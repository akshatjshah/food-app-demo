-- AlterTable
ALTER TABLE "food_items" ADD COLUMN     "is_available" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "is_featured" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "meal_tags" JSONB NOT NULL DEFAULT '[]',
ADD COLUMN     "subcategory" VARCHAR(100);

-- AlterTable
ALTER TABLE "order_item_customizations" ADD COLUMN     "group_name" VARCHAR(100);

-- AlterTable
ALTER TABLE "order_items" ADD COLUMN     "base_price" DECIMAL(10,2),
ADD COLUMN     "food_name" VARCHAR(150);

-- CreateIndex
CREATE INDEX "food_items_is_available_idx" ON "food_items"("is_available");

-- CreateIndex
CREATE INDEX "food_items_is_featured_idx" ON "food_items"("is_featured");

-- CreateIndex
CREATE INDEX "food_items_subcategory_idx" ON "food_items"("subcategory");
