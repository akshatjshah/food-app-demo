/**
 * Parabdi master menu seed — IDEMPOTENT.
 *
 * Source: task specification derived from Parabdi_Final_Organized_Menu.pdf
 * (the PDF file itself was not present in the workspace, so ONLY dishes
 * explicitly enumerated in the task brief are seeded — nothing invented).
 *
 * Safe to run multiple times:
 *  - categories: upsert by unique name
 *  - foods: match by (name) — update in place, never duplicate
 *  - customization groups/items: match by (food, group name) / (group, item name)
 *  - demo foods from the old generic seed (Punjabi Thali, Chicken Biryani,
 *    …) are soft-deleted (isActive=false, deletedAt set) so order history
 *    (FK Restrict) is never broken.
 *
 * Run: node prisma/seed-parabdi-menu.js
 */
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const CATEGORIES = [
  { name: 'Breakfast', icon: '🥞', displayOrder: 1, description: 'Breakfast & morning favourites' },
  { name: 'Shaak & Gujarati Main Dishes', icon: '🍲', displayOrder: 2, description: 'Vegetable / Shaak · Dal / Kadhi / Main preparations' },
  { name: 'Rice & Khichdi', icon: '🍚', displayOrder: 3, description: 'Rice & Khichdi' },
  { name: 'Rotli, Bhakhri & Puri', icon: '🫓', displayOrder: 4, description: 'Rotli / Bhakhri / Puri' },
  { name: 'Visarati Vangio', icon: '🥘', displayOrder: 5, description: 'Traditional / lesser-seen dishes' },
  { name: 'Sweets & Traditional Desserts', icon: '🍮', displayOrder: 6, description: 'Sweets & traditional desserts' },
  { name: 'Snacks & Beverages', icon: '🥤', displayOrder: 7, description: 'Snacks & beverages' },
];

