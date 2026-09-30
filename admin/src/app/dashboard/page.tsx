"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { formatCurrency } from "@/lib/utils";
import { StatusBadge } from "@/components/admin/status-badge";
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
} from "recharts";
import {
  ShoppingCart,
  DollarSign,
  CalendarDays,
  Clock,
  BadgeCheck,
  Ban,
  Users,
  UtensilsCrossed,
  ChefHat,
  Bike,
  AlertTriangle,
} from "lucide-react";

const PIE_COLORS = ["#3b82f6", "#8b5cf6", "#f59e0b", "#22c55e", "#ef4444", "#14b8a6", "#a855f7"];

function unwrap<T>(res: any): T {
  return res.data?.data ?? res.data;
}

function Kpi({ title, value, icon: Icon, color, bg }: any) {
  return (
    <Card>
      <CardContent className="flex items-center gap-4 p-5">
        <div className={`flex h-11 w-11 items-center justify-center rounded-lg ${bg}`}>
          <Icon className={`h-5 w-5 ${color}`} />
        </div>
        <div>
          <p className="text-xs text-muted-foreground">{title}</p>
          <p className="text-xl font-bold">{value}</p>
        </div>
      </CardContent>
    </Card>
  );
}

export default function DashboardPage() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ["dashboard-stats"],
    queryFn: async () => unwrap<any>(await apiClient.get("/admin/dashboard")),
  });

  const { data: revenueData } = useQuery({
    queryKey: ["revenue-chart"],
    queryFn: async () => unwrap<any[]>(await apiClient.get("/admin/dashboard/revenue?days=14")),
  });

  const { data: ordersByStatus } = useQuery({
    queryKey: ["orders-by-status"],
    queryFn: async () => unwrap<any[]>(await apiClient.get("/admin/dashboard/orders-by-status")),
  });

  const { data: topDishes } = useQuery({
    queryKey: ["top-dishes"],
    queryFn: async () => unwrap<any[]>(await apiClient.get("/admin/dashboard/top-dishes?limit=8")),
  });

  const { data: recentOrders } = useQuery({
    queryKey: ["recent-orders"],
    queryFn: async () => unwrap<any[]>(await apiClient.get("/admin/dashboard/recent-orders?limit=8")),
  });

  const { data: customers } = useQuery({
    queryKey: ["recent-customers"],
    queryFn: async () => unwrap<any>(await apiClient.get("/admin/customers?take=5")),
  });

  if (isLoading) {
    return (
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {[...Array(8)].map((_, i) => (
          <Card key={i} className="animate-pulse">
            <CardContent className="p-6">
              <div className="h-4 w-24 rounded bg-muted" />
              <div className="mt-2 h-8 w-16 rounded bg-muted" />
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Kpi title="Today's Orders" value={stats?.todayOrders ?? 0} icon={ShoppingCart} color="text-blue-600" bg="bg-blue-100" />
        <Kpi title="Today's Revenue" value={formatCurrency(stats?.revenueToday ?? 0)} icon={DollarSign} color="text-green-600" bg="bg-green-100" />
        <Kpi title="Pending Orders" value={stats?.pendingOrders ?? 0} icon={Clock} color="text-orange-600" bg="bg-orange-100" />
        <Kpi title="Completed Orders" value={stats?.completedOrders ?? 0} icon={BadgeCheck} color="text-emerald-600" bg="bg-emerald-100" />
        <Kpi title="Total Orders" value={stats?.totalOrders ?? 0} icon={ShoppingCart} color="text-indigo-600" bg="bg-indigo-100" />
        <Kpi title="Total Revenue" value={formatCurrency(stats?.totalRevenue ?? 0)} icon={DollarSign} color="text-teal-600" bg="bg-teal-100" />
        <Kpi title="Cancelled Orders" value={stats?.cancelledOrders ?? 0} icon={Ban} color="text-red-600" bg="bg-red-100" />
        <Kpi title="Active Subscriptions" value={stats?.activeSubscriptions ?? 0} icon={CalendarDays} color="text-purple-600" bg="bg-purple-100" />
        <Kpi title="Active Customers" value={stats?.activeCustomers ?? 0} icon={Users} color="text-sky-600" bg="bg-sky-100" />
        <Kpi title="Active Foods" value={stats?.activeFoods ?? 0} icon={UtensilsCrossed} color="text-amber-600" bg="bg-amber-100" />
        <Kpi title="Low-Stock Foods" value={stats?.lowStockFoods ?? 0} icon={AlertTriangle} color="text-rose-600" bg="bg-rose-100" />
        <Kpi title="Chefs / Riders" value={`${stats?.activeChefs ?? 0} / ${stats?.activeRiders ?? 0}`} icon={ChefHat} color="text-slate-600" bg="bg-slate-100" />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Revenue & Orders (Last 14 Days)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={revenueData || []}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="date" className="text-xs" tick={{ fontSize: 10 }} interval={3} />
                <YAxis className="text-xs" tick={{ fontSize: 10 }} />
                <Tooltip formatter={(value: any, name: any) => (name === "revenue" ? formatCurrency(Number(value)) : value)} />
                <Bar dataKey="revenue" fill="#16a34a" radius={[4, 4, 0, 0]} name="revenue" />
                <Bar dataKey="orders" fill="#3b82f6" radius={[4, 4, 0, 0]} name="orders" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Orders by Status</CardTitle>
          </CardHeader>
          <CardContent>
            {(ordersByStatus?.length ?? 0) > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={ordersByStatus || []}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={100}
                    dataKey="count"
                    nameKey="status"
                    label={({ status, count }: any) => `${String(status).replace(/_/g, " ")}: ${count}`}
                  >
                    {(ordersByStatus || []).map((_: any, index: number) => (
                      <Cell key={index} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <p className="py-16 text-center text-sm text-muted-foreground">No orders yet</p>
            )}
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle>Top Dishes</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {topDishes?.map((dish: any, index: number) => (
                <div key={dish.id} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className="flex h-7 w-7 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">
                      {index + 1}
                    </span>
                    <span className="text-sm font-medium">{dish.name}</span>
                  </div>
                  <span className="text-sm text-muted-foreground">{dish.orderCount} orders</span>
                </div>
              ))}
              {(!topDishes || topDishes.length === 0) && (
                <p className="text-sm text-muted-foreground">No data available</p>
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>Recent Orders</CardTitle>
              <Link href="/dashboard/orders" className="text-xs font-medium text-primary hover:underline">
                View all
              </Link>
            </div>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Order #</TableHead>
                  <TableHead>Total</TableHead>
                  <TableHead>Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {recentOrders?.map((order: any) => (
                  <TableRow key={order.id}>
                    <TableCell>
                      <div className="font-mono text-xs">{order.orderNumber}</div>
                      <div className="text-xs text-muted-foreground">{order.customerName || "Guest"}</div>
                    </TableCell>
                    <TableCell>{formatCurrency(order.total)}</TableCell>
                    <TableCell>
                      <StatusBadge status={order.status} />
                    </TableCell>
                  </TableRow>
                ))}
                {(!recentOrders || recentOrders.length === 0) && (
                  <TableRow>
                    <TableCell colSpan={3} className="text-center text-muted-foreground">
                      No recent orders
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>Recent Customers</CardTitle>
              <Link href="/dashboard/customers" className="text-xs font-medium text-primary hover:underline">
                View all
              </Link>
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {(customers?.data || []).map((c: any) => (
                <div key={c.id} className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium">{c.fullName || "Unnamed"}</p>
                    <p className="text-xs text-muted-foreground">{c.phoneNumber}</p>
                  </div>
                  <span className="text-xs text-muted-foreground">{c.orderCount} orders</span>
                </div>
              ))}
              {(!customers?.data || customers.data.length === 0) && (
                <p className="text-sm text-muted-foreground">No customers yet</p>
              )}
            </div>
            <div className="mt-4 flex items-center gap-2 text-xs text-muted-foreground">
              <Bike className="h-3 w-3" /> Riders active: {stats?.activeRiders ?? 0}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
