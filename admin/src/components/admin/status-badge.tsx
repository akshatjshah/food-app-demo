"use client";

import { Badge } from "@/components/ui/badge";

const ORDER_COLORS: Record<string, string> = {
  pending_payment: "bg-yellow-100 text-yellow-800",
  placed: "bg-blue-100 text-blue-800",
  confirmed: "bg-indigo-100 text-indigo-800",
  preparing: "bg-purple-100 text-purple-800",
  ready: "bg-cyan-100 text-cyan-800",
  rider_assigned: "bg-teal-100 text-teal-800",
  picked_up: "bg-teal-100 text-teal-800",
  out_for_delivery: "bg-orange-100 text-orange-800",
  delivered: "bg-green-100 text-green-800",
  cancelled: "bg-red-100 text-red-800",
  rejected: "bg-red-100 text-red-800",
};

export const ORDER_STATUSES = [
  "pending_payment",
  "placed",
  "confirmed",
  "preparing",
  "ready",
  "rider_assigned",
  "picked_up",
  "out_for_delivery",
  "delivered",
  "cancelled",
  "rejected",
];

export function StatusBadge({ status }: { status: string }) {
  return (
    <Badge variant="secondary" className={ORDER_COLORS[status] || ""}>
      {status?.replace(/_/g, " ")}
    </Badge>
  );
}
