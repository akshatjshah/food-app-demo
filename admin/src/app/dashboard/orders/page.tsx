"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { Pagination } from "@/components/admin/pagination";
import { StatusBadge, ORDER_STATUSES } from "@/components/admin/status-badge";
import { formatCurrency, formatDateTime } from "@/lib/utils";
import { toast } from "sonner";
import { Search, Eye } from "lucide-react";

const NEXT_STATUS: Record<string, string[]> = {
  pending_payment: ["placed", "cancelled"],
  placed: ["confirmed", "cancelled", "rejected"],
  confirmed: ["preparing", "cancelled", "rejected"],
  preparing: ["ready", "cancelled", "rejected"],
  ready: ["rider_assigned", "cancelled", "rejected"],
  rider_assigned: ["picked_up", "cancelled"],
  picked_up: ["out_for_delivery"],
  out_for_delivery: ["delivered", "cancelled"],
  delivered: [],
  cancelled: [],
  rejected: [],
};

export default function OrdersPage() {
  const [status, setStatus] = useState("all");
  const [paymentStatus, setPaymentStatus] = useState("all");
  const [search, setSearch] = useState("");
  const [appliedSearch, setAppliedSearch] = useState("");
  const [page, setPage] = useState(0);
  const [detailId, setDetailId] = useState<string | null>(null);
  const [newStatus, setNewStatus] = useState("");
  const pageSize = 15;
  const qc = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ["admin-orders", status, paymentStatus, appliedSearch, page],
    queryFn: async () => {
      const params = new URLSearchParams({
        skip: String(page * pageSize),
        take: String(pageSize),
      });
      if (status !== "all") params.set("status", status);
      if (paymentStatus !== "all") params.set("paymentStatus", paymentStatus);
      if (appliedSearch) params.set("search", appliedSearch);
      const res = await apiClient.get(`/admin/orders?${params.toString()}`);
      return res.data?.data ?? { data: [], total: 0 };
    },
  });
  const orders = data?.data ?? [];
  const total = data?.total ?? 0;

  const { data: detail, isLoading: detailLoading } = useQuery({
    queryKey: ["admin-order-detail", detailId],
    queryFn: async () => (await apiClient.get(`/admin/orders/${detailId}`)).data?.data,
    enabled: !!detailId,
  });

  const updateStatus = useMutation({
    mutationFn: async () => apiClient.patch(`/admin/orders/${detailId}/status`, { status: newStatus }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["admin-orders"] });
      qc.invalidateQueries({ queryKey: ["admin-order-detail", detailId] });
      toast.success(`Order moved to ${newStatus.replace(/_/g, " ")}`);
      setNewStatus("");
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Status update failed"),
  });

  const allowed = detail ? NEXT_STATUS[detail.status] ?? [] : [];

  return (
    <div className="space-y-6">
      <PageHeader title="Orders" description="Live customer orders — inspect, assign and advance through valid statuses." />

      <Card>
        <CardContent className="pt-6">
          <div className="mb-4 flex flex-col gap-3 lg:flex-row">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Search order ID, customer name… (Enter)"
                className="pl-9"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    setAppliedSearch(search);
                    setPage(0);
                  }
                }}
              />
            </div>
            <Select value={status} onValueChange={(v) => { setStatus(v); setPage(0); }}>
              <SelectTrigger className="w-full lg:w-52">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All statuses</SelectItem>
                {ORDER_STATUSES.map((s) => (
                  <SelectItem key={s} value={s}>{s.replace(/_/g, " ")}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select value={paymentStatus} onValueChange={(v) => { setPaymentStatus(v); setPage(0); }}>
              <SelectTrigger className="w-full lg:w-52">
                <SelectValue placeholder="Payment" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All payments</SelectItem>
                {["pending", "paid", "failed", "refunded"].map((s) => (
                  <SelectItem key={s} value={s}>{s}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Order</TableHead>
                  <TableHead>Customer</TableHead>
                  <TableHead>Items</TableHead>
                  <TableHead>Total</TableHead>
                  <TableHead>Payment</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="w-16" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(6)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(7)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : orders.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7}>
                      <EmptyState title="No orders" description="Customer orders will appear here in real time." />
                    </TableCell>
                  </TableRow>
                ) : (
                  orders.map((o: any) => (
                    <TableRow key={o.id}>
                      <TableCell>
                        <div className="font-mono text-xs">{o.id.slice(0, 8).toUpperCase()}</div>
                        <div className="text-xs text-muted-foreground">{formatDateTime(o.createdAt)}</div>
                      </TableCell>
                      <TableCell>{o.user?.fullName || o.user?.phoneNumber || "—"}</TableCell>
                      <TableCell>{o.items?.length ?? 0}</TableCell>
                      <TableCell>{formatCurrency(Number(o.grandTotal))}</TableCell>
                      <TableCell>
                        <span className="text-xs">{o.paymentMethod} · {o.paymentStatus}</span>
                      </TableCell>
                      <TableCell>
                        <StatusBadge status={o.status} />
                      </TableCell>
                      <TableCell>
                        <Button variant="ghost" size="icon" onClick={() => { setDetailId(o.id); setNewStatus(""); }}>
                          <Eye className="h-4 w-4" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
          <Pagination page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
        </CardContent>
      </Card>

      <Dialog open={!!detailId} onOpenChange={(v) => !v && setDetailId(null)}>
        <DialogContent className="max-h-[90vh] max-w-3xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Order {detail?.id?.slice(0, 8).toUpperCase()}</DialogTitle>
          </DialogHeader>
          {detailLoading ? (
            <div className="h-40 animate-pulse rounded bg-muted" />
          ) : detail ? (
            <div className="space-y-6 py-2">
              <div className="flex flex-wrap items-center gap-3">
                <StatusBadge status={detail.status} />
                <span className="text-sm text-muted-foreground">
                  {detail.paymentMethod} · {detail.paymentStatus} · slot: {detail.deliverySlot}
                </span>
              </div>

              <div>
                <h4 className="mb-2 text-sm font-semibold">Items</h4>
                <div className="divide-y rounded-md border">
                  {detail.items?.map((it: any) => (
                    <div key={it.id} className="flex items-center justify-between px-4 py-2">
                      <div>
                        <p className="text-sm font-medium">{it.foodItem?.name} × {it.quantity}</p>
                        {it.customizations?.length > 0 && (
                          <p className="text-xs text-muted-foreground">
                            {it.customizations.map((c: any) => c.name).join(", ")}
                          </p>
                        )}
                      </div>
                      <span className="text-sm">{formatCurrency(Number(it.unitPrice) * it.quantity)}</span>
                    </div>
                  ))}
                </div>
                <div className="mt-2 space-y-1 text-sm">
                  <div className="flex justify-between text-muted-foreground"><span>Items</span><span>{formatCurrency(Number(detail.itemTotal))}</span></div>
                  <div className="flex justify-between text-muted-foreground"><span>Tax</span><span>{formatCurrency(Number(detail.taxAmount))}</span></div>
                  <div className="flex justify-between text-muted-foreground"><span>Delivery</span><span>{formatCurrency(Number(detail.deliveryFee))}</span></div>
                  <div className="flex justify-between text-muted-foreground"><span>Platform</span><span>{formatCurrency(Number(detail.platformFee))}</span></div>
                  {Number(detail.discountAmount) > 0 && (
                    <div className="flex justify-between text-green-600"><span>Discount {detail.couponUsages?.[0]?.coupon?.code ? `(${detail.couponUsages[0].coupon.code})` : ""}</span><span>−{formatCurrency(Number(detail.discountAmount))}</span></div>
                  )}
                  <div className="flex justify-between font-bold"><span>Total</span><span>{formatCurrency(Number(detail.grandTotal))}</span></div>
                </div>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <h4 className="mb-1 text-sm font-semibold">Customer</h4>
                  <p className="text-sm">{detail.user?.fullName || "—"}</p>
                  <p className="text-sm text-muted-foreground">{detail.user?.phoneNumber}</p>
                  {detail.address && (
                    <p className="mt-1 text-xs text-muted-foreground">
                      {detail.address.addressLine1}, {detail.address.city} {detail.address.postalCode}
                    </p>
                  )}
                </div>
                <div>
                  <h4 className="mb-1 text-sm font-semibold">Assignment</h4>
                  <p className="text-sm">Chef: {detail.chef?.fullName || "—"}</p>
                  <p className="text-sm">Rider: {detail.deliveryBoy?.fullName || "—"}</p>
                  {detail.specialInstructions && (
                    <p className="mt-1 text-xs text-muted-foreground">Note: {detail.specialInstructions}</p>
                  )}
                </div>
              </div>

              <div>
                <h4 className="mb-2 text-sm font-semibold">Timeline</h4>
                <div className="space-y-1">
                  {(detail.statusHistory?.length ?? 0) === 0 && (
                    <p className="text-xs text-muted-foreground">Placed · {formatDateTime(detail.createdAt)}</p>
                  )}
                  {detail.statusHistory?.map((h: any) => (
                    <p key={h.id} className="text-xs text-muted-foreground">
                      {h.fromStatus || "—"} → <span className="font-medium text-foreground">{h.toStatus}</span> · {formatDateTime(h.createdAt)}
                    </p>
                  ))}
                </div>
              </div>

              <div className="space-y-2 rounded-md border p-4">
                <Label>Advance status {allowed.length === 0 && "(terminal — no further moves)"}</Label>
                <div className="flex gap-2">
                  <Select value={newStatus} onValueChange={setNewStatus}>
                    <SelectTrigger className="flex-1">
                      <SelectValue placeholder={allowed.length ? "Select next status" : "No transitions available"} />
                    </SelectTrigger>
                    <SelectContent>
                      {allowed.map((s) => (
                        <SelectItem key={s} value={s}>{s.replace(/_/g, " ")}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <Button onClick={() => updateStatus.mutate()} disabled={!newStatus || updateStatus.isPending}>
                    Update
                  </Button>
                </div>
                <p className="text-xs text-muted-foreground">Only valid transitions are offered — the customer tracking screen reflects the change.</p>
              </div>
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">Order not found.</p>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setDetailId(null)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
