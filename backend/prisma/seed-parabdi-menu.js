/**
 * Parabdi master menu seed - IDEMPOTENT.
 *
 * Source: Parabdi_Final_Organized_Menu.pdf as transcribed into the FOODS /
 * VARIANT_GROUPS tables below (exact PDF names/sections; nothing invented).
 * NOTE: the PDF file itself is not in the repo; if the PDF is (re-)supplied,
 * transcribe any additional Visarati / Sweets / Snacks & Beverages pages here
 * and re-run - existing rows are updated in place, never duplicated.
 *
 * Price policy: the seed NEVER writes a business price.
 * - Existing rows: price is NEVER touched (nor description, displayOrder,
 *   isActive, isAvailable, soft-delete state, or any other admin field).
 *   Only structural master fields sync: category / subcategory / mealTags /
 *   isVeg, plus isFastingFriendly on create.
 * - New rows: the PDF specifies no price and FoodItem.price is schema-required
 *   (non-null Decimal), so new rows are created PRICE-PENDING — technical
 *   price 0, isActive=false, isAvailable=false, tags ['price-pending'], NULL
 *   description — hidden from the customer menu until an admin sets a real
 *   price (Food Edit rejects price <= 0) and activates the item.
 * - Variant option prices: missing options are created at neutral 0;
 *   existing options' additionalPrice is NEVER overwritten.
 *
 * Safe to run multiple times:
 *  - categories: upsert by unique name
 *  - foods: match by (name) - update in place, never duplicate
 *  - customization groups/items: match by (food, group name) / (group, item name)
 *  - orphan variant groups belonging to soft-deleted/archived foods are
 *    removed (they have no order_item_customizations FK pointing at groups,
 *    only at items - items referenced by history are kept).
 *  - demo foods from the old generic seed are soft-deleted (isActive=false,
 *    deletedAt set) so order history (FK Restrict) is never broken.
 *
 * Run: node prisma/seed-parabdi-menu.js
 */
