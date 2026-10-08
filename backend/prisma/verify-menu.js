const { PrismaClient } = require('@prisma/client');
(async () => {
  const p = new PrismaClient();
  const cats = await p.category.findMany({ orderBy: { displayOrder: 'asc' } });
  console.log('CATS:', cats.map((c) => c.name + '(' + (c.isActive ? 'on' : 'off') + ')').join(' | '));
  const n = await p.foodItem.count({ where: { deletedAt: null } });
  console.log('ACTIVE_FOODS:', n);
  const subs = await p.foodItem.findMany({ where: { deletedAt: null }, select: { subcategory: true }, distinct: ['subcategory'] });
  console.log('SUBS:', subs.map((s) => s.subcategory).join(' | '));
  const g = await p.customizationGroup.count();
  const it = await p.customizationItem.count();
  console.log('GROUPS:', g, 'ITEMS:', it);
  const sample = await p.foodItem.findFirst({ where: { name: 'Nylon Poha Chevdo' }, include: { customizationGroups: { include: { items: true } } } });
  console.log('SAMPLE:', JSON.stringify(sample, null, 1).slice(0, 800));
  await p.$disconnect();
})();
