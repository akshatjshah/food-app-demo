import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { FoodsService } from './foods.service';
import { CreateFoodDto } from './dto/create-food.dto';
import { UpdateFoodDto } from './dto/update-food.dto';
import { CreateCustomizationGroupDto } from './dto/create-customization-group.dto';
import { UpdateCustomizationGroupDto } from './dto/update-customization-group.dto';
import { CreateCustomizationItemDto } from './dto/create-customization-item.dto';
import { UpdateCustomizationItemDto } from './dto/update-customization-item.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { Public } from '../../guards/public.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Foods')
@Controller('foods')
export class FoodsController {
  constructor(private foodsService: FoodsService) {}

  // ========== PUBLIC ENDPOINTS ==========

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get available food items (public)' })
  @ApiQuery({ name: 'categoryId', required: false })
  @ApiQuery({ name: 'subcategory', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'isVeg', required: false })
  @ApiQuery({ name: 'isJainAvailable', required: false })
  @ApiQuery({ name: 'isFastingFriendly', required: false })
  @ApiQuery({ name: 'isBestseller', required: false })
  @ApiQuery({ name: 'isFeatured', required: false })
  @ApiQuery({ name: 'isHealthyPick', required: false })
  @ApiQuery({ name: 'isAvailable', required: false })
  @ApiQuery({ name: 'mealTag', required: false })
  @ApiQuery({ name: 'hasCustomization', required: false })
  @ApiQuery({ name: 'minPrice', required: false })
  @ApiQuery({ name: 'maxPrice', required: false })
  @ApiQuery({ name: 'sort', required: false, description: 'recommended|popular|priceAsc|priceDesc|nameAsc' })
  @ApiQuery({ name: 'skip', required: false })
  @ApiQuery({ name: 'take', required: false })
  async findAll(
    @Query('categoryId') categoryId?: string,
    @Query('search') search?: string,
    @Query('subcategory') subcategory?: string,
    @Query('isVeg') isVeg?: string,
    @Query('isJainAvailable') isJainAvailable?: string,
    @Query('isFastingFriendly') isFastingFriendly?: string,
    @Query('isBestseller') isBestseller?: string,
    @Query('isFeatured') isFeatured?: string,
    @Query('isHealthyPick') isHealthyPick?: string,
    @Query('isAvailable') isAvailable?: string,
    @Query('mealTag') mealTag?: string,
    @Query('hasCustomization') hasCustomization?: string,
    @Query('minPrice') minPrice?: string,
    @Query('maxPrice') maxPrice?: string,
    @Query('sort') sort?: string,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    const bool = (v?: string) => (v !== undefined ? v === 'true' : undefined);
    return this.foodsService.findAll({
      categoryId,
      subcategory,
      search,
      isVeg: bool(isVeg),
      isJainAvailable: bool(isJainAvailable),
      isFastingFriendly: bool(isFastingFriendly),
      isBestseller: bool(isBestseller),
      isFeatured: bool(isFeatured),
      isHealthyPick: bool(isHealthyPick),
      isAvailable: bool(isAvailable),
      mealTag,
      hasCustomization: hasCustomization !== undefined ? hasCustomization === 'true' : undefined,
      minPrice: minPrice ? parseFloat(minPrice) : undefined,
      maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
      sort,
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 50,
    });
  }

