"use client";

import { useMemo, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { formatDate } from "@/lib/utils";
import { toast } from "sonner";
import { Search, Eye, EyeOff } from "lucide-react";

export default function ReviewsPage() {
  const [rating, setRating] = useState("all");
  const [foodFilter, setFoodFilter] = useState("all");
  const [search, setSearch] = useState("");
  const qc = useQueryClient();

  const { data: reviews = [], isLoading } = useQuery({
    queryKey: ["reviews"],
    queryFn: async () => (await apiClient.get("/reviews")).data?.data ?? [],
  });

  const filtered = useMemo(() => {
    return reviews.filter((r: any) => {
      if (rating === "approved" && !r.isApproved) return false;
      if (rating === "hidden" && r.isApproved) return false;
      if (rating !== "all" && rating !== "approved" && rating !== "hidden" && r.rating !== Number(rating)) return false;
      if (foodFilter !== "all" && r.foodItemId !== foodFilter) return false;
      if (search) {
        const hay = `${r.comment ?? ""} ${r.user?.fullName ?? ""} ${r.foodItem?.name ?? ""}`.toLowerCase();
        if (!hay.includes(search.toLowerCase())) return false;
      }
      return true;
    });
  }, [reviews, rating, foodFilter, search]);

  const foods = useMemo(() => {
    const m = new Map();
    reviews.forEach((r: any) => {
      if (r.foodItem && !m.has(r.foodItemId)) m.set(r.foodItemId, r.foodItem.name);
    });
    return Array.from(m.entries());
  }, [reviews]);

  const moderate = useMutation({
    mutationFn: ({ id, isApproved }: any) => apiClient.patch(`/reviews/${id}/moderate`, { isApproved }),
    onSuccess: (_, v: any) => {
      qc.invalidateQueries({ queryKey: ["reviews"] });
      toast.success(v.isApproved ? "Review visible to customers" : "Review hidden");
    },
    onError: () => toast.error("Moderation failed"),
  });

  return (
    <div className="space-y-6">
      <PageHeader title="Reviews" description="Customer reviews stay tied to real orders and foods — approve or hide them here." />

      <Card>
        <CardContent className="pt-6">
          <div className="mb-4 flex flex-col gap-3 lg:flex-row">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input placeholder="Search comment, customer, dish…" className="pl-9" value={search} onChange={(e) => setSearch(e.target.value)} />
            </div>
            <Select value={rating} onValueChange={setRating}>
              <SelectTrigger className="w-full lg:w-48">
                <SelectValue placeholder="Rating" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All ratings</SelectItem>
                <SelectItem value="approved">Approved</SelectItem>
                <SelectItem value="hidden">Hidden</SelectItem>
                {[5, 4, 3, 2, 1].map((n) => (
                  <SelectItem key={n} value={String(n)}>{n} ★</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select value={foodFilter} onValueChange={setFoodFilter}>
              <SelectTrigger className="w-full lg:w-56">
                <SelectValue placeholder="Dish" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All dishes</SelectItem>
                {foods.map(([id, name]: any) => (
                  <SelectItem key={id} value={id}>{name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Dish</TableHead>
                  <TableHead>Customer</TableHead>
                  <TableHead>Rating</TableHead>
                  <TableHead>Comment</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="w-16" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  [...Array(5)].map((_, i) => (
                    <TableRow key={i}>
                      {[...Array(7)].map((_, j) => (
                        <TableCell key={j}><div className="h-4 animate-pulse rounded bg-muted" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : filtered.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7}>
                      <EmptyState title="No reviews" description="Reviews appear after customers rate delivered orders." />
                    </TableCell>
                  </TableRow>
                ) : (
                  filtered.map((r: any) => (
                    <TableRow key={r.id}>
                      <TableCell className="font-medium">{r.foodItem?.name || "—"}</TableCell>
                      <TableCell>{r.user?.fullName || "—"}</TableCell>
                      <TableCell>{"★".repeat(r.rating)}<span className="text-muted-foreground">{"★".repeat(5 - r.rating)}</span></TableCell>
                      <TableCell className="max-w-64 truncate">{r.comment || "—"}</TableCell>
                      <TableCell className="text-sm text-muted-foreground">{formatDate(r.createdAt)}</TableCell>
                      <TableCell>
                        <Badge variant={r.isApproved ? "default" : "secondary"}>
                          {r.isApproved ? "Visible" : "Hidden"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Button
                          variant="ghost"
                          size="icon"
                          title={r.isApproved ? "Hide" : "Approve"}
                          onClick={() => moderate.mutate({ id: r.id, isApproved: !r.isApproved })}
                        >
                          {r.isApproved ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4 text-green-600" />}
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
    </div>
  );
}
