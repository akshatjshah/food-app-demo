"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { PageHeader } from "@/components/admin/page-header";
import { formatCurrency } from "@/lib/utils";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
} from "recharts";

const PIE_COLORS = ["#3b82f6", "#8b5cf6", "#f59e0b", "#22c55e", "#ef4444", "#14b8a6"];

export default function AnalyticsPage() {
  const [days, setDays] = useState("30");

  const { data: report } = useQuery({
    queryKey: ["reports", days],
    queryFn: async () => (await apiClient.get(`/admin/reports/summary?days=${days}`)).data?.data,
  });

  const { data: byStatus } = useQuery({
    queryKey: ["orders-by-status"],
    queryFn: async () => (await apiClient.get("/admin/dashboard/orders-by-status")).data?.data ?? [],
  });

  const { data: topDishes } = useQuery({
    queryKey: ["top-dishes"],
    queryFn: async () => (await apiClient.get("/admin/dashboard/top-dishes?limit=10")).data?.data ?? [],
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Analytics / Reports"
        description="Every number comes from the database — no hardcoded figures."
        actions={
          <Select value={days} onValueChange={setDays}>
            <SelectTrigger className="w-40">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7">Last 7 days</SelectItem>
              <SelectItem value="30">Last 30 days</SelectItem>
              <SelectItem value="90">Last 90 days</SelectItem>
            </SelectContent>
          </Select>
        }
      />

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {[
          { label: "Orders", value: report?.totalOrders ?? 0 },
          { label: "Revenue", value: formatCurrency(report?.totalRevenue ?? 0) },
          { label: "Avg order value", value: formatCurrency(report?.avgOrderValue ?? 0) },
          { label: "New customers", value: report?.newCustomers ?? 0 },
        ].map((k) => (
          <Card key={k.label}>
            <CardContent className="p-5">
              <p className="text-xs text-muted-foreground">{k.label} ({days}d)</p>
              <p className="text-2xl font-bold">{k.value}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Revenue trend</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={report?.byDay || []}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="date" tick={{ fontSize: 10 }} interval={Math.max(0, Math.floor((report?.byDay?.length ?? 30) / 8))} />
                <YAxis tick={{ fontSize: 10 }} />
                <Tooltip formatter={(v: any) => formatCurrency(Number(v))} />
                <Line type="monotone" dataKey="revenue" stroke="#16a34a" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Orders per day</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={report?.byDay || []}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="date" tick={{ fontSize: 10 }} interval={Math.max(0, Math.floor((report?.byDay?.length ?? 30) / 8))} />
                <YAxis tick={{ fontSize: 10 }} />
                <Tooltip />
                <Bar dataKey="orders" fill="#3b82f6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Orders by status</CardTitle>
          </CardHeader>
          <CardContent>
            {(byStatus?.length ?? 0) > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie data={byStatus} dataKey="count" nameKey="status" innerRadius={60} outerRadius={100} label={({ status, count }: any) => `${status}: ${count}`}>
                    {byStatus.map((_: any, i: number) => (
                      <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <p className="py-16 text-center text-sm text-muted-foreground">No data</p>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Top dishes</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {topDishes?.map((d: any, i: number) => (
                <div key={d.id} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className="flex h-7 w-7 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">{i + 1}</span>
                    <span className="text-sm font-medium">{d.name}</span>
                  </div>
                  <span className="text-sm text-muted-foreground">{d.quantity ?? d.orderCount} sold</span>
                </div>
              ))}
              {(!topDishes || topDishes.length === 0) && <p className="text-sm text-muted-foreground">No sales yet</p>}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