const { PrismaClient } = require('@prisma/client');
const { CATEGORIES, FOODS, VARIANT_GROUPS, DEMO_FOOD_NAMES, DEMO_CATEGORY_NAMES } = require('./menu-master');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding Parabdi master menu (idempotent)...');

  const masterNames = new Set(FOODS.map((f) => f[0].toLowerCase()));

  // 1. Categories
  const catByName = new Map();
  for (const c of CATEGORIES) {
    const cat = await prisma.category.upsert({
      where: { name: c.name },
      update: { icon: c.icon, displayOrder: c.displayOrder, description: c.description, isActive: true },
      create: { name: c.name, icon: c.icon, displayOrder: c.displayOrder, description: c.description, isActive: true },
    });
    catByName.set(c.name, cat);
  }
  console.log(`  categories: ${catByName.size}`);

  // 2. Foods (match by exact name; preserve existing IDs AND admin-managed fields)
  let created = 0;
  let updated = 0;
  // Append new items after the highest admin-managed position.
  const maxOrderRow = await prisma.foodItem.aggregate({ _max: { displayOrder: true } });
  let nextOrder = (maxOrderRow._max.displayOrder ?? FOODS.length) + 1;
  for (let i = 0; i < FOODS.length; i++) {
    const [name, catName, subcategory, mealTags, extra] = FOODS[i];
    const cat = catByName.get(catName);
    if (!cat) throw new Error(`Unknown category in menu-master: ${catName} (item: ${name})`);
    const existing = await prisma.foodItem.findFirst({ where: { name } });
    if (existing) {
      // Structural sync only: category / subcategory / meal tags / veg.
      // Admin-managed fields (price, description, display order, active,
      // availability, soft-delete, tags) are NEVER clobbered by a re-run.
      await prisma.foodItem.update({
        where: { id: existing.id },
        data: { categoryId: cat.id, subcategory, mealTags, isVeg: true },
      });
      updated++;
    } else {
      // Price-pending create: NO invented business price or description.
      // Technical price 0 satisfies the non-null schema column; the row stays
      // invisible to customers (inactive + unavailable) until admin prices it.
      await prisma.foodItem.create({
        data: {
          name,
          categoryId: cat.id,
          description: null,
          price: 0,
          subcategory,
          mealTags,
          tags: ['price-pending'],
          isVeg: true,
          isFastingFriendly: extra?.fasting === true,
          isActive: false,
          isAvailable: false,
          displayOrder: nextOrder++,
        },
      });
      created++;
    }
  }
  console.log(`  foods: ${created} created, ${updated} updated`);

  // 3. Variant customization groups (match by food+group name)
  let groups = 0;
  let options = 0;
  for (const [foodName, groupName, min, max, opts] of VARIANT_GROUPS) {
    const food = await prisma.foodItem.findFirst({ where: { name: foodName } });
    if (!food) {
      console.log(`  WARN: food not found for variants: ${foodName}`);
      continue;
    }
    let group = await prisma.customizationGroup.findFirst({
      where: { foodItemId: food.id, name: groupName },
    });
    if (!group) {
      group = await prisma.customizationGroup.create({
        data: { foodItemId: food.id, name: groupName, minSelections: min, maxSelections: max, isActive: true },
      });
      groups++;
    } else {
      await prisma.customizationGroup.update({
        where: { id: group.id },
        data: { minSelections: min, maxSelections: max, isActive: true },
      });
    }
    for (let oi = 0; oi < opts.length; oi++) {
      const [optName, optPrice] = opts[oi];
      const existingOpt = await prisma.customizationItem.findFirst({
        where: { groupId: group.id, name: optName },
      });
      if (!existingOpt) {
        // Missing options are created at the neutral 0 delta from master.
        await prisma.customizationItem.create({
          data: { groupId: group.id, name: optName, additionalPrice: optPrice, displayOrder: oi, isActive: true },
        });
        options++;
      } else {
        // Preserve the existing option's additionalPrice (admin-managed);
        // only ensure spec options stay structurally present and ordered.
        await prisma.customizationItem.update({
          where: { id: existingOpt.id },
          data: { isActive: true },
        });
      }
    }
  }
  console.log(`  variant groups: ${groups} created (others updated), ${options} options created`);

  // 4. Archive demo foods (soft-delete; keeps order_items FK intact).
  //    Skip any name that is genuinely part of the master menu.
  const toArchive = DEMO_FOOD_NAMES.filter((n) => !masterNames.has(n.toLowerCase()));
  let archived = 0;
  for (const n of toArchive) {
    const res = await prisma.foodItem.updateMany({
      where: { name: n, deletedAt: null },
      data: { isActive: false, isAvailable: false, deletedAt: new Date() },
    });
    archived += res.count;
  }
  console.log(`  demo foods archived (soft-delete): ${archived}`);

  // 5. Deactivate demo categories that no longer own visible foods.
  for (const n of DEMO_CATEGORY_NAMES) {
    const remaining = await prisma.foodItem.count({
      where: { category: { name: n }, deletedAt: null },
    });
    if (remaining === 0) {
      await prisma.category.updateMany({ where: { name: n }, data: { isActive: false } });
    }
  }

  // 6. Remove orphan variant groups of soft-deleted foods (e.g. leftover
  //    "Mango Lassi :: meduium"). Groups have no order-history FK pointing at
  //    them (OrderItemCustomization -> CustomizationItem only), so deleting an
  //    EMPTY group (no items) or a group whose food is deleted is safe.
  //    Groups with items referenced by order history are left untouched.
  const orphanGroups = await prisma.customizationGroup.findMany({
    where: { foodItem: { deletedAt: { not: null } } },
    include: { items: { include: { _count: { select: { orderItemCustomizations: true } } } } },
  });
  let orphanRemoved = 0;
  for (const g of orphanGroups) {
    const referenced = g.items.some((it) => it._count.orderItemCustomizations > 0);
    if (referenced) {
      console.log(`  keep orphan group with order history: ${g.name}`);
      continue;
    }
    await prisma.customizationGroup.delete({ where: { id: g.id } });
    orphanRemoved++;
  }
  console.log(`  orphan variant groups removed: ${orphanRemoved}`);
  console.log('Done.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
