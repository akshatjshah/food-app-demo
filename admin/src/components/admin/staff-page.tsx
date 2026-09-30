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
import { formatDate } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Search } from "lucide-react";

export default function StaffPage({
  role,
  title,
  description,
}: {
  role: "chef" | "delivery";
  title: string;
  description: string;
}) {
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [form, setForm] = useState({ fullName: "", phoneNumber: "", email: "", isBlocked: false });
  const qc = useQueryClient();

  const { data: staff = [], isLoading } = useQuery({
    queryKey: ["staff", role, search],
    queryFn: async () => {
      const params = new URLSearchParams({ role });
      if (search) params.set("search", search);
      const res = await apiClient.get(`/admin/staff?${params.toString()}`);
      return res.data?.data ?? [];
    },
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ["staff", role] });
  const set = (k: keyof typeof form, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const save = useMutation({
    mutationFn: async () => {
      if (editing) {
        await apiClient.patch(`/admin/staff/${editing.id}`, {
          fullName: form.fullName,
          email: form.email || undefined,
          isBlocked: form.isBlocked,
        });
      } else {
        await apiClient.post("/admin/staff", {
          fullName: form.fullName.trim(),
          phoneNumber: form.phoneNumber.trim(),
          email: form.email || undefined,
          role,
        });
      }
    },
    onSuccess: () => {
      invalidate();
      toast.success(editing ? "Updated" : `${role === "chef" ? "Chef" : "Rider"} added`);
      setOpen(false);
      setEditing(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Save failed"),
  });

  const openEdit = (s: any) => {
    setEditing(s);
    setForm({ fullName: s.fullName ?? "", phoneNumber: s.phoneNumber ?? "", email: s.email ?? "", isBlocked: !!s.isBlocked });
    setOpen(true);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title={title}
        description={description}
        actions={
          <Button onClick={() => { setEditing(null); setForm({ fullName: "", phoneNumber: "", email: "", isBlocked: false }); setOpen(true); }}>
            <Plus className="mr-2 h-4 w-4" /> Add {role === "chef" ? "Chef" : "Rider"}
          </Button>
        }
      />
      <Card>
        <CardContent className="pt-6">
          <div className="relative mb-4 max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="Search name or phone…" className="pl-9" value={search} onChange={(e) => setSearch(e.target.value)} />
          </div>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Active orders</TableHead>
                  <TableHead>Completed</TableHead>
                  <TableHead>Since</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="w-16" />
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
                ) : staff.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7}>
                      <EmptyState title={`No ${role === "chef" ? "chefs" : "riders"}`} description="Add staff so orders can be assigned." />
                    </TableCell>
                  </TableRow>
                ) : (
                  staff.map((s: any) => (
                    <TableRow key={s.id}>
                      <TableCell className="font-medium">{s.fullName || "—"}</TableCell>
                      <TableCell>{s.phoneNumber}</TableCell>
                      <TableCell>{s.activeOrders ?? 0}</TableCell>
                      <TableCell>{s.completedOrders ?? 0}</TableCell>
                      <TableCell className="text-sm text-muted-foreground">{formatDate(s.createdAt)}</TableCell>
                      <TableCell>
                        <Badge variant={s.isBlocked ? "destructive" : "default"}>
                          {s.isBlocked ? "Inactive" : "Active"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Button variant="ghost" size="icon" onClick={() => openEdit(s)}>
                          <Pencil className="h-4 w-4" />
                        </Button>
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
            <DialogTitle>{editing ? "Edit" : `Add ${role === "chef" ? "Chef" : "Rider"}`}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Name *</Label>
              <Input value={form.fullName} onChange={(e) => set("fullName", e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Phone *</Label>
              <Input value={form.phoneNumber} onChange={(e) => set("phoneNumber", e.target.value)} disabled={!!editing} placeholder="+91…" />
            </div>
            <div className="space-y-2">
              <Label>Email</Label>
              <Input value={form.email} onChange={(e) => set("email", e.target.value)} />
            </div>
            {editing && (
              <div className="flex items-center gap-2">
                <Switch checked={!form.isBlocked} onCheckedChange={(v) => set("isBlocked", !v)} />
                <Label>Active</Label>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate()} disabled={save.isPending || !form.fullName || (!editing && !form.phoneNumber)}>
              {editing ? "Save" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
