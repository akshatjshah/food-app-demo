const { PrismaClient } = require('@prisma/client');
(async () => {
  const p = new PrismaClient();
  const foods = await p.foodItem.findMany({
    where: { deletedAt: null },
    select: { name: true, subcategory: true, category: { select: { name: true } } },
    orderBy: { name: 'asc' },
  });
  const byCat = {};
  for (const f of foods) {
    const c = f.category.name;
    byCat[c] = byCat[c] || [];
    byCat[c].push(f.name + ' [' + (f.subcategory || 'no-sub') + ']');
  }
  for (const [c, items] of Object.entries(byCat)) console.log(c + ' (' + items.length + '): ' + items.join(', '));
  await p.$disconnect();
})();
