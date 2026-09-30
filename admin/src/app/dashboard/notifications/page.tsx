"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { formatDateTime } from "@/lib/utils";
import { toast } from "sonner";
import { Send } from "lucide-react";

export default function NotificationsPage() {
  const [form, setForm] = useState({ title: "", body: "", type: "ANNOUNCEMENT", userIds: "" });
  const qc = useQueryClient();

  const { data: recent = [] } = useQuery({
    queryKey: ["recent-notifications"],
    queryFn: async () => (await apiClient.get("/admin/notifications/recent?take=50")).data?.data ?? [],
  });

  const send = useMutation({
    mutationFn: async () => {
      const userIds = form.userIds ? form.userIds.split(",").map((s) => s.trim()).filter(Boolean) : undefined;
      await apiClient.post("/admin/notifications/broadcast", {
        title: form.title.trim(),
        body: form.body.trim(),
        type: form.type,
        userIds,
      });
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["recent-notifications"] });
      toast.success("Notification sent — customer inboxes receive it");
      setForm({ title: "", body: "", type: "ANNOUNCEMENT", userIds: "" });
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Send failed"),
  });

  const set = (k: keyof typeof form, v: string) => setForm((f) => ({ ...f, [k]: v }));

  return (
    <div className="space-y-6">
      <PageHeader title="Notifications" description="Broadcast to all customers or a selected set — delivered to the customer inbox (and push where configured)." />

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Compose broadcast</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>Title *</Label>
              <Input value={form.title} onChange={(e) => set("title", e.target.value)} placeholder="Diwali offer is live" />
            </div>
            <div className="space-y-2">
              <Label>Message *</Label>
              <Textarea value={form.body} onChange={(e) => set("body", e.target.value)} placeholder="Flat 20% off thalis this weekend…" />
            </div>
            <div className="space-y-2">
              <Label>Type</Label>
              <Select value={form.type} onValueChange={(v) => set("type", v)}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="ANNOUNCEMENT">Announcement</SelectItem>
                  <SelectItem value="OFFER">Offer</SelectItem>
                  <SelectItem value="MENU_UPDATE">Menu update</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Target user IDs (blank = all customers)</Label>
              <Textarea value={form.userIds} onChange={(e) => set("userIds", e.target.value)} placeholder="uuid1, uuid2" />
            </div>
            <Button onClick={() => send.mutate()} disabled={send.isPending || !form.title || !form.body}>
              <Send className="mr-2 h-4 w-4" /> Send notification
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recently delivered</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Title</TableHead>
                    <TableHead>To</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Sent</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {recent.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={4}>
                        <EmptyState title="Nothing sent yet" />
                      </TableCell>
                    </TableRow>
                  ) : (
                    recent.map((n: any) => (
                      <TableRow key={n.id}>
                        <TableCell>
                          <p className="text-sm font-medium">{n.title}</p>
                          <p className="max-w-48 truncate text-xs text-muted-foreground">{n.body}</p>
                        </TableCell>
                        <TableCell className="text-xs">{n.user?.fullName || n.user?.phoneNumber || "—"}</TableCell>
                        <TableCell><Badge variant="outline">{n.type}</Badge></TableCell>
                        <TableCell className="text-xs text-muted-foreground">{formatDateTime(n.createdAt)}</TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
