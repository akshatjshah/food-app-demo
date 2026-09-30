"use client";

import { useEffect, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { PageHeader } from "@/components/admin/page-header";
import { toast } from "sonner";
import { Save, ShieldAlert } from "lucide-react";

const GROUPS: { title: string; keys: { key: string; label: string; kind: "text" | "number" | "bool" | "textarea" }[] }[] = [
  {
    title: "Ordering & Fees",
    keys: [
      { key: "delivery_fee", label: "Delivery fee (₹)", kind: "number" },
      { key: "min_order_value", label: "Minimum order (₹)", kind: "number" },
      { key: "platform_fee", label: "Platform fee (₹)", kind: "number" },
      { key: "tax_rate", label: "Tax rate (e.g. 0.05)", kind: "number" },
      { key: "service_availability", label: "Service available", kind: "bool" },
      { key: "cod_enabled", label: "Cash on delivery", kind: "bool" },
      { key: "razorpay_enabled", label: "Razorpay online payments", kind: "bool" },
    ],
  },
  {
    title: "Business & Support",
    keys: [
      { key: "business_hours", label: "Business hours", kind: "text" },
      { key: "support_phone", label: "Support phone", kind: "text" },
      { key: "support_email", label: "Support email", kind: "text" },
      { key: "cancellation_policy", label: "Cancellation rules", kind: "textarea" },
      { key: "delivery_info", label: "Delivery information", kind: "textarea" },
      { key: "app_notice", label: "App-wide notice (blank = none)", kind: "textarea" },
    ],
  },
];

function parseValue(raw: string | undefined, kind: string) {
  if (raw == null || raw === "") return kind === "bool" ? false : "";
  if (kind === "bool") return raw === "true" || raw === "1";
  return raw;
}

export default function SettingsPage() {
  const qc = useQueryClient();
  const [values, setValues] = useState<Record<string, any>>({});
  const [dirty, setDirty] = useState<Record<string, boolean>>({});

  const { data: settings = [], isLoading } = useQuery({
    queryKey: ["settings"],
    queryFn: async () => (await apiClient.get("/settings")).data?.data ?? [],
  });

  useEffect(() => {
    const map: Record<string, any> = {};
    settings.forEach((s: any) => {
      map[s.key] = s.value;
    });
    setValues((v) => ({ ...map, ...Object.fromEntries(Object.entries(dirty).filter(([, d]) => d).map(([k]) => [k, v[k]])) }));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [settings]);

  const save = useMutation({
    mutationFn: async ({ key, value }: { key: string; value: string }) =>
      apiClient.post("/settings", { key, value: String(value), valueType: "string" }),
    onSuccess: (_, v) => {
      qc.invalidateQueries({ queryKey: ["settings"] });
      setDirty((d) => ({ ...d, [v.key]: false }));
      toast.success("Setting saved — customer app reads the new value");
    },
    onError: () => toast.error("Save failed"),
  });

  const setVal = (key: string, v: any) => {
    setValues((prev) => ({ ...prev, [key]: v }));
    setDirty((d) => ({ ...d, [key]: true }));
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="App Settings"
        description="Global business rules. Secrets and OTP data are never listed here."
      />
      <div className="flex items-start gap-2 rounded-lg border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
        <ShieldAlert className="mt-0.5 h-4 w-4 shrink-0" />
        Pricing and availability set here should match backend order logic. Changing fees affects new orders immediately.
      </div>

      {isLoading ? (
        <Card><CardContent className="p-6"><div className="h-40 animate-pulse rounded bg-muted" /></CardContent></Card>
      ) : (
        GROUPS.map((g) => (
          <Card key={g.title}>
            <CardHeader>
              <CardTitle className="text-base">{g.title}</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2">
              {g.keys.map(({ key, label, kind }) => {
                const val = values[key] ?? (kind === "bool" ? false : "");
                const isDirty = !!dirty[key];
                return (
                  <div key={key} className={kind === "textarea" ? "space-y-2 sm:col-span-2" : "space-y-2"}>
                    <Label>{label} <span className="font-mono text-xs text-muted-foreground">({key})</span></Label>
                    <div className="flex items-center gap-2">
                      {kind === "bool" ? (
                        <Switch checked={parseValue(val, kind) === true} onCheckedChange={(v) => setVal(key, v)} />
                      ) : kind === "textarea" ? (
                        <Textarea className="flex-1" value={val ?? ""} onChange={(e) => setVal(key, e.target.value)} />
                      ) : (
                        <Input
                          className="flex-1"
                          type={kind === "number" ? "number" : "text"}
                          value={val ?? ""}
                          onChange={(e) => setVal(key, e.target.value)}
                        />
                      )}
                      <Button
                        size="sm"
                        variant={isDirty ? "default" : "outline"}
                        disabled={!isDirty || save.isPending}
                        onClick={() => save.mutate({ key, value: kind === "bool" ? String(!!val) : (val ?? "") })}
                      >
                        <Save className="mr-1 h-3 w-3" /> Save
                      </Button>
                    </div>
                  </div>
                );
              })}
            </CardContent>
          </Card>
        ))
      )}
    </div>
  );
}
