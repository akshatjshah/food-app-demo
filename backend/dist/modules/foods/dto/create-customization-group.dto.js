"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CreateCustomizationGroupDto = exports.MinLeqMaxConstraint = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
const class_transformer_1 = require("class-transformer");
let MinLeqMaxConstraint = class MinLeqMaxConstraint {
    validate(minSelections, args) {
        const object = args.object;
        const maxSelections = object.maxSelections;
        if (maxSelections !== undefined && maxSelections !== null && minSelections > maxSelections) {
            return false;
        }
        return true;
    }
    defaultMessage() {
        return 'minSelections cannot be greater than maxSelections';
    }
};
exports.MinLeqMaxConstraint = MinLeqMaxConstraint;
exports.MinLeqMaxConstraint = MinLeqMaxConstraint = __decorate([
    (0, class_validator_1.ValidatorConstraint)({ name: 'MinLeqMax', async: false })
], MinLeqMaxConstraint);
class CreateCustomizationGroupDto {
}
exports.CreateCustomizationGroupDto = CreateCustomizationGroupDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Spice Level' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateCustomizationGroupDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 0, description: 'Minimum options user must select' }),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Validate)(MinLeqMaxConstraint),
    __metadata("design:type", Number)
], CreateCustomizationGroupDto.prototype, "minSelections", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 1, description: 'Maximum options user can select' }),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], CreateCustomizationGroupDto.prototype, "maxSelections", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateCustomizationGroupDto.prototype, "displayOrder", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ default: true }),
    (0, class_validator_1.IsBoolean)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], CreateCustomizationGroupDto.prototype, "isActive", void 0);
//# sourceMappingURL=create-customization-group.dto.js.map