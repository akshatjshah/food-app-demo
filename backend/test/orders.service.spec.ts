import { Test, TestingModule } from '@nestjs/testing';
import { OrdersService } from '../src/modules/orders/orders.service';
import { PrismaService } from '../src/config/prisma.service';
import { NotificationsService } from '../src/modules/notifications/notifications.service';

describe('OrdersService', () => {
  let service: OrdersService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      order: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        count: jest.fn(),
      },
      cart: {
        findUnique: jest.fn(),
        delete: jest.fn(),
      },
      address: {
        findUnique: jest.fn(),
      },
      foodItem: {
        findMany: jest.fn(),
      },
      $transaction: jest.fn((fns: any[]) => Promise.all(fns)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrdersService,
        { provide: PrismaService, useValue: prisma },
        {
          provide: NotificationsService,
          useValue: { sendOrderStatusUpdate: jest.fn() },
        },
      ],
    }).compile();

    service = module.get<OrdersService>(OrdersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return orders for user', async () => {
      prisma.order.findMany.mockResolvedValue([
        { id: '1', orderNumber: 1001, status: 'placed', grandTotal: 320 },
      ]);

      const result = await service.findAll('user1', {});
      expect(Array.isArray(result)).toBe(true);
    });
  });
});
