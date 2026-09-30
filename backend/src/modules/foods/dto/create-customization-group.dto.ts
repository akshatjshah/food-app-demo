import { IsString, IsNumber, IsBoolean, IsOptional, Min, Validate, ValidationArguments, ValidatorConstraint, ValidatorConstraintInterface } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

@ValidatorConstraint({ name: 'MinLeqMax', async: false })
export class MinLeqMaxConstraint implements ValidatorConstraintInterface {
  validate(minSelections: number, args: ValidationArguments) {
    const object = args.object as any;
    const maxSelections = object.maxSelections;
    if (maxSelections !== undefined && maxSelections !== null && minSelections > maxSelections) {
      return false;
    }
    return true;
  }

  defaultMessage() {
    return 'minSelections cannot be greater than maxSelections';
  }
}

export class CreateCustomizationGroupDto {
  @ApiProperty({ example: 'Spice Level' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 0, description: 'Minimum options user must select' })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(0)
  @Validate(MinLeqMaxConstraint)
  minSelections?: number;

  @ApiPropertyOptional({ example: 1, description: 'Maximum options user can select' })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  @Min(1)
  maxSelections?: number;

  @ApiPropertyOptional()
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  displayOrder?: number;

  @ApiPropertyOptional({ default: true })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
