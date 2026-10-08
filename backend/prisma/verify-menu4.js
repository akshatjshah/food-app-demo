const { PrismaClient } = require('@prisma/client');
(async () => {
  const p = new PrismaClient();
  // Archive leftover non-master item (soft-delete keeps order_items intact)
  await p.foodItem.updateMany({ where: { name: 'buttermilk' }, data: { isActive: false, isAvailable: false, deletedAt: new Date() } });
  console.log('archived buttermilk');
  for (const n of ['bread', 'Beverages']) {
    const remaining = await p.foodItem.count({ where: { category: { name: n }, deletedAt: null } });
    if (remaining === 0) {
      await p.category.updateMany({ where: { name: n }, data: { isActive: false } });
      console.log('deactivated category', n);
    } else console.log('kept category', n, 'with', remaining);
  }
  const groups = await p.customizationGroup.findMany({ select: { name: true, foodItem: { select: { name: true } } } });
  console.log('ALL_GROUPS:', groups.map((g) => g.foodItem.name + ' :: ' + g.name).join(' | '));
  await p.$disconnect();
})();
