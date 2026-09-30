"use client";

import { useMemo, useState } from "react";
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
import { Textarea } from "@/components/ui/textarea";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { Pagination } from "@/components/admin/pagination";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { ImageUpload, resolveImageUrl } from "@/components/admin/image-upload";
import { formatCurrency } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Trash2, Search } from "lucide-react";

const EMPTY_FORM = {
  name: "",
  description: "",
  price: "",
  originalPrice: "",
  categoryId: "",
  imageUrl: "",
  videoUrl: "",
  calories: "",
  preparationTimeMinutes: "20",
  stock: "",
  displayOrder: "0",
  tags: "",
  isVeg: true,
  isJainAvailable: false,
  isFastingFriendly: false,
  isBestseller: false,
  isHealthyPick: false,
  isActive: true,
};

function toPayload(form: typeof EMPTY_FORM) {
  const num = (v: string) => (v === "" ? undefined : Number(v));
  return {
    name: form.name.trim(),
    description: form.description || undefined,
    price: Number(form.price),
    originalPrice: num(form.originalPrice),
    categoryId: form.categoryId || undefined,
    imageUrls: form.imageUrl ? [form.imageUrl] : [],
    videoUrl: form.videoUrl || undefined,
    calories: num(form.calories),
    preparationTimeMinutes: num(form.preparationTimeMinutes) ?? 20,
    stock: form.stock === "" ? null : Number(form.stock),
    displayOrder: Number(form.displayOrder) || 0,
    tags: form.tags ? form.tags.split(",").map((t) => t.trim()).filter(Boolean) : [],
    isVeg: form.isVeg,
    isJainAvailable: form.isJainAvailable,
    isFastingFriendly: form.isFastingFriendly,
    isBestseller: form.isBestseller,
    isHealthyPick: form.isHealthyPick,
    isActive: form.isActive,
  };
}

