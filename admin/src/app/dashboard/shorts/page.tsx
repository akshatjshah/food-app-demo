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
import { Textarea } from "@/components/ui/textarea";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { ImageUpload, resolveImageUrl } from "@/components/admin/image-upload";
import { formatDate } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Trash2 } from "lucide-react";

const EMPTY = { videoUrl: "", thumbnailUrl: "", caption: "", foodItemId: "", categoryId: "", displayOrder: "0", isActive: true };

export default function ShortsPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY);
  const qc = useQueryClient();

  const { data: shorts = [], isLoading } = useQuery({
    queryKey: ["shorts"],
    queryFn: async () => (await apiClient.get("/shorts/admin/all")).data?.data ?? [],
  });

  const { data: foods = [] } = useQuery({
    queryKey: ["foods-lite"],
    queryFn: async () => (await apiClient.get("/foods/admin/all")).data?.data ?? [],
  });

  const { data: categories = [] } = useQuery({
    queryKey: ["categories-list"],
    queryFn: async () => (await apiClient.get("/categories/admin/all")).data?.data ?? [],
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["shorts"] });
  const set = (k: keyof typeof EMPTY, v: any) => setForm((f) => ({ ...f, [k]: v }));
  const none = (v: string) => (v === "" ? undefined : v);

  const save = useMutation({
    mutationFn: async () => {
      const payload = {
        videoUrl: form.videoUrl,
        thumbnailUrl: form.thumbnailUrl,
        caption: form.caption || undefined,
        foodItemId: none(form.foodItemId),
        categoryId: none(form.categoryId),
        displayOrder: Number(form.displayOrder) || 0,
        isActive: form.isActive,
      };
      if (editing) await apiClient.patch(`/shorts/admin/${editing.id}`, payload);
      else await apiClient.post("/shorts/admin", payload);
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Short updated" : "Short published — customer Shorts feed shows it");
      setOpen(false);
      setEditing(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const toggle = useMutation({
    mutationFn: (s: any) => apiClient.patch(`/shorts/admin/${s.id}`, { isActive: !s.isActive }),
    onSuccess: () => {
      invalidate();
      toast.success("Short visibility updated");
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => apiClient.delete(`/shorts/admin/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Short deleted");
      setDeleteId(null);
    },
    onError: () => toast.error("Delete failed"),
  });

  const openEdit = (s: any) => {
    setEditing(s);
    setForm({
      videoUrl: s.videoUrl ?? "",
      thumbnailUrl: s.thumbnailUrl ?? "",
      caption: s.caption ?? "",
      foodItemId: s.foodItemId ?? "",
      categoryId: s.categoryId ?? "",
      displayOrder: String(s.displayOrder ?? 0),
      isActive: !!s.isActive,
    });
    setOpen(true);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Shorts"
        description="Vertical food videos for the customer Shorts feed, optionally linked to a dish or category."
        actions={
          <Button onClick={() => { setForm(EMPTY); setEditing(null); setOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Publish Short
          </Button>
        }
      />
      <Card>
        <CardContent className="pt-6">
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Short</TableHead>
                  <TableHead>Link</TableHead>
                  <TableHead>Stats</TableHead>
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
                ) : shorts.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6}>
                      <EmptyState title="No shorts" description="Publish a video to fill the customer Shorts feed." />
                    </TableCell>
                  </TableRow>
                ) : (
                  shorts.map((s: any) => {
                    const thumb = resolveImageUrl(s.thumbnailUrl);
                    return (
                      <TableRow key={s.id}>
                        <TableCell>
                          <div className="flex items-center gap-3">
                            {thumb ? (
                              // eslint-disable-next-line @next/next/no-img-element
                              <img src={thumb} alt="" className="h-12 w-9 rounded-md border object-cover" />
                            ) : (
                              <div className="flex h-12 w-9 items-center justify-center rounded-md bg-muted text-xs text-muted-foreground">—</div>
                            )}
                            <div>
                              <p className="max-w-64 truncate text-sm font-medium">{s.caption || "Untitled"}</p>
                              <p className="text-xs text-muted-foreground">{formatDate(s.createdAt)}</p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell className="text-xs">
                          {s.foodItem ? `🍽 ${s.foodItem.name}` : s.category ? `📁 ${s.category.name}` : "—"}
                        </TableCell>
                        <TableCell className="text-xs text-muted-foreground">
                          ♥ {s.likesCount} · ▶ {s.viewsCount}
                        </TableCell>
                        <TableCell>#{s.displayOrder ?? 0}</TableCell>
                        <TableCell>
                          {s.isActive ? <Badge>Live</Badge> : <Badge variant="secondary">Hidden</Badge>}
                          <Switch className="ml-2" checked={!!s.isActive} onCheckedChange={() => toggle.mutate(s)} />
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
            <DialogTitle>{editing ? "Edit Short" : "Publish Short"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <ImageUpload label="Video file *" value={form.videoUrl} onChange={(v) => set("videoUrl", v)} kind="video" accept="video/mp4,video/webm" />
            <div className="space-y-2">
              <Label>…or video URL</Label>
              <Input value={form.videoUrl} onChange={(e) => set("videoUrl", e.target.value)} placeholder="https://…" />
            </div>
            <ImageUpload label="Thumbnail *" value={form.thumbnailUrl} onChange={(v) => set("thumbnailUrl", v)} />
            <div className="space-y-2">
              <Label>Caption</Label>
              <Textarea value={form.caption} onChange={(e) => set("caption", e.target.value)} />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Linked dish</Label>
                <Select value={form.foodItemId || "none"} onValueChange={(v) => set("foodItemId", v === "none" ? "" : v)}>
                  <SelectTrigger><SelectValue placeholder="None" /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">None</SelectItem>
                    {foods.map((f: any) => (
                      <SelectItem key={f.id} value={f.id}>{f.name}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Linked category</Label>
                <Select value={form.categoryId || "none"} onValueChange={(v) => set("categoryId", v === "none" ? "" : v)}>
                  <SelectTrigger><SelectValue placeholder="None" /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">None</SelectItem>
                    {categories.map((c: any) => (
                      <SelectItem key={c.id} value={c.id}>{c.name}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Order</Label>
                <Input type="number" value={form.displayOrder} onChange={(e) => set("displayOrder", e.target.value)} />
              </div>
              <div className="flex items-end gap-2 pb-1">
                <Switch checked={form.isActive} onCheckedChange={(v) => set("isActive", v)} />
                <Label>Active</Label>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.videoUrl || !form.thumbnailUrl}>
              {editing ? "Save" : "Publish"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Short"
        message="It will be removed from the customer feed."
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && remove.mutate(deleteId)}
      />
    </div>
  );
}
