import { IsString, IsNumber, IsOptional, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCouponDto {
  @ApiProperty({ example: 'WELCOME20' })
  @IsString()
  code: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ example: 'percentage' })
  @IsString()
  discountType: string;

  @ApiProperty({ example: 20 })
  @IsNumber()
  discountValue: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  minOrderValue?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  maxDiscountValue?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  maxUses?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  maxUsesPerUser?: number;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isFirstOrderOnly?: boolean;

  @ApiPropertyOptional({ example: true, description: 'Visible/active to customers' })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiProperty({ example: '2026-12-31' })
  @IsString()
  expiresAt: string;
}
