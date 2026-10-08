"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { Pagination } from "@/components/admin/pagination";
import { ConfirmDialog } from "@/components/admin/confirm-dialog";
import { resolveImageUrl } from "@/components/admin/image-upload";
import { formatCurrency } from "@/lib/utils";
import { toast } from "sonner";
import { Plus, Pencil, Trash2, Search, X } from "lucide-react";

const ANY = "any";

type Filters = {
  search: string;
  categoryId: string;
  subcategory: string;
  isActive: string;
  isAvailable: string;
  isFeatured: string;
  isBestseller: string;
  mealTag: string;
  hasCustomization: string;
  minPrice: string;
  maxPrice: string;
  sort: string;
};

const DEFAULT_FILTERS: Filters = {
  search: "",
  categoryId: "all",
  subcategory: "all",
  isActive: ANY,
  isAvailable: ANY,
  isFeatured: ANY,
  isBestseller: ANY,
  mealTag: "all",
  hasCustomization: ANY,
  minPrice: "",
  maxPrice: "",
  sort: "recommended",
};

function toParams(f: Filters, page: number, pageSize: number) {
  const p: Record<string, string> = {
    skip: String(page * pageSize),
    take: String(pageSize),
  };
  if (f.search.trim()) p.search = f.search.trim();
  if (f.categoryId !== "all") p.categoryId = f.categoryId;
  if (f.subcategory !== "all") p.subcategory = f.subcategory;
  if (f.isActive !== ANY) p.isActive = f.isActive;
  if (f.isAvailable !== ANY) p.isAvailable = f.isAvailable;
  if (f.isFeatured !== ANY) p.isFeatured = f.isFeatured;
  if (f.isBestseller !== ANY) p.isBestseller = f.isBestseller;
  if (f.mealTag !== "all") p.mealTag = f.mealTag;
  if (f.hasCustomization !== ANY) p.hasCustomization = f.hasCustomization;
  if (f.minPrice !== "") p.minPrice = f.minPrice;
  if (f.maxPrice !== "") p.maxPrice = f.maxPrice;
  if (f.sort !== "recommended") p.sort = f.sort;
  return p;
}

