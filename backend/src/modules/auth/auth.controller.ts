import {
  Controller,
  Post,
  Body,
  Get,
  Patch,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { ThrottlerGuard } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { GoogleAuthDto } from './dto/google-auth.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { RegisterFcmTokenDto } from './dto/register-fcm-token.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { Public } from '../../guards/public.decorator';
import { AdminLoginDto } from './dto/admin-login.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @UseGuards(ThrottlerGuard)
  @Post('send-otp')
  @ApiOperation({ summary: 'Send OTP to phone number' })
  @ApiBody({ schema: { properties: { phoneNumber: { example: '+919876543210' } } } })
  async sendOtp(@Body() dto: SendOtpDto) {
    return this.authService.sendOtp(dto.phoneNumber);
  }

  @Public()
  @UseGuards(ThrottlerGuard)
  @Post('verify-otp')
  @ApiOperation({ summary: 'Verify OTP and login/register' })
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto.phoneNumber, dto.otp);
  }

  @Public()
  @UseGuards(ThrottlerGuard)
  @Post('admin-login')
  @ApiOperation({ summary: 'Admin login with email and password' })
  async adminLogin(@Body() dto: AdminLoginDto) {
    return this.authService.adminLogin(dto.email, dto.password);
  }

  @Public()
  @Post('google')
  @ApiOperation({ summary: 'Login/register with Google' })
  async googleAuth(@Body() dto: GoogleAuthDto) {
    return this.authService.googleAuth(dto.idToken, dto.fcmToken);
  }

  @Public()
  @Post('refresh')
  @ApiOperation({ summary: 'Refresh access token using refresh token' })
  async refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('logout')
  @ApiOperation({ summary: 'Logout (revoke refresh token)' })
  async logout(@Request() req, @Body() body?: { refreshToken?: string }) {
    return this.authService.logout(req.user.id, body?.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  async getProfile(@Request() req) {
    return this.authService.getProfile(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Patch('profile')
  @ApiOperation({ summary: 'Update current user profile' })
  async updateProfile(@Request() req, @Body() dto: UpdateProfileDto) {
    return this.authService.updateProfile(req.user.id, dto);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('fcm-token')
  @ApiOperation({ summary: 'Register FCM token for push notifications' })
  async registerFcmToken(@Request() req, @Body() dto: RegisterFcmTokenDto) {
    return this.authService.registerFcmToken(req.user.id, dto.token, dto.platform);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('fcm-token/deactivate')
  @ApiOperation({ summary: 'Deactivate FCM token on logout' })
  async deactivateFcmToken(@Request() req, @Body() body?: { token?: string }) {
    return this.authService.deactivateFcmToken(req.user.id, body?.token);
  }
}
