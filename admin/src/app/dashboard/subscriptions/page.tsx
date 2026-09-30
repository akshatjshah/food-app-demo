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
import { Textarea } from "@/components/ui/textarea";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { ImageUpload } from "@/components/admin/image-upload";
import { formatCurrency } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Trash2 } from "lucide-react";

const EMPTY = {
  name: "", description: "", price: "", durationDays: "30", mealsCount: "30",
  mealType: "lunch", benefits: "", displayOrder: "0", imageUrl: "", isActive: true,
};

export default function SubscriptionsPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY);
  const qc = useQueryClient();

  const { data: plans = [], isLoading } = useQuery({
    queryKey: ["subscription-plans"],
    queryFn: async () => (await apiClient.get("/subscriptions/admin/all")).data?.data ?? [],
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["subscription-plans"] });
  const set = (k: keyof typeof EMPTY, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const save = useMutation({
    mutationFn: async () => {
      const payload = {
        name: form.name.trim(),
        description: form.description || undefined,
        price: Number(form.price),
        durationDays: Number(form.durationDays),
        mealsCount: Number(form.mealsCount),
        mealType: form.mealType,
        benefits: form.benefits ? form.benefits.split("\n").map((b) => b.trim()).filter(Boolean) : [],
        displayOrder: Number(form.displayOrder) || 0,
        imageUrl: form.imageUrl || undefined,
        isActive: form.isActive,
      };
      if (editing) await apiClient.patch(`/subscriptions/admin/${editing.id}`, payload);
      else await apiClient.post("/subscriptions/admin", payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Plan updated — subscription screen shows it" : "Plan created");
      setOpen(false);
      setEditing(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const toggle = useMutation({
    mutationFn: (p: any) => apiClient.patch(`/subscriptions/admin/${p.id}`, { isActive: !p.isActive }),
    onSuccess: () => {
      invalidate();
      toast.success("Plan visibility updated");
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => apiClient.delete(`/subscriptions/admin/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Plan deleted");
      setDeleteId(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Delete failed — deactivate while subscribers exist"),
  });

  const openEdit = (p: any) => {
    setEditing(p);
    setForm({
      name: p.name ?? "",
      description: p.description ?? "",
      price: String(p.price ?? ""),
      durationDays: String(p.durationDays ?? 30),
      mealsCount: String(p.mealsCount ?? 30),
      mealType: p.mealType ?? "lunch",
      benefits: Array.isArray(p.benefits) ? p.benefits.join("\n") : "",
      displayOrder: String(p.displayOrder ?? 0),
      imageUrl: p.imageUrl ?? "",
      isActive: !!p.isActive,
    });
    setOpen(true);
  };

  const num = (v: any) => Number(v ?? 0);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Subscription Plans"
        description="Customer subscription screens read these exact records. Editing never touches existing subscriber history."
        actions={
          <Button onClick={() => { setForm(EMPTY); setEditing(null); setOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Add Plan
          </Button>
        }
      />
      <Card>
        <CardContent className="pt-6">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Plan</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Duration</TableHead>
                  <TableHead>Meals</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Order</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead className="w-24" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(4)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(8)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : plans.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8}>
                      <EmptyState title="No plans" description="Create meal plans for the subscription screen." />
                    </TableCell>
                  </TableRow>
                ) : (
                  plans.map((p: any) => (
                    <TableRow key={p.id}>
                      <TableCell>
                        <p className="font-medium">{p.name}</p>
                        <p className="max-w-64 truncate text-xs text-muted-foreground">{p.description || "—"}</p>
                      </TableCell>
                      <TableCell>{formatCurrency(num(p.price))}</TableCell>
                      <TableCell>{p.durationDays} days</TableCell>
                      <TableCell>{p.mealsCount}</TableCell>
                      <TableCell className="text-sm">{p.mealType}</TableCell>
                      <TableCell>#{p.displayOrder ?? 0}</TableCell>
                      <TableCell>
                        <Switch checked={!!p.isActive} onCheckedChange={() => toggle.mutate(p)} />
                      </TableCell>
                      <TableCell>
                        <div className="flex gap-1">
                          <Button variant="ghost" size="icon" onClick={() => openEdit(p)}>
                            <Pencil className="h-4 w-4" />
                          </Button>
                          <Button variant="ghost" size="icon" onClick={() => setDeleteId(p.id)}>
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
            <DialogTitle>{editing ? "Edit Plan" : "Add Plan"}</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4 sm:grid-cols-2">
            <div className="space-y-2 sm:col-span-2">
              <Label>Plan name *</Label>
              <Input value={form.name} onChange={(e) => set("name", e.target.value)} />
            </div>
            <div className="space-y-2 sm:col-span-2">
              <Label>Description</Label>
              <Textarea value={form.description} onChange={(e) => set("description", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Price (₹) *</Label>
              <Input type="number" min="0" value={form.price} onChange={(e) => set("price", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Meal type</Label>
              <Input value={form.mealType} onChange={(e) => set("mealType", e.target.value)} placeholder="lunch / dinner" />
            </div>
            <div className="space-y-2">
              <Label>Duration (days)</Label>
              <Input type="number" min="1" value={form.durationDays} onChange={(e) => set("durationDays", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Meals included</Label>
              <Input type="number" min="1" value={form.mealsCount} onChange={(e) => set("mealsCount", e.target.value)} />
            </div>
            <div className="space-y-2 sm:col-span-2">
              <Label>Benefits (one per line)</Label>
              <Textarea value={form.benefits} onChange={(e) => set("benefits", e.target.value)} placeholder={"Free delivery\nPause anytime"} />
            </div>
            <div className="space-y-2">
              <Label>Sort order</Label>
              <Input type="number" value={form.displayOrder} onChange={(e) => set("displayOrder", e.target.value)} />
            </div>
            <div className="flex items-end gap-2 pb-1">
              <Switch checked={form.isActive} onCheckedChange={(v) => set("isActive", v)} />
              <Label>Active</Label>
            </div>
            <div className="sm:col-span-2">
              <ImageUpload label="Plan banner" value={form.imageUrl} onChange={(v) => set("imageUrl", v)} />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.name || !form.price}>
              {editing ? "Save" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Plan"
        message="Blocked while active subscribers exist — deactivate instead."
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && remove.mutate(deleteId)}
      />
    </div>
  );
}
