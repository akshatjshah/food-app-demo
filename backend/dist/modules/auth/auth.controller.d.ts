import { AuthService } from './auth.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { GoogleAuthDto } from './dto/google-auth.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { RegisterFcmTokenDto } from './dto/register-fcm-token.dto';
import { AdminLoginDto } from './dto/admin-login.dto';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    sendOtp(dto: SendOtpDto): Promise<{
        otp?: string | undefined;
        message: string;
        expiresIn: number;
    }>;
    verifyOtp(dto: VerifyOtpDto): Promise<{
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
    adminLogin(dto: AdminLoginDto): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string | null;
            name: string;
            role: import(".prisma/client").$Enums.UserRole;
        };
    }>;
    googleAuth(dto: GoogleAuthDto): Promise<{
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
    refresh(dto: RefreshTokenDto): Promise<{
        accessToken: string;
        refreshToken: string;
    }>;
    logout(req: any, body?: {
        refreshToken?: string;
    }): Promise<{
        message: string;
    }>;
    getProfile(req: any): Promise<{
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
    updateProfile(req: any, dto: UpdateProfileDto): Promise<{
        walletBalance: number;
        updatedAt: Date;
        id: string;
        phoneNumber: string;
        email: string | null;
        fullName: string | null;
        role: import(".prisma/client").$Enums.UserRole;
    }>;
    registerFcmToken(req: any, dto: RegisterFcmTokenDto): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        token: string;
        platform: string;
        isActive: boolean;
    }>;
    deactivateFcmToken(req: any, body?: {
        token?: string;
    }): Promise<{
        message: string;
    }>;
}
