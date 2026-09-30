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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { formatCurrency, formatDate } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Trash2 } from "lucide-react";

const EMPTY = {
  code: "", description: "", discountType: "percentage", discountValue: "",
  minOrderValue: "", maxDiscountValue: "", maxUses: "", maxUsesPerUser: "1",
  isFirstOrderOnly: false, expiresAt: "", isActive: true,
};

export default function CouponsPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY);
  const qc = useQueryClient();

  const { data: coupons = [], isLoading } = useQuery({
    queryKey: ["coupons"],
    queryFn: async () => (await apiClient.get("/coupons")).data?.data ?? [],
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["coupons"] });
  const set = (k: keyof typeof EMPTY, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const save = useMutation({
    mutationFn: async () => {
      const num = (v: string) => (v === "" ? undefined : Number(v));
      const payload = {
        code: form.code.trim().toUpperCase(),
        description: form.description || undefined,
        discountType: form.discountType,
        discountValue: Number(form.discountValue),
        minOrderValue: num(form.minOrderValue),
        maxDiscountValue: num(form.maxDiscountValue),
        maxUses: num(form.maxUses),
        maxUsesPerUser: num(form.maxUsesPerUser),
        isFirstOrderOnly: form.isFirstOrderOnly,
        expiresAt: form.expiresAt ? new Date(form.expiresAt).toISOString() : undefined,
        isActive: form.isActive,
      };
      if (editing) await apiClient.patch(`/coupons/${editing.id}`, payload);
      else await apiClient.post("/coupons", payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Coupon updated" : "Coupon created — customers can validate it at checkout");
      setOpen(false);
      setEditing(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const toggle = useMutation({
    mutationFn: (c: any) => apiClient.patch(`/coupons/${c.id}`, { isActive: !c.isActive }),
    onSuccess: () => {
      invalidate();
      toast.success("Coupon status updated");
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => apiClient.delete(`/coupons/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Coupon deleted");
      setDeleteId(null);
    },
    onError: () => toast.error("Delete failed"),
  });

  const openEdit = (c: any) => {
    setEditing(c);
    setForm({
      code: c.code ?? "",
      description: c.description ?? "",
      discountType: c.discountType ?? "percentage",
      discountValue: String(c.discountValue ?? ""),
      minOrderValue: c.minOrderValue != null ? String(c.minOrderValue) : "",
      maxDiscountValue: c.maxDiscountValue != null ? String(c.maxDiscountValue) : "",
      maxUses: c.maxUses != null ? String(c.maxUses) : "",
      maxUsesPerUser: c.maxUsesPerUser != null ? String(c.maxUsesPerUser) : "1",
      isFirstOrderOnly: !!c.isFirstOrderOnly,
      expiresAt: c.expiresAt ? new Date(c.expiresAt).toISOString().slice(0, 10) : "",
      isActive: !!c.isActive,
    });
    setOpen(true);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Coupons"
        description="Discounts are validated server-side at order time — the app never decides the amount."
        actions={
          <Button onClick={() => { setForm(EMPTY); setEditing(null); setOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Create Coupon
          </Button>
        }
      />
      <Card>
        <CardContent className="pt-6">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Code</TableHead>
                  <TableHead>Discount</TableHead>
                  <TableHead>Min order</TableHead>
                  <TableHead>Usage</TableHead>
                  <TableHead>Expiry</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead className="w-24" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(4)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(7)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : coupons.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7}>
                      <EmptyState title="No coupons" description="Create a code customers can apply at checkout." />
                    </TableCell>
                  </TableRow>
                ) : (
                  coupons.map((c: any) => (
                    <TableRow key={c.id}>
                      <TableCell>
                        <span className="font-mono font-bold">{c.code}</span>
                        {c.isFirstOrderOnly && <Badge variant="outline" className="ml-2">1st order</Badge>}
                      </TableCell>
                      <TableCell>
                        {c.discountType === "percentage" ? `${c.discountValue}%` : formatCurrency(Number(c.discountValue))}
                        {c.maxDiscountValue && <span className="text-xs text-muted-foreground"> (cap {formatCurrency(Number(c.maxDiscountValue))})</span>}
                      </TableCell>
                      <TableCell>{c.minOrderValue ? formatCurrency(Number(c.minOrderValue)) : "—"}</TableCell>
                      <TableCell className="text-sm">{c.currentUses ?? 0}{c.maxUses ? ` / ${c.maxUses}` : ""}</TableCell>
                      <TableCell className="text-sm text-muted-foreground">{c.expiresAt ? formatDate(c.expiresAt) : "—"}</TableCell>
                      <TableCell>
                        <Switch checked={!!c.isActive} onCheckedChange={() => toggle.mutate(c)} />
                      </TableCell>
                      <TableCell>
                        <div className="flex gap-1">
                          <Button variant="ghost" size="icon" onClick={() => openEdit(c)}>
                            <Pencil className="h-4 w-4" />
                          </Button>
                          <Button variant="ghost" size="icon" onClick={() => setDeleteId(c.id)}>
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-h-[90vh] max-w-lg overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editing ? "Edit Coupon" : "Create Coupon"}</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label>Code *</Label>
              <Input value={form.code} onChange={(e) => set("code", e.target.value.toUpperCase())} placeholder="WELCOME20" disabled={!!editing} />
            </div>
            <div className="space-y-2">
              <Label>Type</Label>
              <Select value={form.discountType} onValueChange={(v) => set("discountType", v)}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="percentage">Percentage %</SelectItem>
                  <SelectItem value="flat">Flat ₹</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Value *</Label>
              <Input type="number" min="0" value={form.discountValue} onChange={(e) => set("discountValue", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Expiry</Label>
              <Input type="date" value={form.expiresAt} onChange={(e) => set("expiresAt", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Min order (₹)</Label>
              <Input type="number" min="0" value={form.minOrderValue} onChange={(e) => set("minOrderValue", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Max discount (₹)</Label>
              <Input type="number" min="0" value={form.maxDiscountValue} onChange={(e) => set("maxDiscountValue", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Total use limit</Label>
              <Input type="number" min="1" value={form.maxUses} onChange={(e) => set("maxUses", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Per-user limit</Label>
              <Input type="number" min="1" value={form.maxUsesPerUser} onChange={(e) => set("maxUsesPerUser", e.target.value)} />
            </div>
            <div className="space-y-2 sm:col-span-2">
              <Label>Description</Label>
              <Input value={form.description} onChange={(e) => set("description", e.target.value)} />
            </div>
            <div className="flex items-center gap-2">
              <Switch checked={form.isFirstOrderOnly} onCheckedChange={(v) => set("isFirstOrderOnly", v)} />
              <Label>First order only</Label>
            </div>
            <div className="flex items-center gap-2">
              <Switch checked={form.isActive} onCheckedChange={(v) => set("isActive", v)} />
              <Label>Active</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.code || !form.discountValue}>
              {editing ? "Save" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Coupon"
        message="Past usages stay recorded on their orders; future checkouts will reject the code."
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && remove.mutate(deleteId)}
      />
    </div>
  );
}
