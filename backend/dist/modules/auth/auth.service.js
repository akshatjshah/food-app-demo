"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../../config/prisma.service");
const client_1 = require("@prisma/client");
const crypto = require("crypto");
const bcrypt = require("bcryptjs");
const OTP_EXPIRY_MS = 5 * 60 * 1000;
const OTP_MAX_ATTEMPTS = 3;
const OTP_RATE_LIMIT_WINDOW_MS = 5 * 60 * 1000;
const OTP_MAX_SENDS_PER_WINDOW = 5;
let AuthService = class AuthService {
    constructor(prisma, jwtService, configService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
        this.configService = configService;
    }
    async sendOtp(phoneNumber) {
        await this.enforceOtpSendRateLimit(phoneNumber);
        const otp = this.generateOtp();
        const otpHash = this.hashOtp(otp);
        const expiresAt = new Date(Date.now() + OTP_EXPIRY_MS);
        const nowIso = new Date().toISOString();
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
        const isDev = this.configService.get('NODE_ENV') !== 'production';
        return {
            message: 'OTP sent successfully',
            expiresIn: OTP_EXPIRY_MS / 1000,
            ...(isDev ? { otp } : {}),
        };
    }
    async verifyOtp(phoneNumber, otp) {
        const record = await this.prisma.setting.findUnique({
            where: { key: `otp:${phoneNumber}` },
        });
        if (!record) {
            throw new common_1.UnauthorizedException('OTP not found. Please request a new one.');
        }
        const data = JSON.parse(record.value);
        const now = Date.now();
        if (now > new Date(data.expiresAt).getTime()) {
            await this.prisma.setting.delete({ where: { key: `otp:${phoneNumber}` } });
            throw new common_1.UnauthorizedException('OTP expired. Please request a new one.');
        }
        if (data.attempts >= OTP_MAX_ATTEMPTS) {
            await this.prisma.setting.delete({ where: { key: `otp:${phoneNumber}` } });
            throw new common_1.UnauthorizedException('Too many failed attempts. Please resend OTP to get a new code.');
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
                throw new common_1.UnauthorizedException('Invalid OTP. Please resend OTP to get a new code.');
            }
            throw new common_1.UnauthorizedException('Invalid OTP. Please try again.');
        }
        await this.prisma.setting.delete({ where: { key: `otp:${phoneNumber}` } });
        let user = await this.prisma.user.findUnique({
            where: { phoneNumber },
        });
        const isNewUser = !user;
        if (!user) {
            user = await this.prisma.user.create({
                data: { phoneNumber, role: client_1.UserRole.customer },
            });
        }
        if (user.isBlocked) {
            throw new common_1.UnauthorizedException('Account has been blocked. Contact support.');
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
    async googleAuth(idToken, fcmToken) {
        const payload = await this.verifyGoogleToken(idToken);
        if (!payload) {
            throw new common_1.UnauthorizedException('Invalid Google token');
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
                    role: client_1.UserRole.customer,
                },
            });
        }
        if (user.isBlocked) {
            throw new common_1.UnauthorizedException('Account has been blocked.');
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
    async refreshToken(refreshToken) {
        let payload;
        try {
            payload = this.jwtService.verify(refreshToken, {
                secret: this.configService.get('JWT_REFRESH_SECRET'),
            });
        }
        catch {
            throw new common_1.UnauthorizedException('Invalid refresh token');
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
            throw new common_1.UnauthorizedException('Refresh token not found or revoked');
        }
        if (new Date() > storedToken.expiresAt) {
            await this.prisma.refreshToken.update({
                where: { id: storedToken.id },
                data: { isRevoked: true },
            });
            throw new common_1.UnauthorizedException('Refresh token expired');
        }
        const user = await this.prisma.user.findUnique({
            where: { id: payload.sub },
        });
        if (!user || user.isBlocked) {
            throw new common_1.UnauthorizedException('User not found or blocked');
        }
        await this.prisma.refreshToken.update({
            where: { id: storedToken.id },
            data: { isRevoked: true },
        });
        const tokens = await this.generateTokens(user.id, user.phoneNumber, user.role);
        return tokens;
    }
    async logout(userId, refreshToken) {
        if (refreshToken) {
            const tokenHash = this.hashToken(refreshToken);
            await this.prisma.refreshToken.updateMany({
                where: { userId, tokenHash },
                data: { isRevoked: true },
            });
        }
        else {
            await this.prisma.refreshToken.updateMany({
                where: { userId, isRevoked: false },
                data: { isRevoked: true },
            });
        }
        return { message: 'Logged out successfully' };
    }
    async getProfile(userId) {
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
            throw new common_1.UnauthorizedException('User not found');
        }
        return { ...user, walletBalance: Number(user.walletBalance) };
    }
    async updateProfile(userId, data) {
        if (data.email) {
            const existing = await this.prisma.user.findFirst({
                where: { email: data.email, id: { not: userId } },
            });
            if (existing) {
                throw new common_1.ConflictException('Email already in use');
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
    async registerFcmToken(userId, token, platform) {
        return this.upsertFcmToken(userId, token, platform);
    }
    async deactivateFcmToken(userId, token) {
        if (token) {
            await this.prisma.fcmToken.updateMany({
                where: { userId, token },
                data: { isActive: false },
            });
        }
        else {
            await this.prisma.fcmToken.updateMany({
                where: { userId, isActive: true },
                data: { isActive: false },
            });
        }
        return { message: 'Device token(s) deactivated' };
    }
    async adminLogin(email, password) {
        const user = await this.prisma.user.findFirst({
            where: { email, role: client_1.UserRole.admin },
        });
        if (!user) {
            throw new common_1.UnauthorizedException('Invalid email or password');
        }
        if (!user.passwordHash) {
            throw new common_1.UnauthorizedException('Admin account not configured. Contact support.');
        }
        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
        if (!isPasswordValid) {
            throw new common_1.UnauthorizedException('Invalid email or password');
        }
        if (user.isBlocked) {
            throw new common_1.UnauthorizedException('Account has been blocked.');
        }
        const accessToken = this.jwtService.sign({ sub: user.id, email: user.email, role: user.role, jti: crypto.randomUUID() }, { expiresIn: this.configService.get('JWT_EXPIRES_IN', '15m') });
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
    async generateTokens(userId, phone, role) {
        const accessToken = this.jwtService.sign({ sub: userId, phone, role, jti: crypto.randomUUID() }, { expiresIn: this.configService.get('JWT_EXPIRES_IN', '15m') });
        const refreshTokenValue = this.jwtService.sign({ sub: userId, phone, role, jti: crypto.randomUUID() }, {
            secret: this.configService.get('JWT_REFRESH_SECRET'),
            expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
        });
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
    async enforceOtpSendRateLimit(phoneNumber) {
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
            }
            catch {
                windowStart = now;
                count = 0;
            }
            if (now - windowStart >= OTP_RATE_LIMIT_WINDOW_MS) {
                count = 0;
                windowStart = now;
            }
        }
        if (count >= OTP_MAX_SENDS_PER_WINDOW) {
            const waitSeconds = Math.ceil((OTP_RATE_LIMIT_WINDOW_MS - (now - windowStart)) / 1000);
            throw new common_1.BadRequestException(`Too many OTP requests. Please wait ${waitSeconds} seconds.`);
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
    async verifyGoogleToken(idToken) {
        try {
            const response = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
            if (!response.ok)
                return null;
            const data = await response.json();
            if (data.aud !== this.configService.get('GOOGLE_CLIENT_ID'))
                return null;
            return data;
        }
        catch {
            return null;
        }
    }
    async upsertFcmToken(userId, token, platform) {
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
    generateOtp() {
        return Math.floor(100000 + Math.random() * 900000).toString();
    }
    hashOtp(otp) {
        return crypto.createHash('sha256').update(otp).digest('hex');
    }
    hashToken(token) {
        return crypto.createHash('sha256').update(token).digest('hex');
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService,
        config_1.ConfigService])
], AuthService);
//# sourceMappingURL=auth.service.js.map