export default function FoodsPage() {
  const router = useRouter();
  const [filters, setFilters] = useState<Filters>(DEFAULT_FILTERS);
  const [page, setPage] = useState(0);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const pageSize = 15;
  const queryClient = useQueryClient();

  const params = toParams(filters, page, pageSize);
  const queryKey = ["foods", params];

  const { data: foods = [], isLoading } = useQuery({
    queryKey,
    queryFn: async () => (await apiClient.get("/foods/admin/all", { params })).data?.data ?? [],
  });

  const { data: categories = [] } = useQuery({
    queryKey: ["categories-list"],
    queryFn: async () => (await apiClient.get("/categories/admin/all")).data?.data ?? [],
  });

  // Subcategory suggestions come from the live dataset (backend-driven).
  const { data: subcatPool = [] } = useQuery({
    queryKey: ["foods-subcategories"],
    queryFn: async () =>
      (await apiClient.get("/foods/admin/all", { params: { take: 500 } })).data?.data ?? [],
    staleTime: 60_000,
  });
  const subcategories = useMemo(() => {
    const set = new Set<string>();
    for (const f of subcatPool as any[]) if (f.subcategory) set.add(f.subcategory);
    return [...set].sort();
  }, [subcatPool]);

  const categoryName = (id: string) => categories.find((c: any) => c.id === id)?.name ?? "—";
  const set = (k: keyof Filters, v: string) => {
    setFilters((f) => ({ ...f, [k]: v }));
    setPage(0);
    setSelected(new Set());
  };
  const activeFilterCount =
    (filters.search.trim() ? 1 : 0) +
    (filters.categoryId !== "all" ? 1 : 0) +
    (filters.subcategory !== "all" ? 1 : 0) +
    (filters.isActive !== ANY ? 1 : 0) +
    (filters.isAvailable !== ANY ? 1 : 0) +
    (filters.isFeatured !== ANY ? 1 : 0) +
    (filters.isBestseller !== ANY ? 1 : 0) +
    (filters.mealTag !== "all" ? 1 : 0) +
    (filters.hasCustomization !== ANY ? 1 : 0) +
    (filters.minPrice !== "" || filters.maxPrice !== "" ? 1 : 0);

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ["foods"] });
    queryClient.invalidateQueries({ queryKey: ["foods-subcategories"] });
  };

  const bulk = useMutation({
    mutationFn: async (payload: { ids: string[]; patch: Record<string, unknown> }) => {
      await Promise.all(payload.ids.map((id) => apiClient.patch(`/foods/${id}`, payload.patch)));
    },
    onSuccess: (_d, v) => {
      invalidate();
      setSelected(new Set());
      toast.success(`Updated ${v.ids.length} item(s)`);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Bulk update failed"),
  });

  const quickToggle = useMutation({
    mutationFn: async ({ id, patch }: { id: string; patch: Record<string, unknown> }) =>
      apiClient.patch(`/foods/${id}`, patch),
    onSuccess: () => invalidate(),
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Update failed"),
  });

  const remove = useMutation({
    mutationFn: async (id: string) => apiClient.delete(`/foods/${id}`),
    onSuccess: () => {
      invalidate();
      toast.success("Food item removed (past orders keep their records)");
      setDeleteId(null);
    },
    onError: (e: any) => toast.error(e?.response?.data?.error?.message || "Delete failed"),
  });

  const toggleSelect = (id: string) =>
    setSelected((s) => {
      const next = new Set(s);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  const allOnPage = foods.map((f: any) => f.id);
  const allChecked = allOnPage.length > 0 && allOnPage.every((id: string) => selected.has(id));

  return (
    <div className="space-y-6">
      <PageHeader
        title="Foods"
        description="Everything the customer sees — filters below query the live dataset, and the pencil opens the full editor."
        actions={
          <Button onClick={() => router.push("/dashboard/foods/new")}>
            <Plus className="mr-2 h-4 w-4" /> Add Food
          </Button>
        }
      />

      <Card>
        <CardContent className="pt-6">
          {/* Filter bar — every control narrows the server query */}
          <div className="mb-4 grid gap-3 md:grid-cols-4">
            <div className="relative md:col-span-2">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Search name or description…"
                className="pl-9"
                value={filters.search}
                onChange={(e) => set("search", e.target.value)}
              />
            </div>
            <Select value={filters.categoryId} onValueChange={(v) => set("categoryId", v)}>
              <SelectTrigger><SelectValue placeholder="All categories" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All categories</SelectItem>
                {categories.map((c: any) => (
                  <SelectItem key={c.id} value={c.id}>{c.name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select value={filters.subcategory} onValueChange={(v) => set("subcategory", v)}>
              <SelectTrigger><SelectValue placeholder="All subcategories" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All subcategories</SelectItem>
                {subcategories.map((s) => (
                  <SelectItem key={s} value={s}>{s}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select value={filters.isActive} onValueChange={(v) => set("isActive", v)}>
              <SelectTrigger><SelectValue placeholder="Active status" /></SelectTrigger>
              <SelectContent>
                <SelectItem value={ANY}>Active: all</SelectItem>
                <SelectItem value="true">Active</SelectItem>
                <SelectItem value="false">Inactive</SelectItem>
              </SelectContent>
            </Select>
            <Select value={filters.isAvailable} onValueChange={(v) => set("isAvailable", v)}>
              <SelectTrigger><SelectValue placeholder="Availability" /></SelectTrigger>
              <SelectContent>
                <SelectItem value={ANY}>Available: all</SelectItem>
                <SelectItem value="true">Available</SelectItem>
                <SelectItem value="false">Unavailable</SelectItem>
              </SelectContent>
            </Select>
            <Select value={filters.isFeatured} onValueChange={(v) => set("isFeatured", v)}>
              <SelectTrigger><SelectValue placeholder="Featured" /></SelectTrigger>
              <SelectContent>
                <SelectItem value={ANY}>Featured: all</SelectItem>
                <SelectItem value="true">Featured</SelectItem>
                <SelectItem value="false">Not featured</SelectItem>
              </SelectContent>
            </Select>
            <Select value={filters.isBestseller} onValueChange={(v) => set("isBestseller", v)}>
              <SelectTrigger><SelectValue placeholder="Bestseller" /></SelectTrigger>
              <SelectContent>
                <SelectItem value={ANY}>Bestseller: all</SelectItem>
                <SelectItem value="true">Bestseller</SelectItem>
                <SelectItem value="false">Not bestseller</SelectItem>
              </SelectContent>
            </Select>
            <Select value={filters.mealTag} onValueChange={(v) => set("mealTag", v)}>
              <SelectTrigger><SelectValue placeholder="Meal" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Meal: all</SelectItem>
                <SelectItem value="breakfast">Breakfast</SelectItem>
                <SelectItem value="lunch">Lunch</SelectItem>
                <SelectItem value="dinner">Dinner</SelectItem>
                <SelectItem value="snacks">Snacks</SelectItem>
              </SelectContent>
            </Select>
            <Select value={filters.hasCustomization} onValueChange={(v) => set("hasCustomization", v)}>
              <SelectTrigger><SelectValue placeholder="Customization" /></SelectTrigger>
              <SelectContent>
                <SelectItem value={ANY}>Customization: all</SelectItem>
                <SelectItem value="true">Has customization</SelectItem>
                <SelectItem value="false">No customization</SelectItem>
              </SelectContent>
            </Select>
            <div className="flex gap-2">
              <Input
                type="number" min="0" placeholder="Min ₹"
                value={filters.minPrice} onChange={(e) => set("minPrice", e.target.value)}
              />
              <Input
                type="number" min="0" placeholder="Max ₹"
                value={filters.maxPrice} onChange={(e) => set("maxPrice", e.target.value)}
              />
            </div>
            <Select value={filters.sort} onValueChange={(v) => set("sort", v)}>
              <SelectTrigger><SelectValue placeholder="Sort" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="recommended">Sort: Recommended</SelectItem>
                <SelectItem value="popular">Sort: Popular</SelectItem>
                <SelectItem value="priceAsc">Sort: Price low → high</SelectItem>
                <SelectItem value="priceDesc">Sort: Price high → low</SelectItem>
                <SelectItem value="nameAsc">Sort: A → Z</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="mb-4 flex flex-wrap items-center gap-2">
            <span className="text-sm text-muted-foreground">
              {foods.length} result(s) on this page{activeFilterCount > 0 ? ` · ${activeFilterCount} filter(s) active` : ""}
            </span>
            {activeFilterCount > 0 && (
              <Button variant="ghost" size="sm" onClick={() => { setFilters(DEFAULT_FILTERS); setPage(0); }}>
                <X className="mr-1 h-3 w-3" /> Clear all
              </Button>
            )}
            {selected.size > 0 && (
              <div className="ml-auto flex flex-wrap gap-2">
                <span className="self-center text-sm font-medium">{selected.size} selected</span>
                <Button size="sm" variant="outline" onClick={() => bulk.mutate({ ids: [...selected], patch: { isActive: true } })}>Activate</Button>
                <Button size="sm" variant="outline" onClick={() => bulk.mutate({ ids: [...selected], patch: { isActive: false } })}>Deactivate</Button>
                <Button size="sm" variant="outline" onClick={() => bulk.mutate({ ids: [...selected], patch: { isAvailable: true } })}>Set available</Button>
                <Button size="sm" variant="outline" onClick={() => bulk.mutate({ ids: [...selected], patch: { isAvailable: false } })}>Set unavailable</Button>
                <Button size="sm" variant="outline" onClick={() => bulk.mutate({ ids: [...selected], patch: { isFeatured: true } })}>★ Featured</Button>
                <Button size="sm" variant="outline" onClick={() => bulk.mutate({ ids: [...selected], patch: { isBestseller: true } })}>Bestseller</Button>
              </div>
            )}
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-10">
                    <input
                      type="checkbox"
                      checked={allChecked}
                      onChange={(e) => setSelected(new Set(e.target.checked ? allOnPage : []))}
                      aria-label="Select all on page"
                      className="h-4 w-4 accent-current"
                    />
                  </TableHead>
                  <TableHead>Food</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Flags</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead>Avail.</TableHead>
                  <TableHead className="w-24">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(6)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(8)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : foods.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8}>
                      <EmptyState title="No foods match these filters" description="Try clearing filters — e.g. active Breakfast foods with customization." />
                    </TableCell>
                  </TableRow>
                ) : (
                  foods.map((food: any) => {
                    const imgs = Array.isArray(food.imageUrls) ? food.imageUrls : [];
                    const thumb = resolveImageUrl(imgs[0]);
                    const groupCount = Array.isArray(food.customizationGroups) ? food.customizationGroups.length : 0;
                    return (
                      <TableRow key={food.id}>
                        <TableCell>
                          <input
                            type="checkbox"
                            checked={selected.has(food.id)}
                            onChange={() => toggleSelect(food.id)}
                            aria-label={`Select ${food.name}`}
                            className="h-4 w-4 accent-current"
                          />
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-3">
                            {thumb ? (
                              // eslint-disable-next-line @next/next/no-img-element
                              <img src={thumb} alt="" className="h-10 w-10 rounded-md border object-cover" />
                            ) : (
                              <div className="flex h-10 w-10 items-center justify-center rounded-md bg-muted text-xs text-muted-foreground">—</div>
                            )}
                            <div>
                              <p className="font-medium">{food.name}</p>
                              <p className="text-xs text-muted-foreground">
                                {food.subcategory || "No subcategory"} · #{food.displayOrder ?? 0}
                                {groupCount > 0 && ` · ${groupCount} option group(s)`}
                              </p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>{food.category?.name || categoryName(food.categoryId)}</TableCell>
                        <TableCell>
                          <div>{formatCurrency(Number(food.price))}</div>
                          {food.originalPrice && (
                            <div className="text-xs text-muted-foreground line-through">{formatCurrency(Number(food.originalPrice))}</div>
                          )}
                        </TableCell>
                        <TableCell>
                          <div className="flex flex-wrap gap-1">
                            {food.isFeatured && <Badge>Featured</Badge>}
                            {food.isBestseller && <Badge variant="secondary">Bestseller</Badge>}
                            {groupCount > 0 && <Badge variant="outline">{groupCount} custom</Badge>}
                          </div>
                        </TableCell>
                        <TableCell>
                          <Switch
                            checked={!!food.isActive}
                            onCheckedChange={(v) => quickToggle.mutate({ id: food.id, patch: { isActive: v } })}
                          />
                        </TableCell>
                        <TableCell>
                          <Switch
                            checked={food.isAvailable !== false}
                            onCheckedChange={(v) => quickToggle.mutate({ id: food.id, patch: { isAvailable: v } })}
                          />
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1">
                            <Button variant="ghost" size="icon" title="Open full editor" onClick={() => router.push(`/dashboard/foods/${food.id}`)}>
                              <Pencil className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="icon" onClick={() => setDeleteId(food.id)}>
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
          <Pagination page={page} pageSize={pageSize} total={foods.length === pageSize ? (page + 1) * pageSize + 1 : page * pageSize + foods.length} onPageChange={setPage} />
        </CardContent>
      </Card>

      <ConfirmDialog
        open={!!deleteId}
        title="Delete Food Item"
        message="The item will be soft-deleted and hidden from customers. Past orders keep their records."
        confirmLabel="Delete"
        danger
        loading={remove.isPending}
        onCancel={() => setDeleteId(null)}
        onConfirm={() => deleteId && remove.mutate(deleteId)}
      />
    </div>
  );
}
