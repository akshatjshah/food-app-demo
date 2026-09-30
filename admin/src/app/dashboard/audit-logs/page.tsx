"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { Pagination } from "@/components/admin/pagination";
import { formatDateTime } from "@/lib/utils";
import { Search } from "lucide-react";

export default function AuditLogsPage() {
  const [entity, setEntity] = useState("all");
  const [search, setSearch] = useState("");
  const [applied, setApplied] = useState("");
  const [page, setPage] = useState(0);
  const pageSize = 20;

  const { data, isLoading } = useQuery({
    queryKey: ["audit-logs", entity, applied, page],
    queryFn: async () => {
      const params = new URLSearchParams({ skip: String(page * pageSize), take: String(pageSize) });
      if (entity !== "all") params.set("entity", entity);
      if (applied) params.set("search", applied);
      const res = await apiClient.get(`/admin/audit-logs?${params.toString()}`);
      return res.data?.data ?? { data: [], total: 0 };
    },
  });
  const logs = data?.data ?? [];
  const total = data?.total ?? 0;

  return (
    <div className="space-y-6">
      <PageHeader title="Audit Logs" description="Every admin mutation is recorded — who changed what, and when. Secrets are never logged." />

      <Card>
        <CardContent className="pt-6">
          <div className="mb-4 flex flex-col gap-3 sm:flex-row">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Search entity ID or admin name… (Enter)"
                className="pl-9"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && (setApplied(search), setPage(0))}
              />
            </div>
            <Select value={entity} onValueChange={(v) => { setEntity(v); setPage(0); }}>
              <SelectTrigger className="w-full sm:w-56">
                <SelectValue placeholder="Entity" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All entities</SelectItem>
                {["order", "food_items", "foods", "categories", "user", "coupons", "banners", "shorts", "subscriptions", "delivery_slots", "settings", "notifications"].map((e) => (
                  <SelectItem key={e} value={e}>{e}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Time</TableHead>
                  <TableHead>Admin</TableHead>
                  <TableHead>Action</TableHead>
                  <TableHead>Entity</TableHead>
                  <TableHead>Entity ID</TableHead>
                  <TableHead>Change</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(6)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(6)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : logs.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6}>
                      <EmptyState title="No audit entries" description="Admin price changes, blocks, status moves and coupon creates will appear here." />
                    </TableCell>
                  </TableRow>
                ) : (
                  logs.map((l: any) => (
                    <TableRow key={l.id}>
                      <TableCell className="whitespace-nowrap text-xs text-muted-foreground">{formatDateTime(l.createdAt)}</TableCell>
                      <TableCell className="text-sm">{l.admin?.fullName || l.admin?.email || l.adminId?.slice(0, 8)}</TableCell>
                      <TableCell><Badge variant="outline">{l.action}</Badge></TableCell>
                      <TableCell className="text-sm">{l.entity}</TableCell>
                      <TableCell className="font-mono text-xs">{l.entityId?.slice(0, 8) ?? "—"}</TableCell>
                      <TableCell className="max-w-72 truncate text-xs text-muted-foreground">
                        {l.oldValue || l.newValue ? JSON.stringify({ from: l.oldValue, to: l.newValue }).slice(0, 120) : "—"}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
          <Pagination page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
        </CardContent>
      </Card>
    </div>
  );
}
