"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
import { formatCurrency } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Trash2 } from "lucide-react";

export default function CustomizationsPage() {
  const [foodId, setFoodId] = useState("");
  const [groupOpen, setGroupOpen] = useState(false);
  const [editingGroup, setEditingGroup] = useState<any>(null);
  const [groupForm, setGroupForm] = useState({ name: "", minSelections: "0", maxSelections: "1", displayOrder: "0", isActive: true });
  const [itemOpen, setItemOpen] = useState(false);
  const [activeGroup, setActiveGroup] = useState<any>(null);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [itemForm, setItemForm] = useState({ name: "", additionalPrice: "0", displayOrder: "0", isActive: true });
  const [deleteTarget, setDeleteTarget] = useState<{ kind: "group" | "item"; id: string } | null>(null);
  const qc = useQueryClient();

  const { data: foods = [] } = useQuery({
    queryKey: ["foods-lite"],
    queryFn: async () => (await apiClient.get("/foods/admin/all")).data?.data ?? [],
  });

  const { data: groups = [], isLoading } = useQuery({
    queryKey: ["customizations", foodId],
    queryFn: async () => (await apiClient.get(`/foods/${foodId}/customizations`)).data?.data ?? [],
    enabled: !!foodId,
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["customizations", foodId] });

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
      else await apiClient.post(`/foods/${foodId}/customizations`, payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editingGroup ? "Group updated" : "Group created — customer food screen uses it");
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
      invalidate();
      toast.success(editingItem ? "Option updated" : "Option created");
      setItemOpen(false);
      setEditingItem(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const remove = useMutation({
    mutationFn: async () => {
      if (!deleteTarget) return;
      if (deleteTarget.kind === "group") await apiClient.delete(`/foods/customizations/groups/${deleteTarget.id}`);
      else await apiClient.delete(`/foods/customizations/items/${deleteTarget.id}`);
    },
    onSuccess: () => {
      invalidate();
      toast.success("Deleted");
      setDeleteTarget(null);
    },
    onError: () => toast.error("Delete failed"),
  });

  const openNewGroup = () => {
    setEditingGroup(null);
    setGroupForm({ name: "", minSelections: "0", maxSelections: "1", displayOrder: String(groups.length), isActive: true });
    setGroupOpen(true);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Food Customizations"
        description="Size, add-ons and options per dish. Pricing here is the single source — the customer app never hardcodes it."
        actions={foodId ? <Button onClick={openNewGroup}><Plus className="mr-2 h-4 w-4" /> Add Group</Button> : undefined}
      />

      <Card>
        <CardContent className="pt-6">
          <div className="max-w-md space-y-2">
            <Label>Select food</Label>
            <Select value={foodId} onValueChange={setFoodId}>
              <SelectTrigger><SelectValue placeholder="Choose a dish…" /></SelectTrigger>
              <SelectContent>
                {foods.map((f: any) => (
                  <SelectItem key={f.id} value={f.id}>{f.name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {!foodId ? (
        <Card>
          <CardContent>
            <EmptyState title="Pick a dish" description="Select a food item above to manage its customization groups and options." />
          </CardContent>
        </Card>
      ) : isLoading ? (
        <Card><CardContent className="p-6"><div className="h-24 animate-pulse rounded bg-muted" /></CardContent></Card>
      ) : groups.length === 0 ? (
        <Card>
          <CardContent>
            <EmptyState title="No customization groups" description="E.g. Size (Regular / Large +₹) or Add-ons (Paneer +₹)." />
          </CardContent>
        </Card>
      ) : (
        groups.map((g: any) => (
          <Card key={g.id}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0">
              <div>
                <CardTitle className="text-base">
                  {g.name}{" "}
                  {!g.isActive && <Badge variant="secondary" className="ml-2">inactive</Badge>}
                  {Number(g.minSelections) > 0 && <Badge variant="outline" className="ml-2">required</Badge>}
                </CardTitle>
                <p className="text-xs text-muted-foreground">
                  min {g.minSelections} · max {g.maxSelections} · order {g.displayOrder}
                </p>
              </div>
              <div className="flex gap-1">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setActiveGroup(g);
                    setEditingItem(null);
                    setItemForm({ name: "", additionalPrice: "0", displayOrder: String(g.items?.length ?? 0), isActive: true });
                    setItemOpen(true);
                  }}
                >
                  <Plus className="mr-1 h-3 w-3" /> Option
                </Button>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => {
                    setEditingGroup(g);
                    setGroupForm({
                      name: g.name,
                      minSelections: String(g.minSelections),
                      maxSelections: String(g.maxSelections),
                      displayOrder: String(g.displayOrder ?? 0),
                      isActive: g.isActive !== false,
                    });
                    setGroupOpen(true);
                  }}
                >
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button variant="ghost" size="icon" onClick={() => setDeleteTarget({ kind: "group", id: g.id })}>
                  <Trash2 className="h-4 w-4 text-destructive" />
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {(g.items?.length ?? 0) === 0 ? (
                <p className="text-sm text-muted-foreground">No options yet.</p>
              ) : (
                <div className="divide-y rounded-md border">
                  {g.items.map((it: any) => (
                    <div key={it.id} className="flex items-center justify-between px-4 py-2">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-medium">{it.name}</span>
                        {!it.isActive && <Badge variant="secondary">inactive</Badge>}
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-sm text-muted-foreground">+{formatCurrency(Number(it.additionalPrice))}</span>
                        <Button
                          variant="ghost"
                          size="icon"
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
              )}
            </CardContent>
          </Card>
        ))
      )}

      <Dialog open={groupOpen} onOpenChange={setGroupOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{editingGroup ? "Edit Group" : "Add Group"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Name *</Label>
              <Input value={groupForm.name} onChange={(e) => setGroupForm({ ...groupForm, name: e.target.value })} placeholder="Size / Add-ons" />
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label>Min</Label>
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
              <Label>Active (visible to customers)</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setGroupOpen(false)}>Cancel</Button>
            <Button onClick={() => saveGroup.mutate()} disabled={saveGroup.isPending || !groupForm.name}>
              {editingGroup ? "Save" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={itemOpen} onOpenChange={setItemOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{editingItem ? "Edit Option" : `Add Option to ${activeGroup?.name}`}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Name *</Label>
              <Input value={itemForm.name} onChange={(e) => setItemForm({ ...itemForm, name: e.target.value })} placeholder="Large / Extra Paneer" />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Price adjustment (₹)</Label>
                <Input type="number" min="0" value={itemForm.additionalPrice} onChange={(e) => setItemForm({ ...itemForm, additionalPrice: e.target.value })} />
              </div>
              <div className="space-y-2">
                <Label>Order</Label>
                <Input type="number" value={itemForm.displayOrder} onChange={(e) => setItemForm({ ...itemForm, displayOrder: e.target.value })} />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Switch checked={itemForm.isActive} onCheckedChange={(v) => setItemForm({ ...itemForm, isActive: v })} />
              <Label>Active</Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setItemOpen(false)}>Cancel</Button>
            <Button onClick={() => saveItem.mutate()} disabled={saveItem.isPending || !itemForm.name}>
              {editingItem ? "Save" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete"
        message={deleteTarget?.kind === "group" ? "The group and all its options will be removed." : "This option will be removed."}
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteTarget(null)}
        onConfirm={() => remove.mutate()}
      />
    </div>
  );
}
