import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { ReorderCategoriesDto } from './dto/reorder-categories.dto';
export declare class CategoriesController {
    private categoriesService;
    constructor(categoriesService: CategoriesService);
    findAll(): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }[]>;
    findOne(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    findAllAdmin(): Promise<({
        _count: {
            foodItems: number;
        };
    } & {
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    })[]>;
    create(dto: CreateCategoryDto): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    update(id: string, dto: UpdateCategoryDto): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    deactivate(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    activate(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    reorder(dto: ReorderCategoriesDto): Promise<{
        message: string;
    }>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