  @Public()
  @Get('specials')
  @ApiOperation({ summary: 'Get today\'s special dishes (public)' })
  async findSpecials() {
    return this.foodsService.findSpecials();
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get food item details with customizations (public)' })
  async findOne(@Param('id') id: string) {
    return this.foodsService.findOne(id);
  }

  // ========== ADMIN/CHEF ENDPOINTS ==========

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Get('admin/all')
  @ApiOperation({ summary: 'Get all food items including inactive (admin/chef)' })
  @ApiQuery({ name: 'categoryId', required: false })
  @ApiQuery({ name: 'subcategory', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'isActive', required: false })
  @ApiQuery({ name: 'isAvailable', required: false })
  @ApiQuery({ name: 'isFeatured', required: false })
  @ApiQuery({ name: 'isBestseller', required: false })
  @ApiQuery({ name: 'mealTag', required: false })
  @ApiQuery({ name: 'hasCustomization', required: false })
  @ApiQuery({ name: 'minPrice', required: false })
  @ApiQuery({ name: 'maxPrice', required: false })
  @ApiQuery({ name: 'sort', required: false })
  @ApiQuery({ name: 'skip', required: false })
  @ApiQuery({ name: 'take', required: false })
  async findAllAdmin(
    @Query('categoryId') categoryId?: string,
    @Query('subcategory') subcategory?: string,
    @Query('search') search?: string,
    @Query('isActive') isActive?: string,
    @Query('isAvailable') isAvailable?: string,
    @Query('isFeatured') isFeatured?: string,
    @Query('isBestseller') isBestseller?: string,
    @Query('mealTag') mealTag?: string,
    @Query('hasCustomization') hasCustomization?: string,
    @Query('minPrice') minPrice?: string,
    @Query('maxPrice') maxPrice?: string,
    @Query('sort') sort?: string,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    const bool = (v?: string) => (v !== undefined && v !== '' ? v === 'true' : undefined);
    return this.foodsService.findAll({
      categoryId,
      subcategory,
      search,
      isActive: bool(isActive),
      isAvailable: bool(isAvailable),
      isFeatured: bool(isFeatured),
      isBestseller: bool(isBestseller),
      mealTag,
      hasCustomization: hasCustomization !== undefined && hasCustomization !== '' ? hasCustomization === 'true' : undefined,
      minPrice: minPrice ? parseFloat(minPrice) : undefined,
      maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
      sort,
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 500,
      includeInactive: true,
    });
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Post()
  @ApiOperation({ summary: 'Create food item (admin/chef)' })
  async create(@Body() dto: CreateFoodDto) {
    return this.foodsService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Patch(':id')
  @ApiOperation({ summary: 'Update food item (admin/chef)' })
  async update(@Param('id') id: string, @Body() dto: UpdateFoodDto) {
    return this.foodsService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete(':id')
  @ApiOperation({ summary: 'Delete food item (admin only)' })
  async remove(@Param('id') id: string) {
    return this.foodsService.remove(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Patch(':id/toggle-active')
  @ApiOperation({ summary: 'Toggle food item availability (admin/chef)' })
  async toggleActive(@Param('id') id: string) {
    return this.foodsService.toggleActive(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Patch(':id/toggle-bestseller')
  @ApiOperation({ summary: 'Toggle bestseller/special status (admin)' })
  async toggleBestseller(@Param('id') id: string) {
    return this.foodsService.toggleBestseller(id);
  }

  // ========== CUSTOMIZATION GROUPS ==========

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Get(':foodItemId/customizations')
  @ApiOperation({ summary: 'Get customization groups for food item (admin/chef)' })
  async getCustomizationGroups(@Param('foodItemId') foodItemId: string) {
    return this.foodsService.getCustomizationGroups(foodItemId);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Post(':foodItemId/customizations')
  @ApiOperation({ summary: 'Create customization group (admin/chef)' })
  async createCustomizationGroup(
    @Param('foodItemId') foodItemId: string,
    @Body() dto: CreateCustomizationGroupDto,
  ) {
    return this.foodsService.createCustomizationGroup(foodItemId, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Patch('customizations/groups/:groupId')
  @ApiOperation({ summary: 'Update customization group (admin/chef)' })
  async updateCustomizationGroup(
    @Param('groupId') groupId: string,
    @Body() dto: UpdateCustomizationGroupDto,
  ) {
    return this.foodsService.updateCustomizationGroup(groupId, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete('customizations/groups/:groupId')
  @ApiOperation({ summary: 'Delete customization group (admin only)' })
  async deleteCustomizationGroup(@Param('groupId') groupId: string) {
    return this.foodsService.deleteCustomizationGroup(groupId);
  }

  // ========== CUSTOMIZATION ITEMS ==========

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Post('customizations/groups/:groupId/items')
  @ApiOperation({ summary: 'Create customization option (admin/chef)' })
  async createCustomizationItem(
    @Param('groupId') groupId: string,
    @Body() dto: CreateCustomizationItemDto,
  ) {
    return this.foodsService.createCustomizationItem(groupId, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Patch('customizations/items/:itemId')
  @ApiOperation({ summary: 'Update customization option (admin/chef)' })
  async updateCustomizationItem(
    @Param('itemId') itemId: string,
    @Body() dto: UpdateCustomizationItemDto,
  ) {
    return this.foodsService.updateCustomizationItem(itemId, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete('customizations/items/:itemId')
  @ApiOperation({ summary: 'Delete customization option (admin only)' })
  async deleteCustomizationItem(@Param('itemId') itemId: string) {
    return this.foodsService.deleteCustomizationItem(itemId);
  }
}
