const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

async function main() {
  const prisma = new PrismaClient();
  const passwordHash = await bcrypt.hash('admin123', 10);

  const existingByEmail = await prisma.user.findUnique({
    where: { email: 'admin@parabdi.com' },
  });
  if (existingByEmail) {
    await prisma.user.update({
      where: { email: 'admin@parabdi.com' },
      data: { role: 'admin', passwordHash },
    });
    console.log('Admin user updated:', existingByEmail.email);
    await prisma.$disconnect();
    return;
  }

  const phoneTaken = await prisma.user.findUnique({
    where: { phoneNumber: '+919999999999' },
  });

  const admin = await prisma.user.create({
    data: {
      id: crypto.randomUUID(),
      phoneNumber: phoneTaken ? '+919800000001' : '+919999999999',
      email: 'admin@parabdi.com',
      fullName: 'Admin',
      role: 'admin',
      passwordHash: passwordHash,
    },
  });

  console.log('Admin user created:', admin.email);
  await prisma.$disconnect();
}

main().catch((e) => { console.error(e); process.exit(1); });