export default function FoodsPage() {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [page, setPage] = useState(0);
  const pageSize = 15;
  const queryClient = useQueryClient();

  const { data: foods = [], isLoading } = useQuery({
    queryKey: ["foods"],
    queryFn: async () => (await apiClient.get("/foods/admin/all")).data?.data ?? [],
  });

  const { data: categories = [] } = useQuery({
    queryKey: ["categories-list"],
    queryFn: async () => (await apiClient.get("/categories/admin/all")).data?.data ?? [],
  });

  const categoryName = (id: string) => categories.find((c: any) => c.id === id)?.name ?? "—";

  const filtered = useMemo(() => {
    return foods.filter((f: any) => {
      if (categoryFilter !== "all" && f.categoryId !== categoryFilter) return false;
      if (search && !f.name?.toLowerCase().includes(search.toLowerCase())) return false;
      return true;
    });
  }, [foods, search, categoryFilter]);

  const paged = filtered.slice(page * pageSize, page * pageSize + pageSize);

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ["foods"] });

  const saveMutation = useMutation({
    mutationFn: async () => {
      const payload = toPayload(form);
      if (editing) await apiClient.patch(`/foods/${editing.id}`, payload);
      else await apiClient.post("/foods", payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Food updated — customer app shows the new value" : "Food created");
      setDialogOpen(false);
      resetForm();
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const toggleMutation = useMutation({
    mutationFn: async ({ id, isActive }: any) => apiClient.patch(`/foods/${id}`, { isActive }),
    onSuccess: () => {
      invalidate();
      toast.success("Availability updated");
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => apiClient.delete(`/foods/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Food item removed");
      setDeleteId(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Delete failed"),
  });

  const resetForm = () => {
    setForm(EMPTY_FORM);
    setEditing(null);
  };

  const openEdit = (food: any) => {
    setEditing(food);
    const imgs = Array.isArray(food.imageUrls) ? food.imageUrls : [];
    setForm({
      name: food.name ?? "",
      description: food.description ?? "",
      price: String(food.price ?? ""),
      originalPrice: food.originalPrice != null ? String(food.originalPrice) : "",
      categoryId: food.categoryId ?? "",
      imageUrl: imgs[0] ?? "",
      videoUrl: food.videoUrl ?? "",
      calories: food.calories != null ? String(food.calories) : "",
      preparationTimeMinutes: String(food.preparationTimeMinutes ?? 20),
      stock: food.stock != null ? String(food.stock) : "",
      displayOrder: String(food.displayOrder ?? 0),
      tags: Array.isArray(food.tags) ? food.tags.join(", ") : "",
      isVeg: food.isVeg !== false,
      isJainAvailable: !!food.isJainAvailable,
      isFastingFriendly: !!food.isFastingFriendly,
      isBestseller: !!food.isBestseller,
      isHealthyPick: !!food.isHealthyPick,
      isActive: !!food.isActive,
    });
    setDialogOpen(true);
  };

  const set = (k: keyof typeof EMPTY_FORM, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const finalPrice = Number(form.price) || 0;
  const discount = form.originalPrice ? Math.max(0, Number(form.originalPrice) - finalPrice) : 0;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Foods"
        description="Everything the customer sees — name, price, images, availability. Changes go live via the API."
        actions={
          <Button onClick={() => { resetForm(); setDialogOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Add Food
          </Button>
        }
      />

      <Card>
        <CardContent className="pt-6">
          <div className="mb-4 flex flex-col gap-3 sm:flex-row">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Search foods…"
                className="pl-9"
                value={search}
                onChange={(e) => { setSearch(e.target.value); setPage(0); }}
              />
            </div>
            <Select value={categoryFilter} onValueChange={(v) => { setCategoryFilter(v); setPage(0); }}>
              <SelectTrigger className="w-full sm:w-56">
                <SelectValue placeholder="All categories" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All categories</SelectItem>
                {categories.map((c: any) => (
                  <SelectItem key={c.id} value={c.id}>{c.name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Food</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Stock</TableHead>
                  <TableHead>Flags</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead className="w-24">Actions</TableHead>
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
                ) : paged.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7}>
                      <EmptyState title="No foods found" description="Add your first food item to show it in the customer app." />
                    </TableCell>
                  </TableRow>
                ) : (
                  paged.map((food: any) => {
                    const imgs = Array.isArray(food.imageUrls) ? food.imageUrls : [];
                    const thumb = resolveImageUrl(imgs[0]);
                    return (
                      <TableRow key={food.id}>
                        <TableCell>
                          <div className="flex items-center gap-3">
                            {thumb ? (
                              // eslint-disable-next-line @next/next/no-img-element
                              <img src={thumb} alt="" className="h-10 w-10 rounded-md border object-cover" />
                            ) : (
                              <div className="flex h-10 w-10 items-center justify-center rounded-md bg-muted text-xs text-muted-foreground">—</div>
                            )}
                            <div>
                              <p className="font-medium">{food.name}</p>
                              <p className="text-xs text-muted-foreground">#{food.displayOrder ?? 0} · {food.preparationTimeMinutes ?? 20} min</p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>{food.category?.name || categoryName(food.categoryId)}</TableCell>
                        <TableCell>
                          <div>{formatCurrency(Number(food.price))}</div>
                          {food.originalPrice && (
                            <div className="text-xs text-muted-foreground line-through">{formatCurrency(Number(food.originalPrice))}</div>
                          )}
                        </TableCell>
                        <TableCell>{food.stock == null ? <span className="text-muted-foreground">∞</span> : food.stock}</TableCell>
                        <TableCell>
                          <div className="flex flex-wrap gap-1">
                            {food.isBestseller && <Badge>Featured</Badge>}
                            {food.isHealthyPick && <Badge variant="secondary">Healthy</Badge>}
                            {food.isJainAvailable && <Badge variant="outline">Jain</Badge>}
                          </div>
                        </TableCell>
                        <TableCell>
                          <Switch
                            checked={!!food.isActive}
                            onCheckedChange={(v) => toggleMutation.mutate({ id: food.id, isActive: v })}
                          />
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1">
                            <Button variant="ghost" size="icon" onClick={() => openEdit(food)}>
                              <Pencil className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="icon" onClick={() => setDeleteId(food.id)}>
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
          <Pagination page={page} pageSize={pageSize} total={filtered.length} onPageChange={setPage} />
        </CardContent>
      </Card>

      <Dialog open={dialogOpen} onOpenChange={(v) => { if (!v) { setDialogOpen(false); resetForm(); } }}>
        <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editing ? "Edit Food" : "Add Food"}</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4 sm:grid-cols-2">
            <div className="space-y-2 sm:col-span-2">
              <Label>Name *</Label>
              <Input value={form.name} onChange={(e) => set("name", e.target.value)} />
            </div>
            <div className="space-y-2 sm:col-span-2">
              <Label>Description</Label>
              <Textarea value={form.description} onChange={(e) => set("description", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Price (₹) *</Label>
              <Input type="number" min="1" value={form.price} onChange={(e) => set("price", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Original price (₹) — shows discount</Label>
              <Input type="number" min="0" value={form.originalPrice} onChange={(e) => set("originalPrice", e.target.value)} />
              {discount > 0 && <p className="text-xs text-green-600">Customer saves {formatCurrency(discount)}</p>}
            </div>
            <div className="space-y-2">
              <Label>Category *</Label>
              <Select value={form.categoryId} onValueChange={(v) => set("categoryId", v)}>
                <SelectTrigger><SelectValue placeholder="Select category" /></SelectTrigger>
                <SelectContent>
                  {categories.map((c: any) => (
                    <SelectItem key={c.id} value={c.id}>{c.name}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Prep time (min)</Label>
              <Input type="number" min="1" value={form.preparationTimeMinutes} onChange={(e) => set("preparationTimeMinutes", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Stock (blank = unlimited)</Label>
              <Input type="number" min="0" value={form.stock} onChange={(e) => set("stock", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Sort position</Label>
              <Input type="number" value={form.displayOrder} onChange={(e) => set("displayOrder", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Calories</Label>
              <Input type="number" min="0" value={form.calories} onChange={(e) => set("calories", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Tags (comma separated)</Label>
              <Input value={form.tags} onChange={(e) => set("tags", e.target.value)} placeholder="spicy, lunch" />
            </div>
            <div className="space-y-2 sm:col-span-2">
              <ImageUpload label="Food image" value={form.imageUrl} onChange={(v) => set("imageUrl", v)} />
            </div>
            <div className="space-y-2 sm:col-span-2">
              <Label>Video URL (optional)</Label>
              <Input value={form.videoUrl} onChange={(e) => set("videoUrl", e.target.value)} placeholder="https://…" />
            </div>
            <div className="flex flex-wrap gap-x-6 gap-y-3 sm:col-span-2">
              {([
                ["isVeg", "Veg (always on — pure veg kitchen)"],
                ["isJainAvailable", "Jain available"],
                ["isFastingFriendly", "Fasting friendly"],
                ["isBestseller", "Featured / special"],
                ["isHealthyPick", "Healthy pick"],
                ["isActive", "Available for ordering"],
              ] as const).map(([key, label]) => (
                <div key={key} className="flex items-center gap-2">
                  <Switch checked={!!form[key]} onCheckedChange={(v) => set(key, v)} disabled={key === "isVeg"} />
                  <Label>{label}</Label>
                </div>
              ))}
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => { setDialogOpen(false); resetForm(); }}>Cancel</Button>
            <Button onClick={() => saveMutation.mutate()} disabled={saveMutation.isPending || !form.name || !form.price || !form.categoryId}>
              {editing ? "Save Changes" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Food Item"
        message="The item will be soft-deleted and hidden from customers. Past orders keep their records."
        confirmLabel="Delete"
        danger
        loading={deleteMutation.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
      />
    </div>
  );
}
