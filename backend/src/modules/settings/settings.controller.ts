import { Controller, Get, Post, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SettingsService } from './settings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { Public } from '../../guards/public.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Settings')
@Controller('settings')
export class SettingsController {
  constructor(private settingsService: SettingsService) {}

  // Only non-sensitive display keys are public. OTP hashes, rate-limit
  // records and any future secrets must never be readable without admin auth.
  private static readonly PUBLIC_KEYS = new Set([
    'delivery_fee',
    'min_order_value',
    'platform_fee',
    'tax_rate',
    'business_hours',
    'support_phone',
    'support_email',
    'service_availability',
    'cod_enabled',
    'razorpay_enabled',
    'app_notice',
    'cancellation_policy',
    'delivery_info',
    'about_us',
    'contact_info',
    'faq',
    'terms_display',
    'home_promo_text',
    'subscription_promo_text',
  ]);

  @Public()
  @Get('public/:key')
  @ApiOperation({ summary: 'Get public setting by key' })
  async getPublic(@Param('key') key: string) {
    if (!SettingsController.PUBLIC_KEYS.has(key)) {
      throw new (require('@nestjs/common').ForbiddenException)('Setting is not public');
    }
    return this.settingsService.get(key);
  }

  @Public()
  @Get('public')
  @ApiOperation({ summary: 'Get all public settings' })
  async getAllPublic() {
    const all = await this.settingsService.getAll();
    return all.filter((s: any) => SettingsController.PUBLIC_KEYS.has(s.key));
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Get(':key')
  @ApiOperation({ summary: 'Get setting by key (admin)' })
  async get(@Param('key') key: string) {
    return this.settingsService.get(key);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Get()
  @ApiOperation({ summary: 'Get all settings (admin)' })
  async getAll() {
    return this.settingsService.getAll();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Post()
  @ApiOperation({ summary: 'Set setting (admin)' })
  async set(@Body() body: { key: string; value: string; valueType?: string; description?: string }) {
    return this.settingsService.set(body.key, body.value, body.valueType, body.description);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete(':key')
  @ApiOperation({ summary: 'Delete setting (admin)' })
  async delete(@Param('key') key: string) {
    return this.settingsService.delete(key);
  }
}
