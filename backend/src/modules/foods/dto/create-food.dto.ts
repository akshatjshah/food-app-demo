import { IsString, IsNumber, IsBoolean, IsOptional, IsArray, IsPositive, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateFoodDto {
  @ApiProperty({ description: 'Category ID (must be an active category)' })
  @IsString()
  categoryId: string;

  @ApiProperty({ example: 'Gujarati Thali' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Traditional Gujarati thali with dal, rice, roti, sabzi, and sweets' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ example: 199 })
  @Type(() => Number)
  @IsNumber()
  @IsPositive({ message: 'Price must be a positive number' })
  price: number;

  @ApiPropertyOptional({ example: 249 })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(0)
  originalPrice?: number;

  @ApiPropertyOptional({ type: [String], example: ['https://example.com/thali.jpg'] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  imageUrls?: string[];

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  videoUrl?: string;

  @ApiPropertyOptional()
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(0)
  calories?: number;

  @ApiPropertyOptional({ example: 20 })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(1)
  preparationTimeMinutes?: number;

  @ApiPropertyOptional({ default: true, description: 'Always true — Parabdi is pure vegetarian' })
  @IsBoolean()
  @IsOptional()
  isVeg?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isJainAvailable?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isFastingFriendly?: boolean;

  @ApiPropertyOptional({ description: 'Mark as today\'s special / featured dish' })
  @IsBoolean()
  @IsOptional()
  isBestseller?: boolean;

  @ApiPropertyOptional({ description: 'Admin featured flag (homepage/featured lists)' })
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional({ description: 'Available for ordering right now (separate from active listing)' })
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;

  @ApiPropertyOptional({ description: 'Subcategory within the category, e.g. Shaak, Dal / Kadhi, Rice & Khichdi' })
  @IsString()
  @IsOptional()
  subcategory?: string;

  @ApiPropertyOptional({ type: [String], example: ['breakfast', 'lunch'] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  mealTags?: string[];

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isHealthyPick?: boolean;

  @ApiPropertyOptional({ description: 'Stock count. Null/omitted = unlimited.' })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(0)
  stock?: number;

  @ApiPropertyOptional({ example: 1 })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  displayOrder?: number;

  @ApiPropertyOptional({ type: [String], example: ['spicy', 'lunch'] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[];

  @ApiPropertyOptional({ default: true })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
