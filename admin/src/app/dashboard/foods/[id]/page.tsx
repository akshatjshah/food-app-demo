"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { PageHeader } from "@/components/admin/page-header";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { ImageUpload } from "@/components/admin/image-upload";
import { formatCurrency } from "@/lib/utils";
import { toast } from "sonner";
import { ArrowLeft, Plus, Pencil, Trash2 } from "lucide-react";

const EMPTY = {
  name: "",
  description: "",
  price: "",
  originalPrice: "",
  categoryId: "",
  subcategory: "",
  mealTags: "",
  imageUrl: "",
  videoUrl: "",
  calories: "",
  preparationTimeMinutes: "20",
  stock: "",
  displayOrder: "0",
  tags: "",
  isHealthyPick: false,
  isFastingFriendly: false,
  isBestseller: false,
  isFeatured: false,
  isActive: true,
  isAvailable: true,
};

function toPayload(form: typeof EMPTY) {
  const num = (v: string) => (v === "" ? undefined : Number(v));
  return {
    name: form.name.trim(),
    description: form.description || undefined,
    price: Number(form.price),
    originalPrice: num(form.originalPrice),
    categoryId: form.categoryId || undefined,
    subcategory: form.subcategory.trim() || undefined,
    mealTags: form.mealTags ? form.mealTags.split(",").map((t) => t.trim()).filter(Boolean) : [],
    imageUrls: form.imageUrl ? [form.imageUrl] : [],
    videoUrl: form.videoUrl || undefined,
    calories: num(form.calories),
    preparationTimeMinutes: num(form.preparationTimeMinutes) ?? 20,
    stock: form.stock === "" ? undefined : Number(form.stock),
    displayOrder: Number(form.displayOrder) || 0,
    tags: form.tags ? form.tags.split(",").map((t) => t.trim()).filter(Boolean) : [],
    isHealthyPick: form.isHealthyPick,
    isFastingFriendly: form.isFastingFriendly,
    isBestseller: form.isBestseller,
    isFeatured: form.isFeatured,
    isActive: form.isActive,
    isAvailable: form.isAvailable,
  };
}

