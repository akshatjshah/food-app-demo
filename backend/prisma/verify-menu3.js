const { PrismaClient } = require('@prisma/client');
(async () => {
  const p = new PrismaClient();
  const f = await p.foodItem.findFirst({ where: { name: 'buttermilk' } });
  console.log('ITEM:', f.name, '| price:', String(f.price), '| active:', f.isActive, '| rating:', String(f.rating), '| reviews:', f.reviewsCount, '| created:', f.createdAt);
  const oi = await p.orderItem.count({ where: { foodItemId: f.id } });
  const ci = await p.cartItem.count({ where: { foodItemId: f.id } });
  const rev = await p.review.count({ where: { foodItemId: f.id } });
  const wish = await p.wishlist.count({ where: { foodItemId: f.id } });
  console.log('orderItems:', oi, 'cartItems:', ci, 'reviews:', rev, 'wishlist:', wish);
  const breadFoods = await p.foodItem.count({ where: { category: { name: 'bread' }, deletedAt: null } });
  console.log('bread active foods:', breadFoods);
  await p.$disconnect();
})();
