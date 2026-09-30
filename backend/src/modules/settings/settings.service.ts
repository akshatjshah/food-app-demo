import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class SettingsService {
  constructor(private prisma: PrismaService) {}

  private isSecretKey(key: string) {
    return key.startsWith('otp:') || key.startsWith('otp_rate:');
  }

  async get(key: string) {
    if (this.isSecretKey(key)) {
      // OTP hashes must never be readable via settings API.
      return null;
    }
    const setting = await this.prisma.setting.findUnique({ where: { key } });
    return setting ? { key: setting.key, value: setting.value, valueType: setting.valueType } : null;
  }

  async getAll() {
    const all = await this.prisma.setting.findMany();
    // Strip OTP/rate-limit secrets; never expose hashes.
    return all
      .filter((s) => !this.isSecretKey(s.key))
      .map((s) => ({ key: s.key, value: s.value, valueType: s.valueType, description: s.description, updatedAt: s.updatedAt }));
  }

  async set(key: string, value: string, valueType?: string, description?: string) {
    return this.prisma.setting.upsert({
      where: { key },
      update: { value, valueType, description },
      create: { key, value, valueType: valueType || 'string', description },
    });
  }

  async delete(key: string) {
    return this.prisma.setting.delete({ where: { key } });
  }
}