// [name, category, subcategory, price, mealTags]
const FOODS = [
  // ── BREAKFAST ──
  ['White Dhokla', 'Breakfast', 'Breakfast & Morning Favourites', 60, ['breakfast']],
  ['Khatta Dhokla', 'Breakfast', 'Breakfast & Morning Favourites', 60, ['breakfast']],
  ['Handvo', 'Breakfast', 'Breakfast & Morning Favourites', 70, ['breakfast']],
  ['Muthiya', 'Breakfast', 'Breakfast & Morning Favourites', 60, ['breakfast']],
  ['Patra', 'Breakfast', 'Breakfast & Morning Favourites', 70, ['breakfast']],
  ['Khichu', 'Breakfast', 'Breakfast & Morning Favourites', 50, ['breakfast']],
  ['Thepla', 'Breakfast', 'Breakfast & Morning Favourites', 60, ['breakfast']],
  ['Methi Thepla', 'Breakfast', 'Breakfast & Morning Favourites', 70, ['breakfast']],
  ['Bajra Rotla', 'Breakfast', 'Breakfast & Morning Favourites', 50, ['breakfast']],
  ['Makai no Chevdo', 'Breakfast', 'Breakfast & Morning Favourites', 60, ['breakfast']],
  ['Nylon Poha Chevdo', 'Breakfast', 'Breakfast & Morning Favourites', 60, ['breakfast']],
  ['Sev Mamra', 'Breakfast', 'Breakfast & Morning Favourites', 50, ['breakfast']],
  ['Besan Chilla', 'Breakfast', 'Breakfast & Morning Favourites', 80, ['breakfast']],
  ['Vegetable Sandwich', 'Breakfast', 'Breakfast & Morning Favourites', 70, ['breakfast']],
  ['Aloo Sandwiches', 'Breakfast', 'Breakfast & Morning Favourites', 70, ['breakfast']],
  ['Idli', 'Breakfast', 'Breakfast & Morning Favourites', 60, ['breakfast']],
  ['Uttapam', 'Breakfast', 'Breakfast & Morning Favourites', 80, ['breakfast']],
  ['Chakri', 'Breakfast', 'Breakfast & Morning Favourites', 50, ['breakfast']],
  ['Mamra', 'Breakfast', 'Breakfast & Morning Favourites', 40, ['breakfast']],
  ['Sabudana Bataka', 'Breakfast', 'Breakfast & Morning Favourites', 70, ['breakfast']],
  ['Tikhi Puri', 'Breakfast', 'Breakfast & Morning Favourites', 50, ['breakfast']],
  ['Farsi Puri', 'Breakfast', 'Breakfast & Morning Favourites', 50, ['breakfast']],
  ['Lilva Kachori', 'Breakfast', 'Breakfast & Morning Favourites', 70, ['breakfast']],
  ['Aloo Paratha', 'Breakfast', 'Breakfast & Morning Favourites', 80, ['breakfast']],

  // ── SHAAK & MAIN ──
  ['Ringana Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Ooro', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 120, ['lunch', 'dinner']],
  ['Sev Tameta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Dudhi Chana Dal', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Dudhi Muthiya', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 100, ['lunch', 'dinner']],
  ['Kora nu Shak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Tarelu Rataru', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Tindora Fry', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Turiya Patra', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Kobi Vatana', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 100, ['lunch', 'dinner']],
  ['Bhinda nu Shak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Flowers Vatana', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Choli Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Tuver Lilva', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 120, ['lunch', 'dinner']],
  ['Valor Papdi', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 120, ['lunch', 'dinner']],
  ['Valor Dal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', 110, ['lunch', 'dinner']],
  ['Va nu Shak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Rasavala Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 100, ['lunch', 'dinner']],
  ['Guvar Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Methi Alu', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 110, ['lunch', 'dinner']],
  ['Guju Dal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', 90, ['lunch', 'dinner']],
  ['Mung Dal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', 90, ['lunch', 'dinner']],
  ['Rajasthani Daal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', 110, ['lunch', 'dinner']],
  ['Besan ni Sabji', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 100, ['lunch', 'dinner']],
  ['Drum Stick Sabji', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', 120, ['lunch', 'dinner']],
  ['Dal Dhokli', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', 110, ['lunch', 'dinner']],

  // ── RICE & KHICHDI ──
  ['Steam Rice', 'Rice & Khichdi', 'Rice & Khichdi', 80, ['lunch', 'dinner']],
  ['Jeera Rice', 'Rice & Khichdi', 'Rice & Khichdi', 100, ['lunch', 'dinner']],
  ['Khichdi', 'Rice & Khichdi', 'Rice & Khichdi', 90, ['lunch', 'dinner']],
  ['Vaghareli Khichdi', 'Rice & Khichdi', 'Rice & Khichdi', 100, ['lunch', 'dinner']],
  ['Fada Khichdi', 'Rice & Khichdi', 'Rice & Khichdi', 100, ['lunch', 'dinner']],

  // ── ROTLI / BHAKHRI / PURI ──
  ['Phulka Roti', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', 15, ['lunch', 'dinner']],
  ['Tawa Roti', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', 15, ['lunch', 'dinner']],
  ['Bajra Roti', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', 25, ['lunch', 'dinner']],
  ['Makai Rotla', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', 25, ['lunch', 'dinner']],
  ['Jowar Bhakhri', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', 25, ['lunch', 'dinner']],
  ['Wheat Bhakhri', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', 25, ['lunch', 'dinner']],
  ['Puri', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', 30, ['lunch', 'dinner']],
];

// Variant groups from the brief §4: [foodName, groupName, min, max, [[option, price]]]
const VARIANT_GROUPS = [
  ['Nylon Poha Chevdo', 'Choose your type', 1, 1, [['Diet', 0], ['Regular', 0]]],
  ['Besan Chilla', 'Choose your style', 1, 1, [['Normal', 0], ['Fully Veg Loaded', 30]]],
  ['Vegetable Sandwich', 'Choose your toast', 1, 1, [['Without Toast', 0], ['Hand Toasted', 10]]],
  ['Steam Rice', 'Choose your rice', 1, 1, [['Chutta', 0], ['Chadela', 0]]],
  ['Besan ni Sabji', 'Choose your variety', 1, 1, [['Plain', 0], ['Onion', 0], ['Methi', 0], ['Ringan Vado', 10]]],
  ['Drum Stick Sabji', 'Choose your type', 1, 1, [['Type 1', 0], ['Type 2', 0]]],
  ['Dal Dhokli', 'Choose your type', 1, 1, [['Type 1', 0], ['Type 2', 0], ['Type 3', 0]]],
  ['Puri', 'Choose your puri', 1, 1, [['Yellow', 0], ['White', 0]]],
];

// Old generic/demo seed names — NOT Parabdi menu. Soft-delete only.
const DEMO_FOOD_NAMES = [
  'Gujarati Thali',
  'Punjabi Thali',
  'Rajasthani Thali',
  'Chicken Biryani',
  'Paneer Biryani',
  'Butter Naan',
  'Garlic Naan',
  'Tandoori Roti',
  'Samosa (2 pcs)',
  'Pav Bhaji',
  'Masala Dosa',
  'Idli Sambar (4 pcs)',
  'Buddha Bowl',
  'Grilled Chicken Salad',
  'Gulab Jamun (4 pcs)',
  'Rasmalai (2 pcs)',
  'Mango Lassi',
  'Masala Chai',
  'Buttermilk',
];

const DEMO_CATEGORY_NAMES = [
  'Thali',
  'Rice & Biryani',
  'Breads',
  'Snacks',
  'South Indian',
  'Healthy Bowls',
  'Desserts',
  'Beverages',
];

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

  // 2. Foods (match by exact name; preserve existing IDs)
  let created = 0;
  let updated = 0;
  for (let i = 0; i < FOODS.length; i++) {
    const [name, catName, subcategory, price, mealTags] = FOODS[i];
    const cat = catByName.get(catName);
    const existing = await prisma.foodItem.findFirst({ where: { name } });
    const data = {
      categoryId: cat.id,
      description: existing?.description ?? `${name} — authentic Parabdi preparation`,
      price,
      subcategory,
      mealTags,
      isVeg: true,
      isActive: true,
      isAvailable: true,
      deletedAt: null,
      displayOrder: i + 1,
    };
    if (existing) {
      await prisma.foodItem.update({ where: { id: existing.id }, data });
      updated++;
    } else {
      await prisma.foodItem.create({ data: { name, ...data } });
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
        await prisma.customizationItem.create({
          data: { groupId: group.id, name: optName, additionalPrice: optPrice, displayOrder: oi, isActive: true },
        });
        options++;
      } else {
        await prisma.customizationItem.update({
          where: { id: existingOpt.id },
          data: { additionalPrice: optPrice, isActive: true },
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
  console.log('Done.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
