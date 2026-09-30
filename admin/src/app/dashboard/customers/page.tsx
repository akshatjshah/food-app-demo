"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { Pagination } from "@/components/admin/pagination";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { StatusBadge } from "@/components/admin/status-badge";
import { formatCurrency, formatDate, formatDateTime } from "@/lib/utils";
import { toast } from "sonner";
import { Search, Ban, CheckCircle, Eye } from "lucide-react";

export default function CustomersPage() {
  const [search, setSearch] = useState("");
  const [applied, setApplied] = useState("");
  const [page, setPage] = useState(0);
  const [detailId, setDetailId] = useState<string | null>(null);
  const [blockTarget, setBlockTarget] = useState<any>(null);
  const pageSize = 15;
  const qc = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ["customers", applied, page],
    queryFn: async () => {
      const params = new URLSearchParams({ skip: String(page * pageSize), take: String(pageSize) });
      if (applied) params.set("search", applied);
      const res = await apiClient.get(`/admin/customers?${params.toString()}`);
      return res.data?.data ?? { data: [], total: 0 };
    },
  });
  const customers = data?.data ?? [];
  const total = data?.total ?? 0;

  const { data: detail } = useQuery({
    queryKey: ["customer-detail", detailId],
    queryFn: async () => (await apiClient.get(`/admin/customers/${detailId}`)).data?.data,
    enabled: !!detailId,
  });

  const blockMutation = useMutation({
    mutationFn: async (c: any) =>
      apiClient.patch(`/admin/customers/${c.id}/block`, { isBlocked: !c.isBlocked }),
    onSuccess: (_, c: any) => {
      qc.invalidateQueries({ queryKey: ["customers"] });
      qc.invalidateQueries({ queryKey: ["customer-detail", c.id] });
      toast.success(c.isBlocked ? "Customer unblocked" : "Customer blocked — backend rejects their auth");
      setBlockTarget(null);
    },
    onError: () => toast.error("Failed to update customer status"),
  });

  return (
    <div className="space-y-6">
      <PageHeader title="Customers" description="Canonical user source — same records the customer app authenticates with." />

      <Card>
        <CardContent className="pt-6">
          <div className="relative mb-4 max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Search name, phone, email… (Enter)"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && (setApplied(search), setPage(0))}
              className="pl-9"
            />
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Orders</TableHead>
                  <TableHead>Total spend</TableHead>
                  <TableHead>Wallet</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="w-24" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(5)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(8)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : customers.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8}>
                      <EmptyState title="No customers" description="Customers appear after they sign in on the app." />
                    </TableCell>
                  </TableRow>
                ) : (
                  customers.map((c: any) => (
                    <TableRow key={c.id}>
                      <TableCell className="font-medium">{c.fullName || "—"}</TableCell>
                      <TableCell>{c.phoneNumber}</TableCell>
                      <TableCell>{c.orderCount ?? 0}</TableCell>
                      <TableCell>{formatCurrency(c.totalSpend ?? 0)}</TableCell>
                      <TableCell>{formatCurrency(c.walletBalance ?? 0)}</TableCell>
                      <TableCell className="text-sm text-muted-foreground">{formatDate(c.createdAt)}</TableCell>
                      <TableCell>
                        <Badge variant={c.isBlocked ? "destructive" : "default"}>
                          {c.isBlocked ? "Blocked" : "Active"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex gap-1">
                          <Button variant="ghost" size="icon" onClick={() => setDetailId(c.id)}>
                            <Eye className="h-4 w-4" />
                          </Button>
                          <Button variant="ghost" size="icon" onClick={() => setBlockTarget(c)}>
                            {c.isBlocked ? (
                              <CheckCircle className="h-4 w-4 text-green-600" />
                            ) : (
                              <Ban className="h-4 w-4 text-destructive" />
                            )}
                          </Button>
                        </div>
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
        <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{detail?.fullName || detail?.phoneNumber || "Customer"}</DialogTitle>
          </DialogHeader>
          {detail ? (
            <div className="space-y-5 py-2">
              <div className="grid grid-cols-2 gap-4 text-sm sm:grid-cols-4">
                <div><p className="text-muted-foreground">Phone</p><p className="font-medium">{detail.phoneNumber}</p></div>
                <div><p className="text-muted-foreground">Orders</p><p className="font-medium">{detail._count?.orders ?? detail.orders?.length ?? 0}</p></div>
                <div><p className="text-muted-foreground">Spend</p><p className="font-medium">{formatCurrency(detail.totalSpend ?? 0)}</p></div>
                <div><p className="text-muted-foreground">Wallet</p><p className="font-medium">{formatCurrency(detail.walletBalance ?? 0)}</p></div>
              </div>
              <div>
                <h4 className="mb-2 text-sm font-semibold">Addresses ({detail.addresses?.length ?? 0})</h4>
                {(detail.addresses?.length ?? 0) === 0 ? (
                  <p className="text-sm text-muted-foreground">No saved addresses.</p>
                ) : (
                  detail.addresses.map((a: any) => (
                    <p key={a.id} className="text-xs text-muted-foreground">
                      {a.label}: {a.addressLine1}, {a.city} {a.postalCode}
                    </p>
                  ))
                )}
              </div>
              <div>
                <h4 className="mb-2 text-sm font-semibold">Subscriptions ({detail.subscriptions?.length ?? 0})</h4>
                {(detail.subscriptions?.length ?? 0) === 0 ? (
                  <p className="text-sm text-muted-foreground">No subscriptions.</p>
                ) : (
                  detail.subscriptions.map((s: any) => (
                    <p key={s.id} className="text-xs text-muted-foreground">
                      {s.subscription?.name} · {s.status} · meals left {s.mealsRemaining}
                    </p>
                  ))
                )}
              </div>
              <div>
                <h4 className="mb-2 text-sm font-semibold">Recent orders</h4>
                {(detail.orders?.length ?? 0) === 0 ? (
                  <p className="text-sm text-muted-foreground">No orders yet.</p>
                ) : (
                  <div className="space-y-1">
                    {detail.orders.map((o: any) => (
                      <div key={o.id} className="flex items-center justify-between text-sm">
                        <span className="font-mono text-xs">{o.id.slice(0, 8).toUpperCase()} · {formatDateTime(o.createdAt)}</span>
                        <span className="flex items-center gap-2">
                          {formatCurrency(Number(o.grandTotal))} <StatusBadge status={o.status} />
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          ) : (
            <div className="h-32 animate-pulse rounded bg-muted" />
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setDetailId(null)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!blockTarget}
        title={blockTarget?.isBlocked ? "Unblock customer?" : "Block customer?"}
        message={
          blockTarget?.isBlocked
            ? "They will be able to sign in and order again."
            : "Blocked accounts are rejected server-side on every authenticated request."
        }
        confirmLabel={blockTarget?.isBlocked ? "Unblock" : "Block"}
        danger={!blockTarget?.isBlocked}
        loading={blockMutation.isPending}
        onCancel={() => setBlockTarget(null)}
        onConfirm={() => blockTarget && blockMutation.mutate(blockTarget)}
      />
    </div>
  );
}
