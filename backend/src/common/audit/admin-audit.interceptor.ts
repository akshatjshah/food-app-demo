import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { PrismaService } from '../../config/prisma.service';

const SENSITIVE_KEYS = ['password', 'otp', 'token', 'secret', 'hash', 'pin'];

/** Redacts secrets before persisting audit payloads. */
function sanitize(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sanitize);
  if (value && typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      out[k] = SENSITIVE_KEYS.some((s) => k.toLowerCase().includes(s)) ? '[REDACTED]' : sanitize(v);
    }
    return out;
  }
  return value;
}

/**
 * Records every successful admin POST/PATCH/PUT/DELETE into admin_audit_logs.
 * Read-only GETs and non-admin roles are ignored.
 */
@Injectable()
export class AdminAuditInterceptor implements NestInterceptor {
  constructor(private prisma: PrismaService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest();
    const method: string = req.method;
    const user = req.user;

    return next.handle().pipe(
      tap({
        next: () => {
          if (!user || user.role !== 'admin') return;
          if (!['POST', 'PATCH', 'PUT', 'DELETE'].includes(method)) return;
          // Skip auth/session noise and the audit log itself.
          if (req.path?.includes('/auth/') || req.path?.includes('/audit-logs')) return;

          const segments = (req.path || '').split('/').filter(Boolean);
          // path like api/v1/foods/:id -> entity foods
          const entity = segments.length >= 3 ? segments[2] : segments[segments.length - 1] || 'unknown';
          const entityId =
            req.params?.id || req.params?.orderId || req.params?.groupId || req.params?.itemId || undefined;

          this.prisma.adminAuditLog
            .create({
              data: {
                adminId: user.id,
                action: `${method.toLowerCase()}`,
                entity,
                entityId,
                newValue: sanitize(req.body ?? {}) as any,
                ipAddress: req.ip,
              },
            })
            .catch(() => {
              /* audit must never break the request */
            });
        },
      }),
    );
  }
}