export default function FoodEditorPage() {
  const params = useParams<{ id: string }>();
  const id = params.id;
  const isNew = id === "new";
  const router = useRouter();
  const qc = useQueryClient();

  const [form, setForm] = useState(EMPTY);
  const [groupOpen, setGroupOpen] = useState(false);
  const [editingGroup, setEditingGroup] = useState<any>(null);
  const [groupForm, setGroupForm] = useState({ name: "", minSelections: "0", maxSelections: "1", displayOrder: "0", isActive: true });
  const [itemOpen, setItemOpen] = useState(false);
  const [activeGroup, setActiveGroup] = useState<any>(null);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [itemForm, setItemForm] = useState({ name: "", additionalPrice: "0", displayOrder: "0", isActive: true });
  const [deleteTarget, setDeleteTarget] = useState<{ kind: "group" | "item"; id: string } | null>(null);

  const { data: categories = [] } = useQuery({
    queryKey: ["categories-list"],
    queryFn: async () => (await apiClient.get("/categories/admin/all")).data?.data ?? [],
  });

  const { data: food, isLoading } = useQuery({
    queryKey: ["food", id],
    queryFn: async () => (await apiClient.get(`/foods/${id}`)).data?.data,
    enabled: !isNew,
  });

  const { data: groups = [], isLoading: groupsLoading } = useQuery({
    queryKey: ["food-groups", id],
    queryFn: async () => (await apiClient.get(`/foods/${id}/customizations`)).data?.data ?? [],
    enabled: !isNew,
  });

  useEffect(() => {
    if (food && !isNew) {
      const imgs = Array.isArray(food.imageUrls) ? food.imageUrls : [];
      setForm({
        name: food.name ?? "",
        description: food.description ?? "",
        price: food.price != null ? String(food.price) : "",
        originalPrice: food.originalPrice != null ? String(food.originalPrice) : "",
        categoryId: food.categoryId ?? "",
        subcategory: food.subcategory ?? "",
        mealTags: Array.isArray(food.mealTags) ? food.mealTags.join(", ") : "",
        imageUrl: imgs[0] ?? "",
        videoUrl: food.videoUrl ?? "",
        calories: food.calories != null ? String(food.calories) : "",
        preparationTimeMinutes: String(food.preparationTimeMinutes ?? 20),
        stock: food.stock != null ? String(food.stock) : "",
        displayOrder: String(food.displayOrder ?? 0),
        tags: Array.isArray(food.tags) ? food.tags.join(", ") : "",
        isHealthyPick: !!food.isHealthyPick,
        isFastingFriendly: !!food.isFastingFriendly,
        isBestseller: !!food.isBestseller,
        isFeatured: !!food.isFeatured,
        isActive: !!food.isActive,
        isAvailable: food.isAvailable !== false,
      });
    }
  }, [food, isNew]);

  const save = useMutation({
    mutationFn: async () => {
      const payload = toPayload(form);
      if (isNew) {
        const res = await apiClient.post("/foods", payload);
        return res.data?.data;
      }
      await apiClient.patch(`/foods/${id}`, payload);
      return null;
    },
    onSuccess: (created) => {
      qc.invalidateQueries({ queryKey: ["foods"] });
      qc.invalidateQueries({ queryKey: ["food", id] });
      toast.success(isNew ? "Food created — live in the customer app" : "Saved — customer app shows the new value");
      if (isNew && created?.id) router.replace(`/dashboard/foods/${created.id}`);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const invalidateGroups = () => {
    qc.invalidateQueries({ queryKey: ["food-groups", id] });
    qc.invalidateQueries({ queryKey: ["foods"] });
  };

  const saveGroup = useMutation({
    mutationFn: async () => {
      const payload = {
        name: groupForm.name.trim(),
        minSelections: Number(groupForm.minSelections) || 0,
        maxSelections: Number(groupForm.maxSelections) || 1,
        displayOrder: Number(groupForm.displayOrder) || 0,
        isActive: groupForm.isActive,
      };
      if (editingGroup) await apiClient.patch(`/foods/customizations/groups/${editingGroup.id}`, payload);
      else await apiClient.post(`/foods/${id}/customizations`, payload);
    },
    onSuccess: () => {
      invalidateGroups();
      toast.success(editingGroup ? "Group updated — customer food screen uses it" : "Group created — customer food screen shows it");
      setGroupOpen(false);
      setEditingGroup(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const saveItem = useMutation({
    mutationFn: async () => {
      const payload = {
        name: itemForm.name.trim(),
        additionalPrice: Number(itemForm.additionalPrice) || 0,
        displayOrder: Number(itemForm.displayOrder) || 0,
        isActive: itemForm.isActive,
      };
      if (editingItem) await apiClient.patch(`/foods/customizations/items/${editingItem.id}`, payload);
      else await apiClient.post(`/foods/customizations/groups/${activeGroup.id}/items`, payload);
    },
    onSuccess: () => {
      invalidateGroups();
      toast.success(editingItem ? "Option updated" : "Option created");
      setItemOpen(false);
      setEditingItem(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const removeTarget = useMutation({
    mutationFn: async () => {
      if (!deleteTarget) return;
      if (deleteTarget.kind === "group") await apiClient.delete(`/foods/customizations/groups/${deleteTarget.id}`);
      else await apiClient.delete(`/foods/customizations/items/${deleteTarget.id}`);
    },
    onSuccess: () => {
      invalidateGroups();
      toast.success("Deleted");
      setDeleteTarget(null);
    },
    onError: () => toast.error("Delete failed (options used in past orders are protected)"),
  });

  const set = (k: keyof typeof EMPTY, v: any) => setForm((f) => ({ ...f, [k]: v }));
  const finalPrice = Number(form.price) || 0;
  const discount = form.originalPrice ? Math.max(0, Number(form.originalPrice) - finalPrice) : 0;

  const openNewGroup = () => {
    setEditingGroup(null);
    setGroupForm({ name: "", minSelections: "1", maxSelections: "1", displayOrder: String(groups.length), isActive: true });
    setGroupOpen(true);
  };

  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <PageHeader
        title={isNew ? "Add Food" : `Edit Food${food ? ` — ${food.name}` : ""}`}
        description="Full-size editor. Every field here drives the customer app — name, price, availability, images and option groups."
        actions={
          <div className="flex gap-2">
            <Button variant="outline" onClick={() => router.push("/dashboard/foods")}>
              <ArrowLeft className="mr-2 h-4 w-4" /> Back to Foods
            </Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.name || !form.price || !form.categoryId}>
              {save.isPending ? "Saving…" : "Save"}
            </Button>
          </div>
        }
      />

      {isLoading ? (
        <Card><CardContent className="pt-6"><div className="h-64 animate-pulse rounded bg-muted" /></CardContent></Card>
      ) : (
        <>
          <Card>
            <CardHeader>
              <CardTitle>Basic Information</CardTitle>
              <CardDescription>Name, description, image and placement in the menu hierarchy.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2 md:col-span-2">
                <Label>Food name *</Label>
                <Input value={form.name} onChange={(e) => set("name", e.target.value)} placeholder="e.g. Nylon Poha Chevdo" />
              </div>
              <div className="space-y-2 md:col-span-2">
                <Label>Description</Label>
                <Textarea value={form.description} onChange={(e) => set("description", e.target.value)} rows={3} />
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
                <Label>Subcategory</Label>
                <Input
                  value={form.subcategory}
                  onChange={(e) => set("subcategory", e.target.value)}
                  placeholder="e.g. Vegetable / Shaak"
                  list="subcategory-suggestions"
                />
                <datalist id="subcategory-suggestions">
                  <option value="Breakfast & Morning Favourites" />
                  <option value="Vegetable / Shaak" />
                  <option value="Dal / Kadhi / Main Preparations" />
                  <option value="Rice & Khichdi" />
                  <option value="Rotli / Bhakhri / Puri" />
                  <option value="Traditional / Lesser-seen Dishes" />
                </datalist>
              </div>
              <div className="space-y-2">
                <Label>Meal tags (comma separated)</Label>
                <Input value={form.mealTags} onChange={(e) => set("mealTags", e.target.value)} placeholder="breakfast, lunch, dinner" />
              </div>
              <div className="space-y-2">
                <Label>Video URL (optional)</Label>
                <Input value={form.videoUrl} onChange={(e) => set("videoUrl", e.target.value)} placeholder="https://…" />
              </div>
              <div className="space-y-2 md:col-span-2">
                <ImageUpload label="Food image" value={form.imageUrl} onChange={(v) => set("imageUrl", v)} />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Pricing</CardTitle>
              <CardDescription>Server-authoritative prices — the app always calculates from these.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-3">
              <div className="space-y-2">
                <Label>Base price (₹) *</Label>
                <Input type="number" min="1" value={form.price} onChange={(e) => set("price", e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Original price (₹) — shows discount</Label>
                <Input type="number" min="0" value={form.originalPrice} onChange={(e) => set("originalPrice", e.target.value)} />
                {discount > 0 && <p className="text-xs text-green-600">Customer saves {formatCurrency(discount)}</p>}
              </div>
              <div className="space-y-2">
                <Label>Calories</Label>
                <Input type="number" min="0" value={form.calories} onChange={(e) => set("calories", e.target.value)} />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Menu Availability</CardTitle>
              <CardDescription>Controls exactly where and whether customers can order this dish.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              {([
                ["isActive", "Active listing (visible in menu)"],
                ["isAvailable", "Available for ordering right now"],
                ["isFeatured", "Featured (homepage / featured lists)"],
                ["isBestseller", "Bestseller badge"],
                ["isHealthyPick", "Healthy pick"],
                ["isFastingFriendly", "Fasting friendly"],
              ] as const).map(([key, label]) => (
                <div key={key} className="flex items-center justify-between rounded-md border p-3">
                  <Label>{label}</Label>
                  <Switch checked={!!form[key]} onCheckedChange={(v) => set(key, v)} />
                </div>
              ))}
              <div className="space-y-2">
                <Label>Preparation time (min)</Label>
                <Input type="number" min="1" value={form.preparationTimeMinutes} onChange={(e) => set("preparationTimeMinutes", e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Stock (blank = unlimited)</Label>
                <Input type="number" min="0" value={form.stock} onChange={(e) => set("stock", e.target.value)} />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Variants & Customizations</CardTitle>
              <CardDescription>
                Variant selectors from the menu (e.g. Diet / Regular) and add-ons live here.
                Required groups, min/max and option prices are enforced by the backend at cart + checkout.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {isNew ? (
                <p className="text-sm text-muted-foreground">Save the food first, then add option groups here.</p>
              ) : groupsLoading ? (
                <div className="h-24 animate-pulse rounded bg-muted" />
              ) : groups.length === 0 ? (
                <div className="flex items-center justify-between rounded-md border border-dashed p-4">
                  <p className="text-sm text-muted-foreground">No option groups yet — customers will see only quantity + special instructions.</p>
                  <Button size="sm" onClick={openNewGroup}><Plus className="mr-1 h-4 w-4" /> Add group</Button>
                </div>
              ) : (
                <>
                  <div className="flex justify-end">
                    <Button size="sm" onClick={openNewGroup}><Plus className="mr-1 h-4 w-4" /> Add group</Button>
                  </div>
                  {groups.map((g: any) => (
                    <div key={g.id} className="rounded-md border p-4">
                      <div className="mb-2 flex flex-wrap items-center gap-2">
                        <p className="font-medium">{g.name}</p>
                        <span className="text-xs text-muted-foreground">
                          min {g.minSelections} · max {g.maxSelections} · {g.isActive ? "active" : "inactive"}
                          {g.minSelections > 0 ? " · required" : " · optional"}
                        </span>
                        <div className="ml-auto flex gap-1">
                          <Button
                            variant="ghost" size="sm"
                            onClick={() => {
                              setEditingGroup(g);
                              setGroupForm({
                                name: g.name,
                                minSelections: String(g.minSelections),
                                maxSelections: String(g.maxSelections),
                                displayOrder: String(g.displayOrder ?? 0),
                                isActive: !!g.isActive,
                              });
                              setGroupOpen(true);
                            }}
                          >
                            <Pencil className="h-3 w-3" /> Edit
                          </Button>
                          <Button
                            variant="ghost" size="sm"
                            onClick={() => { setActiveGroup(g); setEditingItem(null); setItemForm({ name: "", additionalPrice: "0", displayOrder: String((g.items || []).length), isActive: true }); setItemOpen(true); }}
                          >
                            <Plus className="h-3 w-3" /> Option
                          </Button>
                          <Button variant="ghost" size="sm" onClick={() => setDeleteTarget({ kind: "group", id: g.id })}>
                            <Trash2 className="h-3 w-3 text-destructive" />
                          </Button>
                        </div>
                      </div>
                      <div className="space-y-1">
                        {(g.items || []).map((it: any) => (
                          <div key={it.id} className="flex items-center gap-2 rounded bg-muted/50 px-3 py-2 text-sm">
                            <span className={it.isActive ? "" : "text-muted-foreground line-through"}>{it.name}</span>
                            <span className="text-muted-foreground">
                              {Number(it.additionalPrice) > 0 ? `+${formatCurrency(Number(it.additionalPrice))}` : "included"}
                              {!it.isActive && " · off"}
                            </span>
                            <div className="ml-auto flex gap-1">
                              <Button
                                variant="ghost" size="icon"
                                onClick={() => {
                                  setActiveGroup(g);
                                  setEditingItem(it);
                                  setItemForm({
                                    name: it.name,
                                    additionalPrice: String(it.additionalPrice ?? 0),
                                    displayOrder: String(it.displayOrder ?? 0),
                                    isActive: !!it.isActive,
                                  });
                                  setItemOpen(true);
                                }}
                              >
                                <Pencil className="h-3 w-3" />
                              </Button>
                              <Button variant="ghost" size="icon" onClick={() => setDeleteTarget({ kind: "item", id: it.id })}>
                                <Trash2 className="h-3 w-3 text-destructive" />
                              </Button>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  ))}
                </>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Display</CardTitle>
              <CardDescription>Ordering and discovery inside the menu.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label>Sort position (lower shows first)</Label>
                <Input type="number" value={form.displayOrder} onChange={(e) => set("displayOrder", e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Tags (comma separated)</Label>
                <Input value={form.tags} onChange={(e) => set("tags", e.target.value)} placeholder="spicy, lunch" />
              </div>
            </CardContent>
          </Card>

          <div className="flex justify-end gap-2 pb-8">
            <Button variant="outline" onClick={() => router.push("/dashboard/foods")}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.name || !form.price || !form.categoryId}>
              {save.isPending ? "Saving…" : isNew ? "Create food" : "Save changes"}
            </Button>
          </div>
        </>
      )}

      <Dialog open={groupOpen} onOpenChange={setGroupOpen}>
        <DialogContent>
          <DialogHeader><DialogTitle>{editingGroup ? "Edit option group" : "New option group"}</DialogTitle></DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label>Group name * (customers see this, e.g. Choose your type)</Label>
              <Input value={groupForm.name} onChange={(e) => setGroupForm({ ...groupForm, name: e.target.value })} />
            </div>
            <div className="grid grid-cols-3 gap-3">
              <div className="space-y-2">
                <Label>Min (0 = optional)</Label>
                <Input type="number" min="0" value={groupForm.minSelections} onChange={(e) => setGroupForm({ ...groupForm, minSelections: e.target.value })} />
              </div>
              <div className="space-y-2">
                <Label>Max</Label>
                <Input type="number" min="1" value={groupForm.maxSelections} onChange={(e) => setGroupForm({ ...groupForm, maxSelections: e.target.value })} />
              </div>
              <div className="space-y-2">
                <Label>Order</Label>
                <Input type="number" value={groupForm.displayOrder} onChange={(e) => setGroupForm({ ...groupForm, displayOrder: e.target.value })} />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Switch checked={groupForm.isActive} onCheckedChange={(v) => setGroupForm({ ...groupForm, isActive: v })} />
              <Label>Group active</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setGroupOpen(false)}>Cancel</Button>
            <Button onClick={() => saveGroup.mutate()} disabled={saveGroup.isPending || !groupForm.name.trim()}>
              {editingGroup ? "Save group" : "Create group"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={itemOpen} onOpenChange={setItemOpen}>
        <DialogContent>
          <DialogHeader><DialogTitle>{editingItem ? "Edit option" : `New option in “${activeGroup?.name}”`}</DialogTitle></DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label>Option name *</Label>
              <Input value={itemForm.name} onChange={(e) => setItemForm({ ...itemForm, name: e.target.value })} placeholder="e.g. Fully Veg Loaded" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label>Extra price (₹)</Label>
                <Input type="number" min="0" value={itemForm.additionalPrice} onChange={(e) => setItemForm({ ...itemForm, additionalPrice: e.target.value })} />
              </div>
              <div className="space-y-2">
                <Label>Order</Label>
                <Input type="number" value={itemForm.displayOrder} onChange={(e) => setItemForm({ ...itemForm, displayOrder: e.target.value })} />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Switch checked={itemForm.isActive} onCheckedChange={(v) => setItemForm({ ...itemForm, isActive: v })} />
              <Label>Option available</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setItemOpen(false)}>Cancel</Button>
            <Button onClick={() => saveItem.mutate()} disabled={saveItem.isPending || !itemForm.name.trim()}>
              {editingItem ? "Save option" : "Create option"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteTarget}
        title={deleteTarget?.kind === "group" ? "Delete option group" : "Delete option"}
        message="Customers will no longer see this. Past orders keep their snapshots."
        confirmLabel="Delete"
        danger
        loading={removeTarget.isPending}
        onCancel={() => setDeleteTarget(null)}
        onConfirm={() => removeTarget.mutate()}
      />
    </div>
  );
}
