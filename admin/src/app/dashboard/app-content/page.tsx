"use client";

import { useEffect, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import apiClient from "@/lib/api-client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { PageHeader } from "@/components/admin/page-header";
import { toast } from "sonner";
import { Save } from "lucide-react";

const SECTIONS: { key: string; label: string; hint: string; multiline: boolean }[] = [
  { key: "home_promo_text", label: "Home promotional text", hint: "Headline offer strip on customer Home.", multiline: false },
  { key: "subscription_promo_text", label: "Subscription promo", hint: "Banner text on the subscription screen.", multiline: false },
  { key: "about_us", label: "About us", hint: "Shown on the About screen.", multiline: true },
  { key: "contact_info", label: "Contact / support info", hint: "Phone, email, address shown in Help & Support.", multiline: true },
  { key: "faq", label: "Help / FAQ", hint: "Questions and answers, plain text.", multiline: true },
  { key: "terms_display", label: "Terms display text", hint: "Short customer-facing terms summary.", multiline: true },
  { key: "cancellation_policy", label: "Cancellation info", hint: "Customer-facing cancellation rules.", multiline: true },
  { key: "delivery_info", label: "Delivery info", hint: "Customer-facing delivery explainer.", multiline: true },
];

export default function AppContentPage() {
  const qc = useQueryClient();
  const [values, setValues] = useState<Record<string, string>>({});
  const [dirty, setDirty] = useState<Record<string, boolean>>({});

  const { data: settings = [], isLoading } = useQuery({
    queryKey: ["settings"],
    queryFn: async () => (await apiClient.get("/settings")).data?.data ?? [],
  });

  useEffect(() => {
    const map: Record<string, string> = {};
    settings.forEach((s: any) => {
      map[s.key] = s.value;
    });
    setValues((v) => {
      const next = { ...map };
      Object.entries(dirty).forEach(([k, d]) => {
        if (d && v[k] !== undefined) next[k] = v[k];
      });
      return next;
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [settings]);

  const save = useMutation({
    mutationFn: ({ key, value }: { key: string; value: string }) =>
      apiClient.post("/settings", { key, value, valueType: "string" }),
    onSuccess: (_, v) => {
      qc.invalidateQueries({ queryKey: ["settings"] });
      setDirty((d) => ({ ...d, [v.key]: false }));
      toast.success("Content published to the customer app");
    },
    onError: () => toast.error("Save failed"),
  });

  const setVal = (key: string, v: string) => {
    setValues((prev) => ({ ...prev, [key]: v }));
    setDirty((d) => ({ ...d, [key]: true }));
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="App Content"
        description="Only business content is dynamic here — UI labels and buttons stay in the app code."
      />
      {isLoading ? (
        <Card><CardContent className="p-6"><div className="h-40 animate-pulse rounded bg-muted" /></CardContent></Card>
      ) : (
        <div className="grid gap-6 lg:grid-cols-2">
          {SECTIONS.map((s) => (
            <Card key={s.key}>
              <CardHeader>
                <CardTitle className="text-base">{s.label}</CardTitle>
                <p className="text-xs text-muted-foreground">{s.hint} <span className="font-mono">({s.key})</span></p>
              </CardHeader>
              <CardContent className="space-y-3">
                <Label className="sr-only">{s.label}</Label>
                {s.multiline ? (
                  <Textarea rows={5} value={values[s.key] ?? ""} onChange={(e) => setVal(s.key, e.target.value)} />
                ) : (
                  <Input value={values[s.key] ?? ""} onChange={(e) => setVal(s.key, e.target.value)} />
                )}
                <Button
                  size="sm"
                  variant={dirty[s.key] ? "default" : "outline"}
                  disabled={!dirty[s.key] || save.isPending}
                  onClick={() => save.mutate({ key: s.key, value: values[s.key] ?? "" })}
                >
                  <Save className="mr-1 h-3 w-3" /> Publish
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
