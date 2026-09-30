import { ValidationArguments, ValidatorConstraintInterface } from 'class-validator';
export declare class MinLeqMaxConstraint implements ValidatorConstraintInterface {
    validate(minSelections: number, args: ValidationArguments): boolean;
    defaultMessage(): string;
}
export declare class CreateCustomizationGroupDto {
    name: string;
    minSelections?: number;
    maxSelections?: number;
    displayOrder?: number;
    isActive?: boolean;
}
