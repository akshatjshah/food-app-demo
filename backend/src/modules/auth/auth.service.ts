import { Injectable, UnauthorizedException, BadRequestException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../config/prisma.service';
import { UserRole } from '@prisma/client';
import * as crypto from 'crypto';
import * as bcrypt from 'bcryptjs';

const OTP_EXPIRY_MS = 5 * 60 * 1000;
const OTP_MAX_ATTEMPTS = 3;
const OTP_RATE_LIMIT_WINDOW_MS = 5 * 60 * 1000;
const OTP_MAX_SENDS_PER_WINDOW = 5;

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async sendOtp(phoneNumber: string) {
    await this.enforceOtpSendRateLimit(phoneNumber);

    const otp = this.generateOtp();
    const otpHash = this.hashOtp(otp);
    const expiresAt = new Date(Date.now() + OTP_EXPIRY_MS);
    const nowIso = new Date().toISOString();

    // Upsert replaces any previous OTP (hash, expiry, attempts) for this phone.
    await this.prisma.setting.upsert({
      where: { key: `otp:${phoneNumber}` },
      update: {
        value: JSON.stringify({
          hash: otpHash,
          expiresAt: expiresAt.toISOString(),
          attempts: 0,
          createdAt: nowIso,
        }),
      },
      create: {
        key: `otp:${phoneNumber}`,
        value: JSON.stringify({
          hash: otpHash,
          expiresAt: expiresAt.toISOString(),
          attempts: 0,
          createdAt: nowIso,
        }),
        valueType: 'json',
        description: `OTP for ${phoneNumber}`,
      },
    });

    console.log(`[OTP] ${phoneNumber}: ${otp} (expires: ${expiresAt.toISOString()})`);

    const isDev = this.configService.get<string>('NODE_ENV') !== 'production';
    return {
      message: 'OTP sent successfully',
      expiresIn: OTP_EXPIRY_MS / 1000,
      // Only expose the code in non-production (dev SMS bypass). Production
      // delivers via SMS provider and must never leak the code in API output.
      ...(isDev ? { otp } : {}),
    };
  }

  async verifyOtp(phoneNumber: string, otp: string) {
    const record = await this.prisma.setting.findUnique({
      where: { key: `otp:${phoneNumber}` },
    });

    if (!record) {
      throw new UnauthorizedException('OTP not found. Please request a new one.');
    }

    const data = JSON.parse(record.value);
    const now = Date.now();

    if (now > new Date(data.expiresAt).getTime()) {
      await this.prisma.setting.delete({ where: { key: `otp:${phoneNumber}` } });
      throw new UnauthorizedException('OTP expired. Please request a new one.');
    }

    if (data.attempts >= OTP_MAX_ATTEMPTS) {
      await this.prisma.setting.delete({ where: { key: `otp:${phoneNumber}` } });
      throw new UnauthorizedException(
        'Too many failed attempts. Please resend OTP to get a new code.',
      );
    }

    const otpHash = this.hashOtp(otp);
    if (data.hash !== otpHash) {
      const attempts = (data.attempts || 0) + 1;
      const remaining = Math.max(OTP_MAX_ATTEMPTS - attempts, 0);
      await this.prisma.setting.update({
        where: { key: `otp:${phoneNumber}` },
        data: { value: JSON.stringify({ ...data, attempts }) },
      });
      if (remaining <= 0) {
        throw new UnauthorizedException(
          'Invalid OTP. Please resend OTP to get a new code.',
        );
      }
      throw new UnauthorizedException('Invalid OTP. Please try again.');
    }

    await this.prisma.setting.delete({ where: { key: `otp:${phoneNumber}` } });

    let user = await this.prisma.user.findUnique({
      where: { phoneNumber },
    });

    const isNewUser = !user;

    if (!user) {
      user = await this.prisma.user.create({
        data: { phoneNumber, role: UserRole.customer },
      });
    }

    if (user.isBlocked) {
      throw new UnauthorizedException('Account has been blocked. Contact support.');
    }

    const tokens = await this.generateTokens(user.id, user.phoneNumber, user.role);

    return {
      isNewUser,
      user: {
        id: user.id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        walletBalance: Number(user.walletBalance),
        createdAt: user.createdAt,
      },
      ...tokens,
    };
  }

  async googleAuth(idToken: string, fcmToken?: string) {
    const payload = await this.verifyGoogleToken(idToken);
    if (!payload) {
      throw new UnauthorizedException('Invalid Google token');
    }

    let user = await this.prisma.user.findFirst({
      where: { email: payload.email },
    });

    const isNewUser = !user;

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          phoneNumber: `google_${payload.sub}`,
          email: payload.email,
          fullName: payload.name || payload.email.split('@')[0],
          role: UserRole.customer,
        },
      });
    }

    if (user.isBlocked) {
      throw new UnauthorizedException('Account has been blocked.');
    }

    if (fcmToken) {
      await this.upsertFcmToken(user.id, fcmToken, 'web');
    }

    const tokens = await this.generateTokens(user.id, user.phoneNumber, user.role);

    return {
      isNewUser,
      user: {
        id: user.id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        walletBalance: Number(user.walletBalance),
      },
      ...tokens,
    };
  }

  async refreshToken(refreshToken: string) {
    let payload: any;
    try {
      payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokenHash = this.hashToken(refreshToken);
    const storedToken = await this.prisma.refreshToken.findFirst({
      where: {
        userId: payload.sub,
        tokenHash,
        isRevoked: false,
      },
    });

    if (!storedToken) {
      throw new UnauthorizedException('Refresh token not found or revoked');
    }

    if (new Date() > storedToken.expiresAt) {
      await this.prisma.refreshToken.update({
        where: { id: storedToken.id },
        data: { isRevoked: true },
      });
      throw new UnauthorizedException('Refresh token expired');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
    });

    if (!user || user.isBlocked) {
      throw new UnauthorizedException('User not found or blocked');
    }

    await this.prisma.refreshToken.update({
      where: { id: storedToken.id },
      data: { isRevoked: true },
    });

    const tokens = await this.generateTokens(user.id, user.phoneNumber, user.role);

    return tokens;
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      const tokenHash = this.hashToken(refreshToken);
      await this.prisma.refreshToken.updateMany({
        where: { userId, tokenHash },
        data: { isRevoked: true },
      });
    } else {
      await this.prisma.refreshToken.updateMany({
        where: { userId, isRevoked: false },
        data: { isRevoked: true },
      });
    }

    return { message: 'Logged out successfully' };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        phoneNumber: true,
        fullName: true,
        email: true,
        role: true,
        walletBalance: true,
        isBlocked: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return { ...user, walletBalance: Number(user.walletBalance) };
  }

  async updateProfile(userId: string, data: { fullName?: string; email?: string }) {
    if (data.email) {
      const existing = await this.prisma.user.findFirst({
        where: { email: data.email, id: { not: userId } },
      });
      if (existing) {
        throw new ConflictException('Email already in use');
      }
    }

    const user = await this.prisma.user.update({
      where: { id: userId },
      data,
      select: {
        id: true,
        phoneNumber: true,
        fullName: true,
        email: true,
        role: true,
        walletBalance: true,
        updatedAt: true,
      },
    });

    return { ...user, walletBalance: Number(user.walletBalance) };
  }

  async registerFcmToken(userId: string, token: string, platform: string) {
    return this.upsertFcmToken(userId, token, platform);
  }

  async deactivateFcmToken(userId: string, token?: string) {
    if (token) {
      await this.prisma.fcmToken.updateMany({
        where: { userId, token },
        data: { isActive: false },
      });
    } else {
      await this.prisma.fcmToken.updateMany({
        where: { userId, isActive: true },
        data: { isActive: false },
      });
    }
    return { message: 'Device token(s) deactivated' };
  }

  async adminLogin(email: string, password: string) {
    const user = await this.prisma.user.findFirst({
      where: { email, role: UserRole.admin },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException('Admin account not configured. Contact support.');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    if (user.isBlocked) {
      throw new UnauthorizedException('Account has been blocked.');
    }

    const accessToken = this.jwtService.sign(
      { sub: user.id, email: user.email, role: user.role, jti: crypto.randomUUID() },
      { expiresIn: this.configService.get<string>('JWT_EXPIRES_IN', '15m') } as any,
    );

    return {
      access_token: accessToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.fullName || 'Admin',
        role: user.role,
      },
    };
  }

  private async generateTokens(userId: string, phone: string, role: string) {
    const accessToken = this.jwtService.sign(
      { sub: userId, phone, role, jti: crypto.randomUUID() },
      { expiresIn: this.configService.get<string>('JWT_EXPIRES_IN', '15m') } as any,
    );

    const refreshTokenValue = this.jwtService.sign(
      { sub: userId, phone, role, jti: crypto.randomUUID() },
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRES_IN', '7d'),
      } as any,
    );

    const tokenHash = this.hashToken(refreshTokenValue);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt,
      },
    });

    return { accessToken, refreshToken: refreshTokenValue };
  }

  private async enforceOtpSendRateLimit(phoneNumber: string) {
    const key = `otp_rate:${phoneNumber}`;
    const record = await this.prisma.setting.findUnique({ where: { key } });
    const now = Date.now();

    let count = 0;
    let windowStart = now;

    if (record) {
      try {
        const data = JSON.parse(record.value);
        windowStart = new Date(data.windowStart).getTime();
        count = Number(data.count) || 0;
      } catch {
        windowStart = now;
        count = 0;
      }

      if (now - windowStart >= OTP_RATE_LIMIT_WINDOW_MS) {
        count = 0;
        windowStart = now;
      }
    }

    if (count >= OTP_MAX_SENDS_PER_WINDOW) {
      const waitSeconds = Math.ceil(
        (OTP_RATE_LIMIT_WINDOW_MS - (now - windowStart)) / 1000,
      );
      throw new BadRequestException(
        `Too many OTP requests. Please wait ${waitSeconds} seconds.`,
      );
    }

    const value = JSON.stringify({
      count: count + 1,
      windowStart: new Date(windowStart).toISOString(),
    });

    await this.prisma.setting.upsert({
      where: { key },
      update: { value },
      create: {
        key,
        value,
        valueType: 'json',
        description: `OTP send rate for ${phoneNumber}`,
      },
    });
  }

  private async verifyGoogleToken(idToken: string) {
    try {
      const response = await fetch(
        `https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`,
      );
      if (!response.ok) return null;
      const data = await response.json();
      if (data.aud !== this.configService.get<string>('GOOGLE_CLIENT_ID')) return null;
      return data;
    } catch {
      return null;
    }
  }

  private async upsertFcmToken(userId: string, token: string, platform: string) {
    const existing = await this.prisma.fcmToken.findFirst({
      where: { userId, token },
    });

    if (existing) {
      return this.prisma.fcmToken.update({
        where: { id: existing.id },
        data: { isActive: true },
      });
    }

    return this.prisma.fcmToken.create({
      data: { userId, token, platform },
    });
  }

  private generateOtp(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  private hashOtp(otp: string): string {
    return crypto.createHash('sha256').update(otp).digest('hex');
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }
}
