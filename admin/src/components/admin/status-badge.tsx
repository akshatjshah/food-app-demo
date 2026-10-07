"use client";

import { Badge } from "@/components/ui/badge";

const ORDER_COLORS: Record<string, string> = {
  pending_payment: "bg-yellow-100 text-yellow-800",
  placed: "bg-blue-100 text-blue-800",
  confirmed: "bg-yellow-100 text-yellow-800",
  preparing: "bg-purple-100 text-purple-800",
  // No Ready-for-Pickup step exists in the Parabdi workflow.
  // Legacy internal statuses drain to Out for Delivery — same orange.
  ready: "bg-orange-100 text-orange-800",
  rider_assigned: "bg-teal-100 text-teal-800",
  picked_up: "bg-teal-100 text-teal-800",
  out_for_delivery: "bg-orange-100 text-orange-800",
  delivered: "bg-green-100 text-green-800",
  cancelled: "bg-red-100 text-red-800",
  rejected: "bg-red-100 text-red-800",
};

// Filter list: single visible "Cancelled" covers both internal statuses
// (backend treats status=cancelled as IN [cancelled, rejected]).
// "ready" is NOT a Parabdi status and is excluded from the filter list.
export const ORDER_STATUSES = [
  "pending_payment",
  "placed",
  "confirmed",
  "preparing",
  "rider_assigned",
  "picked_up",
  "out_for_delivery",
  "delivered",
  "cancelled",
];

/// Display-only labels: backend/internal status stays "rejected",
/// but every user/admin-facing label shows "Cancelled". Legacy "ready"
/// (no pickup step exists) displays as "out for delivery".
export function displayOrderStatus(status: string): string {
  if (status === "rejected") return "cancelled";
  if (status === "ready") return "out_for_delivery";
  return status;
}

export function StatusBadge({ status }: { status: string }) {
  return (
    <Badge variant="secondary" className={ORDER_COLORS[status] || ""}>
      {displayOrderStatus(status)?.replace(/_/g, " ")}
    </Badge>
  );
}
