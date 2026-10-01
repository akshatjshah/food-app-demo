import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from '../src/modules/auth/auth.service';
import { PrismaService } from '../src/config/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

describe('AuthService', () => {
  let service: AuthService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      user: {
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      setting: {
        findUnique: jest.fn(),
        upsert: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
      refreshToken: {
        create: jest.fn().mockResolvedValue({}),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: prisma },
        { provide: JwtService, useValue: { sign: jest.fn().mockReturnValue('mock-token'), verify: jest.fn() } },
        { provide: ConfigService, useValue: { get: jest.fn((key: string) => {
          if (key === 'JWT_SECRET') return 'test-secret';
          if (key === 'JWT_REFRESH_SECRET') return 'test-refresh-secret';
          if (key === 'OTP_EXPIRY_MINUTES') return '5';
          if (key === 'MAX_OTP_ATTEMPTS') return '3';
          if (key === 'GOOGLE_CLIENT_ID') return '';
          return null;
        }) } },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('sendOtp', () => {
    it('should send OTP for new user', async () => {
      prisma.setting.findUnique.mockResolvedValue(null);
      prisma.setting.upsert.mockResolvedValue({});
      prisma.user.findUnique.mockResolvedValue(null);
      prisma.user.create.mockResolvedValue({ id: '1', phoneNumber: '+919876543210' });

      const result = await service.sendOtp('+919876543210');
      expect(result).toHaveProperty('message');
      expect(result).toHaveProperty('otp');
    });

    it('should send OTP for existing user', async () => {
      prisma.setting.findUnique.mockResolvedValue(null);
      prisma.setting.upsert.mockResolvedValue({});
      prisma.user.findUnique.mockResolvedValue({ id: '1', phoneNumber: '+919876543210' });

      const result = await service.sendOtp('+919876543210');
      expect(result).toHaveProperty('message');
    });

    it('should replace previous OTP on resend (upsert updates hash)', async () => {
      prisma.setting.findUnique.mockResolvedValue(null);
      prisma.setting.upsert.mockResolvedValue({});

      const first = await service.sendOtp('+919876543210');
      const second = await service.sendOtp('+919876543210');

      expect(prisma.setting.upsert).toHaveBeenCalled();
      expect(first.otp).not.toEqual(second.otp);
    });
  });

  describe('verifyOtp', () => {
    const phone = '+919876543210';

    function otpRecord(hash: string, attempts = 0, expiresMs = 60000) {
      return {
        value: JSON.stringify({
          hash,
          expiresAt: new Date(Date.now() + expiresMs).toISOString(),
          attempts,
          createdAt: new Date().toISOString(),
        }),
      };
    }

    // SHA-256 of a known OTP for test fixtures
    const crypto = require('crypto');
    const hashOf = (otp: string) =>
      crypto.createHash('sha256').update(otp).digest('hex');

    it('should reject wrong OTP with friendly message and keep screen usable', async () => {
      prisma.setting.findUnique.mockResolvedValue(otpRecord(hashOf('111111')));
      prisma.setting.update.mockResolvedValue({});

      await expect(service.verifyOtp(phone, '999999')).rejects.toThrow(
        'Invalid OTP. Please try again.',
      );
      expect(prisma.setting.update).toHaveBeenCalled();
      expect(prisma.setting.delete).not.toHaveBeenCalled();
    });

    it('should accept only the latest OTP after resend', async () => {
      const oldOtp = '111111';
      const newOtp = '222222';

      // Resend replaces record with new hash
      prisma.setting.findUnique.mockResolvedValue(otpRecord(hashOf(newOtp)));
      prisma.setting.delete.mockResolvedValue({});
      prisma.user.findUnique.mockResolvedValue({
        id: 'u1',
        phoneNumber: phone,
        fullName: null,
        email: null,
        role: 'customer',
        walletBalance: 0,
        isBlocked: false,
        createdAt: new Date(),
      });

      await expect(service.verifyOtp(phone, oldOtp)).rejects.toThrow(
        'Invalid OTP. Please try again.',
      );

      const result = await service.verifyOtp(phone, newOtp);
      expect(result).toHaveProperty('accessToken');
      expect(result.user.phoneNumber).toBe(phone);
    });

    it('should expire OTP after expiry time', async () => {
      prisma.setting.findUnique.mockResolvedValue(
        otpRecord(hashOf('111111'), 0, -1000),
      );
      prisma.setting.delete.mockResolvedValue({});

      await expect(service.verifyOtp(phone, '111111')).rejects.toThrow(
        'OTP expired',
      );
    });

    it('should require resend after too many failed attempts', async () => {
      prisma.setting.findUnique.mockResolvedValue(otpRecord(hashOf('111111'), 3));
      prisma.setting.delete.mockResolvedValue({});

      await expect(service.verifyOtp(phone, '111111')).rejects.toThrow(
        'resend OTP',
      );
      expect(prisma.setting.delete).toHaveBeenCalled();
    });
  });
});
