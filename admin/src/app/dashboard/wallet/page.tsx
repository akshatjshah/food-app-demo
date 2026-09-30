"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { PageHeader } from "@/components/admin/page-header";
import { EmptyState } from "@/components/admin/empty-state";
import { Pagination } from "@/components/admin/pagination";
import { formatCurrency, formatDateTime } from "@/lib/utils";
import { Search } from "lucide-react";

export default function WalletPage() {
  const [search, setSearch] = useState("");
  const [applied, setApplied] = useState("");
  const [page, setPage] = useState(0);
  const [loyaltyPage, setLoyaltyPage] = useState(0);
  const pageSize = 15;

  const walletQuery = (path: string, pg: number) => {
    const params = new URLSearchParams({ skip: String(pg * pageSize), take: String(pageSize) });
    if (applied) params.set("search", applied);
    return apiClient.get(`${path}?${params.toString()}`).then((r) => r.data?.data ?? { data: [], total: 0 });
  };

  const { data: wallet } = useQuery({
    queryKey: ["wallet-tx", applied, page],
    queryFn: () => walletQuery("/admin/wallet/transactions", page),
  });

  const { data: loyalty } = useQuery({
    queryKey: ["loyalty-tx", applied, loyaltyPage],
    queryFn: () => walletQuery("/admin/loyalty/transactions", loyaltyPage),
  });

  return (
    <div className="space-y-6">
      <PageHeader title="Wallet / Loyalty" description="Transaction ledger and balances. Adjustments are audited — manual edits happen only through support flows." />

      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          placeholder="Search description, name, phone… (Enter)"
          className="pl-9"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && (setApplied(search), setPage(0), setLoyaltyPage(0))}
        />
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Wallet transactions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Customer</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {(wallet?.data?.length ?? 0) === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5}>
                      <EmptyState title="No wallet activity" />
                    </TableCell>
                  </TableRow>
                ) : (
                  wallet.data.map((t: any) => (
                    <TableRow key={t.id}>
                      <TableCell>{t.user?.fullName || t.user?.phoneNumber || "—"}</TableCell>
                      <TableCell>
                        <Badge variant={t.type === "credit" ? "default" : "secondary"}>{t.type}</Badge>
                      </TableCell>
                      <TableCell className={t.type === "credit" ? "text-green-600" : ""}>
                        {t.type === "credit" ? "+" : "−"}{formatCurrency(Number(t.amount))}
                      </TableCell>
                      <TableCell className="max-w-64 truncate text-sm text-muted-foreground">{t.description}</TableCell>
                      <TableCell className="text-xs text-muted-foreground">{formatDateTime(t.createdAt)}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
          <Pagination page={page} pageSize={pageSize} total={wallet?.total ?? 0} onPageChange={setPage} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Loyalty points ledger</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Customer</TableHead>
                  <TableHead>Points</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {(loyalty?.data?.length ?? 0) === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5}>
                      <EmptyState title="No loyalty activity" />
                    </TableCell>
                  </TableRow>
                ) : (
                  loyalty.data.map((t: any) => (
                    <TableRow key={t.id}>
                      <TableCell>{t.user?.fullName || t.user?.phoneNumber || "—"}</TableCell>
                      <TableCell className="font-medium">{t.points}</TableCell>
                      <TableCell><Badge variant="outline">{t.transactionType}</Badge></TableCell>
                      <TableCell className="max-w-64 truncate text-sm text-muted-foreground">{t.description}</TableCell>
                      <TableCell className="text-xs text-muted-foreground">{formatDateTime(t.createdAt)}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
          <Pagination page={loyaltyPage} pageSize={pageSize} total={loyalty?.total ?? 0} onPageChange={setLoyaltyPage} />
        </CardContent>
      </Card>
    </div>
  );
}
