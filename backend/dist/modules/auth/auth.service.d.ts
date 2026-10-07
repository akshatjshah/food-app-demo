import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../config/prisma.service';
export declare class AuthService {
    private prisma;
    private jwtService;
    private configService;
    constructor(prisma: PrismaService, jwtService: JwtService, configService: ConfigService);
    sendOtp(phoneNumber: string): Promise<{
        otp?: string | undefined;
        message: string;
        expiresIn: number;
    }>;
    verifyOtp(phoneNumber: string, otp: string): Promise<{
        accessToken: string;
        refreshToken: string;
        isNewUser: boolean;
        user: {
            id: string;
            phoneNumber: string;
            fullName: string | null;
            email: string | null;
            role: import(".prisma/client").$Enums.UserRole;
            walletBalance: number;
            createdAt: Date;
        };
    }>;
    googleAuth(idToken: string, fcmToken?: string): Promise<{
        accessToken: string;
        refreshToken: string;
        isNewUser: boolean;
        user: {
            id: string;
            phoneNumber: string;
            fullName: string | null;
            email: string | null;
            role: import(".prisma/client").$Enums.UserRole;
            walletBalance: number;
        };
    }>;
    refreshToken(refreshToken: string): Promise<{
        accessToken: string;
        refreshToken: string;
    }>;
    logout(userId: string, refreshToken?: string): Promise<{
        message: string;
    }>;
    getProfile(userId: string): Promise<{
        walletBalance: number;
        updatedAt: Date;
        id: string;
        phoneNumber: string;
        email: string | null;
        fullName: string | null;
        role: import(".prisma/client").$Enums.UserRole;
        isBlocked: boolean;
        createdAt: Date;
    }>;
    updateProfile(userId: string, data: {
        fullName?: string;
        email?: string;
    }): Promise<{
        walletBalance: number;
        updatedAt: Date;
        id: string;
        phoneNumber: string;
        email: string | null;
        fullName: string | null;
        role: import(".prisma/client").$Enums.UserRole;
    }>;
    registerFcmToken(userId: string, token: string, platform: string): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        token: string;
        platform: string;
        isActive: boolean;
    }>;
    deactivateFcmToken(userId: string, token?: string): Promise<{
        message: string;
    }>;
    adminLogin(email: string, password: string): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string | null;
            name: string;
            role: import(".prisma/client").$Enums.UserRole;
        };
    }>;
    private generateTokens;
    private enforceOtpSendRateLimit;
    private verifyGoogleToken;
    private upsertFcmToken;
    private generateOtp;
    private hashOtp;
    private hashToken;
}
