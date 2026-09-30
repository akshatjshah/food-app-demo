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
import { Textarea } from "@/components/ui/textarea";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { ImageUpload, resolveImageUrl } from "@/components/admin/image-upload";
import { toast } from "sonner";
import { Plus, Pencil, Trash2, ArrowUp, ArrowDown } from "lucide-react";

const EMPTY = { name: "", icon: "", imageUrl: "", description: "", displayOrder: "0", isFeatured: false };

export default function CategoriesPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY);
  const qc = useQueryClient();

  const { data: categories = [], isLoading } = useQuery({
    queryKey: ["categories"],
    queryFn: async () => (await apiClient.get("/categories/admin/all")).data?.data ?? [],
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["categories"] });
  const set = (k: keyof typeof EMPTY, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const save = useMutation({
    mutationFn: async () => {
      const payload = {
        name: form.name.trim(),
        icon: form.icon || undefined,
        imageUrl: form.imageUrl || undefined,
        description: form.description || undefined,
        displayOrder: Number(form.displayOrder) || 0,
        isFeatured: form.isFeatured,
      };
      if (editing) await apiClient.patch(`/categories/${editing.id}`, payload);
      else await apiClient.post("/categories", payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Category updated" : "Category created");
      setOpen(false);
      setForm(EMPTY);
      setEditing(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const toggle = useMutation({
    mutationFn: async (c: any) =>
      apiClient.patch(`/categories/${c.id}/${c.isActive ? "deactivate" : "activate"}`),
    onSuccess: () => {
      invalidate();
      toast.success("Category status updated");
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Update failed"),
  });

  const move = useMutation({
    mutationFn: async ({ list }: { list: any[] }) =>
      apiClient.patch("/categories/admin/reorder", {
        items: list.map((c, i) => ({ id: c.id, displayOrder: i + 1 })),
      }),
    onSuccess: () => {
      invalidate();
      toast.success("Order updated — customer browsing uses this order");
    },
    onError: () => toast.error("Reorder failed"),
  });

  const remove = useMutation({
    mutationFn: async (id: string) => apiClient.delete(`/categories/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Category deleted");
      setDeleteId(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Delete failed"),
  });

  const openEdit = (c: any) => {
    setEditing(c);
    setForm({
      name: c.name ?? "",
      icon: c.icon ?? "",
      imageUrl: c.imageUrl ?? "",
      description: c.description ?? "",
      displayOrder: String(c.displayOrder ?? 0),
      isFeatured: !!c.isFeatured,
    });
    setOpen(true);
  };

  const shift = (index: number, dir: -1 | 1) => {
    const list = [...categories].sort((a: any, b: any) => (a.displayOrder ?? 0) - (b.displayOrder ?? 0));
    const j = index + dir;
    if (j < 0 || j >= list.length) return;
    [list[index], list[j]] = [list[j], list[index]];
    move.mutate({ list });
  };

  const sorted = [...categories].sort((a: any, b: any) => (a.displayOrder ?? 0) - (b.displayOrder ?? 0));

  return (
    <div className="space-y-6">
      <PageHeader
        title="Categories"
        description="Customer Home and Menu read this list — order, images and visibility update live."
        actions={
          <Button onClick={() => { setForm(EMPTY); setEditing(null); setOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Add Category
          </Button>
        }
      />
      <Card>
        <CardContent className="pt-6">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Category</TableHead>
                  <TableHead>Foods</TableHead>
                  <TableHead>Order</TableHead>
                  <TableHead>Featured</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead className="w-32">Actions</TableHead>
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
                ) : sorted.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6}>
                      <EmptyState title="No categories" description="Create categories to organize the customer menu." />
                    </TableCell>
                  </TableRow>
                ) : (
                  sorted.map((c: any, i: number) => {
                    const img = resolveImageUrl(c.imageUrl);
                    return (
                      <TableRow key={c.id}>
                        <TableCell>
                          <div className="flex items-center gap-3">
                            {img ? (
                              // eslint-disable-next-line @next/next/no-img-element
                              <img src={img} alt="" className="h-10 w-10 rounded-md border object-cover" />
                            ) : (
                              <div className="flex h-10 w-10 items-center justify-center rounded-md bg-muted text-lg">
                                {c.icon || "🍽"}
                              </div>
                            )}
                            <div>
                              <p className="font-medium">{c.name}</p>
                              <p className="max-w-64 truncate text-xs text-muted-foreground">{c.description || "—"}</p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>{c._count?.foodItems ?? "—"}</TableCell>
                        <TableCell>#{c.displayOrder ?? 0}</TableCell>
                        <TableCell>{c.isFeatured ? <Badge>Featured</Badge> : <span className="text-muted-foreground">—</span>}</TableCell>
                        <TableCell>
                          <Switch checked={!!c.isActive} onCheckedChange={() => toggle.mutate(c)} />
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1">
                            <Button variant="ghost" size="icon" title="Move up" onClick={() => shift(i, -1)}>
                              <ArrowUp className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="icon" title="Move down" onClick={() => shift(i, 1)}>
                              <ArrowDown className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="icon" onClick={() => openEdit(c)}>
                              <Pencil className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="icon" onClick={() => setDeleteId(c.id)}>
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

      <Dialog open={open} onOpenChange={(v) => !v && setOpen(false)}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{editing ? "Edit Category" : "Add Category"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Name *</Label>
              <Input value={form.name} onChange={(e) => set("name", e.target.value)} />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Icon (emoji)</Label>
                <Input value={form.icon} onChange={(e) => set("icon", e.target.value)} placeholder="🍛" />
              </div>
              <div className="space-y-2">
                <Label>Sort position</Label>
                <Input type="number" value={form.displayOrder} onChange={(e) => set("displayOrder", e.target.value)} />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Description</Label>
              <Textarea value={form.description} onChange={(e) => set("description", e.target.value)} />
            </div>
            <ImageUpload label="Category image" value={form.imageUrl} onChange={(v) => set("imageUrl", v)} />
            <div className="flex items-center gap-2">
              <Switch checked={form.isFeatured} onCheckedChange={(v) => set("isFeatured", v)} />
              <Label>Featured</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.name}>
              {editing ? "Save Changes" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Category"
        message="Allowed only when no foods or shorts reference it. Otherwise deactivate or reassign first."
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && remove.mutate(deleteId)}
      />
    </div>
  );
}
