"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/lib/auth-provider";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  ShoppingCart,
  Users,
  ChefHat,
  Bike,
  UtensilsCrossed,
  FolderTree,
  SlidersHorizontal,
  Image,
  Clapperboard,
  CalendarDays,
  Clock,
  Ticket,
  Star,
  Bell,
  MapPin,
  Wallet,
  FileText,
  Settings,
  ShieldCheck,
  BarChart3,
  ScrollText,
  LogOut,
  Menu,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";

const navSections = [
  {
    title: "Overview",
    items: [
      { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
      { href: "/dashboard/analytics", label: "Analytics / Reports", icon: BarChart3 },
      { href: "/dashboard/audit-logs", label: "Audit Logs", icon: ScrollText },
    ],
  },
  {
    title: "Operations",
    items: [
      { href: "/dashboard/orders", label: "Orders", icon: ShoppingCart },
      { href: "/dashboard/customers", label: "Customers", icon: Users },
      { href: "/dashboard/chefs", label: "Chefs", icon: ChefHat },
      { href: "/dashboard/riders", label: "Delivery / Riders", icon: Bike },
      { href: "/dashboard/reviews", label: "Reviews", icon: Star },
    ],
  },
  {
    title: "Catalog",
    items: [
      { href: "/dashboard/foods", label: "Foods", icon: UtensilsCrossed },
      { href: "/dashboard/categories", label: "Categories", icon: FolderTree },
      { href: "/dashboard/customizations", label: "Customizations", icon: SlidersHorizontal },
      { href: "/dashboard/banners", label: "Banners", icon: Image },
      { href: "/dashboard/shorts", label: "Shorts", icon: Clapperboard },
      { href: "/dashboard/subscriptions", label: "Subscriptions", icon: CalendarDays },
      { href: "/dashboard/delivery-slots", label: "Delivery Slots", icon: Clock },
      { href: "/dashboard/coupons", label: "Coupons", icon: Ticket },
    ],
  },
  {
    title: "Engagement",
    items: [
      { href: "/dashboard/notifications", label: "Notifications", icon: Bell },
      { href: "/dashboard/addresses", label: "Addresses / Places", icon: MapPin },
      { href: "/dashboard/wallet", label: "Wallet / Loyalty", icon: Wallet },
      { href: "/dashboard/app-content", label: "App Content", icon: FileText },
    ],
  },
  {
    title: "System",
    items: [
      { href: "/dashboard/settings", label: "App Settings", icon: Settings },
      { href: "/dashboard/roles", label: "Roles & Permissions", icon: ShieldCheck },
    ],
  },
];

function SidebarContent({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();
  const { logout, user } = useAuth();

  return (
    <div className="flex h-full flex-col bg-sidebar text-sidebar-foreground">
      <div className="flex items-center gap-2 border-b border-white/10 px-6 py-5">
        <UtensilsCrossed className="h-6 w-6 text-sidebar-accent" />
        <span className="text-lg font-bold">Parabdi Admin</span>
      </div>
      <nav className="flex-1 space-y-4 overflow-y-auto px-3 py-4">
        {navSections.map((section) => (
          <div key={section.title}>
            <p className="px-3 pb-1 text-[11px] font-semibold uppercase tracking-wider text-sidebar-foreground/40">
              {section.title}
            </p>
            <div className="space-y-1">
              {section.items.map((item) => {
                const isActive =
                  item.href === "/dashboard"
                    ? pathname === "/dashboard"
                    : pathname.startsWith(item.href);
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={onNavigate}
                    className={cn(
                      "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                      isActive
                        ? "bg-sidebar-accent text-white"
                        : "text-sidebar-foreground/70 hover:bg-white/10 hover:text-white"
                    )}
                  >
                    <item.icon className="h-4 w-4 shrink-0" />
                    {item.label}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>
      <div className="border-t border-white/10 p-4">
        <div className="mb-3 truncate text-xs text-sidebar-foreground/50">
          Signed in as <span className="font-medium text-sidebar-foreground/80">{user?.email}</span>
        </div>
        <Button
          variant="ghost"
          className="w-full justify-start text-sidebar-foreground/70 hover:bg-white/10 hover:text-white"
          onClick={logout}
        >
          <LogOut className="mr-2 h-4 w-4" />
          Logout
        </Button>
      </div>
    </div>
  );
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading, logout } = useAuth();
  const router = useRouter();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push("/login");
    }
  }, [user, isLoading, router]);

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    );
  }

  if (!user) return null;

  return (
    <div className="flex min-h-screen">
      <aside className="hidden w-64 shrink-0 lg:block">
        <div className="sticky top-0 h-screen">
          <SidebarContent />
        </div>
      </aside>

      <Sheet open={open} onOpenChange={setOpen}>
        <SheetTrigger asChild className="fixed left-4 top-4 z-50 lg:hidden">
          <Button variant="outline" size="icon">
            <Menu className="h-5 w-5" />
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-64 p-0">
          <SidebarContent onNavigate={() => setOpen(false)} />
        </SheetContent>
      </Sheet>

      <main className="min-w-0 flex-1 overflow-auto">
        <div className="border-b bg-background px-6 py-3 lg:px-8">
          <div className="flex items-center justify-between">
            <div className="pl-12 lg:pl-0">
              <h1 className="text-lg font-semibold">Welcome, {user?.name || "Admin"}</h1>
            </div>
            <Button variant="ghost" size="sm" onClick={logout}>
              <LogOut className="mr-2 h-4 w-4" />
              Logout
            </Button>
          </div>
        </div>
        <div className="p-6 lg:p-8">{children}</div>
      </main>
    </div>
  );
}
