"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { toast } from "sonner";
import { ShieldCheck } from "lucide-react";

const CAPABILITIES = [
  { key: "orders", label: "Orders" },
  { key: "foods", label: "Foods" },
  { key: "categories", label: "Categories" },
  { key: "customers", label: "Customers" },
  { key: "chefs", label: "Chefs" },
  { key: "riders", label: "Riders" },
  { key: "subscriptions", label: "Subscriptions" },
  { key: "coupons", label: "Coupons" },
  { key: "notifications", label: "Notifications" },
  { key: "settings", label: "Settings" },
  { key: "analytics", label: "Analytics" },
  { key: "audit-logs", label: "Audit logs" },
];

// Route-level enforcement today (RolesGuard on every admin controller).
// The matrix documents which roles may call what; assignment changes take
// effect on next login because JWT validation re-reads the user row.
const MATRIX: Record<string, string[]> = {
  admin: ["orders", "foods", "categories", "customers", "chefs", "riders", "subscriptions", "coupons", "notifications", "settings", "analytics", "audit-logs"],
  chef: ["orders", "foods"],
  delivery: ["orders"],
  customer: [],
};

const ROLE_INFO: Record<string, string> = {
  admin: "Full access. Can manage catalog, orders, staff, settings and audit.",
  chef: "Kitchen app: assigned orders, accept/prepare/ready, food availability.",
  delivery: "Delivery app: assigned deliveries and status updates.",
  customer: "Customer app only. No admin panel access.",
};

export default function RolesPage() {
  const qc = useQueryClient();
  const [roleFilter, setRoleFilter] = useState("all");

  const { data: users = [] } = useQuery({
    queryKey: ["role-users", roleFilter],
    queryFn: async () => {
      if (roleFilter === "chef" || roleFilter === "delivery") {
        const res = await apiClient.get(`/admin/staff?role=${roleFilter}`);
        return (res.data?.data ?? []).map((u: any) => ({ ...u, role: roleFilter }));
      }
      const res = await apiClient.get("/users?take=100");
      const list = res.data?.data ?? [];
      return roleFilter === "all" ? list : list.filter((u: any) => u.role === roleFilter);
    },
  });

  const changeRole = useMutation({
    mutationFn: ({ id, role }: any) => apiClient.patch(`/admin/staff/${id}`, { role }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["role-users"] });
      toast.success("Role updated — enforced by the backend on next request");
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Role change failed"),
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Roles & Permissions"
        description="Authorization is enforced server-side (JWT + role guards). The panel never relies on hiding buttons alone."
      />

      <div className="grid gap-6 lg:grid-cols-2">
        {Object.entries(ROLE_INFO).map(([role, info]) => (
          <Card key={role}>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-base capitalize">
                <ShieldCheck className="h-4 w-4" /> {role}
              </CardTitle>
              <p className="text-xs text-muted-foreground">{info}</p>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-1">
                {MATRIX[role].length === 0 && <span className="text-xs text-muted-foreground">No admin capabilities</span>}
                {MATRIX[role].map((c) => (
                  <Badge key={c} variant="secondary">{c}</Badge>
                ))}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="text-base">Assign staff roles</CardTitle>
            <Select value={roleFilter} onValueChange={setRoleFilter}>
              <SelectTrigger className="w-48">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All roles</SelectItem>
                <SelectItem value="admin">Admins</SelectItem>
                <SelectItem value="chef">Chefs</SelectItem>
                <SelectItem value="delivery">Riders</SelectItem>
                <SelectItem value="customer">Customers</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Current role</TableHead>
                  <TableHead>Capabilities</TableHead>
                  <TableHead className="w-56">Change role</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {users.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5}>
                      <EmptyState title="No users in this role" />
                    </TableCell>
                  </TableRow>
                ) : (
                  users.map((u: any) => (
                    <TableRow key={u.id}>
                      <TableCell className="font-medium">{u.fullName || "—"}</TableCell>
                      <TableCell>{u.phoneNumber}</TableCell>
                      <TableCell><Badge className="capitalize">{u.role}</Badge></TableCell>
                      <TableCell className="max-w-64">
                        <div className="flex flex-wrap gap-1">
                          {(MATRIX[u.role] ?? []).map((c) => (
                            <Badge key={c} variant="outline">{c}</Badge>
                          ))}
                        </div>
                      </TableCell>
                      <TableCell>
                        {(u.role === "chef" || u.role === "delivery") ? (
                          <div className="flex gap-2">
                            <Select
                              defaultValue={u.role}
                              onValueChange={(v) => v !== u.role && changeRole.mutate({ id: u.id, role: v })}
                            >
                              <SelectTrigger><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="chef">Chef</SelectItem>
                                <SelectItem value="delivery">Rider</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                        ) : (
                          <span className="text-xs text-muted-foreground">
                            {u.role === "customer" ? "Promote via Chefs/Riders pages" : "Protected"}
                          </span>
                        )}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
          <div className="mt-3 space-y-1">
            <p className="text-xs font-medium">Capability map</p>
            <div className="grid grid-cols-2 gap-1 sm:grid-cols-4">
              {CAPABILITIES.map((c) => (
                <p key={c.key} className="text-xs text-muted-foreground">
                  <span className="font-medium text-foreground">{c.label}:</span>{" "}
                  {Object.entries(MATRIX).filter(([, caps]) => caps.includes(c.key)).map(([r]) => r).join(", ") || "—"}
                </p>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
