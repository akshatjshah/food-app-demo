import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class DeliverySlotsService {
  constructor(private prisma: PrismaService) {}

  async findActive() {
    return this.prisma.deliverySlot.findMany({
      where: { isActive: true },
      orderBy: { displayOrder: 'asc' },
    });
  }

  async findAllAdmin() {
    return this.prisma.deliverySlot.findMany({ orderBy: { displayOrder: 'asc' } });
  }

  async create(data: any) {
    return this.prisma.deliverySlot.create({ data });
  }

  async update(id: string, data: any) {
    return this.prisma.deliverySlot.update({ where: { id }, data });
  }

  async remove(id: string) {
    return this.prisma.deliverySlot.delete({ where: { id } });
  }
}
