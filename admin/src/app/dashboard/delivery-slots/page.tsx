"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { toast } from "sonner";
import { Plus, Pencil, Trash2 } from "lucide-react";

const EMPTY = { name: "", startTime: "", endTime: "", maxOrders: "10", displayOrder: "0", isActive: true };

export default function DeliverySlotsPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY);
  const qc = useQueryClient();

  const { data: slots = [], isLoading } = useQuery({
    queryKey: ["delivery-slots"],
    queryFn: async () => (await apiClient.get("/delivery-slots/admin/all")).data?.data ?? [],
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["delivery-slots"] });
  const set = (k: keyof typeof EMPTY, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const save = useMutation({
    mutationFn: async () => {
      const payload = {
        name: form.name.trim(),
        startTime: form.startTime,
        endTime: form.endTime,
        maxOrders: Number(form.maxOrders) || 10,
        displayOrder: Number(form.displayOrder) || 0,
        isActive: form.isActive,
      };
      if (editing) await apiClient.patch(`/delivery-slots/${editing.id}`, payload);
      else await apiClient.post("/delivery-slots", payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Slot updated — checkout reflects it" : "Slot created — checkout shows it");
      setOpen(false);
      setEditing(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const toggle = useMutation({
    mutationFn: (s: any) => apiClient.patch(`/delivery-slots/${s.id}`, { isActive: !s.isActive }),
    onSuccess: () => {
      invalidate();
      toast.success("Slot visibility updated");
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => apiClient.delete(`/delivery-slots/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Slot deleted");
      setDeleteId(null);
    },
    onError: () => toast.error("Delete failed"),
  });

  const openEdit = (s: any) => {
    setEditing(s);
    setForm({
      name: s.name ?? "",
      startTime: s.startTime ?? "",
      endTime: s.endTime ?? "",
      maxOrders: String(s.maxOrders ?? 10),
      displayOrder: String(s.displayOrder ?? 0),
      isActive: !!s.isActive,
    });
    setOpen(true);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Delivery Slots"
        description="Checkout lists active slots in this order. Disabling hides them from customers."
        actions={
          <Button onClick={() => { setForm(EMPTY); setEditing(null); setOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Add Slot
          </Button>
        }
      />
      <Card>
        <CardContent className="pt-6">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Label</TableHead>
                  <TableHead>Window</TableHead>
                  <TableHead>Capacity</TableHead>
                  <TableHead>Order</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead className="w-24" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(4)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(6)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : slots.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6}>
                      <EmptyState title="No slots" description="Create delivery windows for checkout." />
                    </TableCell>
                  </TableRow>
                ) : (
                  slots.map((s: any) => (
                    <TableRow key={s.id}>
                      <TableCell className="font-medium">{s.name}</TableCell>
                      <TableCell>{s.startTime} – {s.endTime}</TableCell>
                      <TableCell>{s.maxOrders}</TableCell>
                      <TableCell>#{s.displayOrder ?? 0}</TableCell>
                      <TableCell>
                        <Switch checked={!!s.isActive} onCheckedChange={() => toggle.mutate(s)} />
                      </TableCell>
                      <TableCell>
                        <div className="flex gap-1">
                          <Button variant="ghost" size="icon" onClick={() => openEdit(s)}>
                            <Pencil className="h-4 w-4" />
                          </Button>
                          <Button variant="ghost" size="icon" onClick={() => setDeleteId(s.id)}>
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
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{editing ? "Edit Slot" : "Add Slot"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Label *</Label>
              <Input value={form.name} onChange={(e) => set("name", e.target.value)} placeholder="Lunch (12:00 - 14:00)" />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Start (HH:MM) *</Label>
                <Input value={form.startTime} onChange={(e) => set("startTime", e.target.value)} placeholder="12:00" />
              </div>
              <div className="space-y-2">
                <Label>End (HH:MM) *</Label>
                <Input value={form.endTime} onChange={(e) => set("endTime", e.target.value)} placeholder="14:00" />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Capacity</Label>
                <Input type="number" min="1" value={form.maxOrders} onChange={(e) => set("maxOrders", e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Order</Label>
                <Input type="number" value={form.displayOrder} onChange={(e) => set("displayOrder", e.target.value)} />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Switch checked={form.isActive} onCheckedChange={(v) => set("isActive", v)} />
              <Label>Active</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.name || !form.startTime || !form.endTime}>
              {editing ? "Save" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Slot"
        message="Existing orders keep their slot label as text; only future checkout is affected."
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && remove.mutate(deleteId)}
      />
    </div>
  );
}
