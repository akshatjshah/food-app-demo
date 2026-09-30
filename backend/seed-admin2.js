const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

async function main() {
  const prisma = new PrismaClient();
  const passwordHash = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@parabdi.com' },
    update: { role: 'admin', passwordHash },
    create: {
      id: crypto.randomUUID(),
      phoneNumber: '+919800000001',
      email: 'admin@parabdi.com',
      fullName: 'Admin',
      role: 'admin',
      passwordHash,
    },
  });
  console.log('Admin user ready:', admin.email);
  await prisma.$disconnect();
}

main().catch((e) => { console.error(e); process.exit(1); });
