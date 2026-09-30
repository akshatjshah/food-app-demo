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
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { ImageUpload, resolveImageUrl } from "@/components/admin/image-upload";
import { formatDate } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Trash2 } from "lucide-react";

const EMPTY = {
  title: "", subtitle: "", imageUrl: "", clickAction: "", actionValue: "",
  displayOrder: "0", startDate: "", endDate: "", isActive: true,
};

const toLocalInput = (iso?: string) => {
  if (!iso) return "";
  const d = new Date(iso);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
};

export default function BannersPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY);
  const qc = useQueryClient();

  const { data: banners = [], isLoading } = useQuery({
    queryKey: ["banners"],
    queryFn: async () => (await apiClient.get("/banners/admin")).data?.data ?? [],
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["banners"] });
  const set = (k: keyof typeof EMPTY, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const save = useMutation({
    mutationFn: async () => {
      const payload = {
        title: form.title.trim(),
        subtitle: form.subtitle || undefined,
        imageUrl: form.imageUrl,
        clickAction: form.clickAction || undefined,
        actionValue: form.actionValue || undefined,
        displayOrder: Number(form.displayOrder) || 0,
        startDate: form.startDate ? new Date(form.startDate).toISOString() : new Date().toISOString(),
        endDate: form.endDate ? new Date(form.endDate).toISOString() : undefined,
        isActive: form.isActive,
      };
      if (editing) await apiClient.patch(`/banners/${editing.id}`, payload);
      else await apiClient.post("/banners", payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Banner updated — customer Home refreshes" : "Banner published");
      setOpen(false);
      setEditing(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const toggle = useMutation({
    mutationFn: (b: any) => apiClient.patch(`/banners/${b.id}`, { isActive: !b.isActive }),
    onSuccess: () => {
      invalidate();
      toast.success("Banner visibility updated");
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => apiClient.delete(`/banners/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Banner deleted");
      setDeleteId(null);
    },
    onError: () => toast.error("Delete failed"),
  });

  const openEdit = (b: any) => {
    setEditing(b);
    setForm({
      title: b.title ?? "",
      subtitle: b.subtitle ?? "",
      imageUrl: b.imageUrl ?? "",
      clickAction: b.clickAction ?? "",
      actionValue: b.actionValue ?? "",
      displayOrder: String(b.displayOrder ?? 0),
      startDate: toLocalInput(b.startDate),
      endDate: toLocalInput(b.endDate),
      isActive: !!b.isActive,
    });
    setOpen(true);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Banners"
        description="Customer Home promos read this feed — image, order and schedule update live."
        actions={
          <Button onClick={() => { setForm(EMPTY); setEditing(null); setOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Add Banner
          </Button>
        }
      />
      <Card>
        <CardContent className="pt-6">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Banner</TableHead>
                  <TableHead>Action</TableHead>
                  <TableHead>Schedule</TableHead>
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
                ) : banners.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6}>
                      <EmptyState title="No banners" description="Publish a promo to show it on customer Home." />
                    </TableCell>
                  </TableRow>
                ) : (
                  banners.map((b: any) => {
                    const img = resolveImageUrl(b.imageUrl);
                    const now = new Date();
                    const scheduled = b.startDate && new Date(b.startDate) > now;
                    const expired = b.endDate && new Date(b.endDate) < now;
                    return (
                      <TableRow key={b.id}>
                        <TableCell>
                          <div className="flex items-center gap-3">
                            {img ? (
                              // eslint-disable-next-line @next/next/no-img-element
                              <img src={img} alt="" className="h-10 w-16 rounded-md border object-cover" />
                            ) : (
                              <div className="flex h-10 w-16 items-center justify-center rounded-md bg-muted text-xs text-muted-foreground">—</div>
                            )}
                            <div>
                              <p className="font-medium">{b.title}</p>
                              <p className="text-xs text-muted-foreground">{b.subtitle || "—"}</p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell className="text-xs">
                          {b.clickAction ? `${b.clickAction}: ${b.actionValue || ""}` : "—"}
                        </TableCell>
                        <TableCell className="text-xs text-muted-foreground">
                          {b.startDate ? formatDate(b.startDate) : "—"} → {b.endDate ? formatDate(b.endDate) : "∞"}
                          {scheduled && <Badge variant="outline" className="ml-2">scheduled</Badge>}
                          {expired && <Badge variant="destructive" className="ml-2">expired</Badge>}
                        </TableCell>
                        <TableCell>#{b.displayOrder ?? 0}</TableCell>
                        <TableCell>
                          <Switch checked={!!b.isActive} onCheckedChange={() => toggle.mutate(b)} />
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1">
                            <Button variant="ghost" size="icon" onClick={() => openEdit(b)}>
                              <Pencil className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="icon" onClick={() => setDeleteId(b.id)}>
                              <Trash2 className="h-4 w-4 text-destructive" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    );
                  })
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-h-[90vh] max-w-lg overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editing ? "Edit Banner" : "Add Banner"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Title *</Label>
              <Input value={form.title} onChange={(e) => set("title", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Subtitle</Label>
              <Input value={form.subtitle} onChange={(e) => set("subtitle", e.target.value)} />
            </div>
            <ImageUpload label="Banner image *" value={form.imageUrl} onChange={(v) => set("imageUrl", v)} />
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Target type</Label>
                <Input value={form.clickAction} onChange={(e) => set("clickAction", e.target.value)} placeholder="category / food / subscription" />
              </div>
              <div className="space-y-2">
                <Label>Target ID</Label>
                <Input value={form.actionValue} onChange={(e) => set("actionValue", e.target.value)} placeholder="category/food/plan id" />
              </div>
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label>Order</Label>
                <Input type="number" value={form.displayOrder} onChange={(e) => set("displayOrder", e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Start</Label>
                <Input type="datetime-local" value={form.startDate} onChange={(e) => set("startDate", e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>End</Label>
                <Input type="datetime-local" value={form.endDate} onChange={(e) => set("endDate", e.target.value)} />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Switch checked={form.isActive} onCheckedChange={(v) => set("isActive", v)} />
              <Label>Active</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.title || !form.imageUrl}>
              {editing ? "Save" : "Publish"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Banner"
        message="It will disappear from customer Home immediately."
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && remove.mutate(deleteId)}
      />
    </div>
  );
}
