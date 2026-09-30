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
import { Save, MapPin } from "lucide-react";

export default function AddressesPage() {
  const qc = useQueryClient();
  const [values, setValues] = useState<Record<string, string>>({ serviceable_cities: "", delivery_zones: "" });
  const [dirty, setDirty] = useState<Record<string, boolean>>({});

  const { data: settings = [] } = useQuery({
    queryKey: ["settings"],
    queryFn: async () => (await apiClient.get("/settings")).data?.data ?? [],
  });

  useEffect(() => {
    const map: Record<string, string> = {};
    settings.forEach((s: any) => {
      if (s.key === "serviceable_cities" || s.key === "delivery_zones") map[s.key] = s.value;
    });
    setValues((v) => {
      const next = { ...map };
      (Object.keys(dirty) as string[]).forEach((k) => {
        if (dirty[k] && v[k] !== undefined) next[k] = v[k];
      });
      return { serviceable_cities: next.serviceable_cities ?? "", delivery_zones: next.delivery_zones ?? "" };
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [settings]);

  const save = useMutation({
    mutationFn: ({ key, value }: { key: string; value: string }) =>
      apiClient.post("/settings", { key, value, valueType: "string" }),
    onSuccess: (_, v) => {
      qc.invalidateQueries({ queryKey: ["settings"] });
      setDirty((d) => ({ ...d, [v.key]: false }));
      toast.success("Service area updated");
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
        title="Addresses / Places"
        description="Customer addresses live on their accounts and orders. Here you configure where you deliver — no city is hardcoded in app logic."
      />

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <MapPin className="h-4 w-4" /> Serviceable cities
            </CardTitle>
            <p className="text-xs text-muted-foreground">
              Comma-separated list, e.g. <span className="font-mono">Ahmedabad, Gandhinagar</span> <span className="font-mono">(serviceable_cities)</span>
            </p>
          </CardHeader>
          <CardContent className="space-y-3">
            <Label className="sr-only">Serviceable cities</Label>
            <Textarea
              rows={3}
              value={values.serviceable_cities}
              onChange={(e) => setVal("serviceable_cities", e.target.value)}
            />
            <Button
              size="sm"
              variant={dirty.serviceable_cities ? "default" : "outline"}
              disabled={!dirty.serviceable_cities || save.isPending}
              onClick={() => save.mutate({ key: "serviceable_cities", value: values.serviceable_cities })}
            >
              <Save className="mr-1 h-3 w-3" /> Save
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <MapPin className="h-4 w-4" /> Delivery zones
            </CardTitle>
            <p className="text-xs text-muted-foreground">
              Area / pincode rules, one per line <span className="font-mono">(delivery_zones)</span>
            </p>
          </CardHeader>
          <CardContent className="space-y-3">
            <Label className="sr-only">Delivery zones</Label>
            <Textarea
              rows={3}
              value={values.delivery_zones}
              onChange={(e) => setVal("delivery_zones", e.target.value)}
              placeholder={"380001 - Navrangpura\n380015 - Satellite"}
            />
            <Button
              size="sm"
              variant={dirty.delivery_zones ? "default" : "outline"}
              disabled={!dirty.delivery_zones || save.isPending}
              onClick={() => save.mutate({ key: "delivery_zones", value: values.delivery_zones })}
            >
              <Save className="mr-1 h-3 w-3" /> Save
            </Button>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Lookup & geocoding</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <Label>Search places (proxy)</Label>
          <div className="flex gap-2">
            <Input id="places-q" placeholder="Type an area or landmark…" />
            <Button
              variant="outline"
              onClick={async () => {
                const q = (document.getElementById("places-q") as HTMLInputElement)?.value;
                if (!q) return;
                try {
                  const res = await apiClient.get(`/places/search?query=${encodeURIComponent(q)}`);
                  toast.success(`Found ${(res.data?.data?.length ?? res.data?.length ?? 0)} result(s) — see console`);
                  console.log("places/search", res.data);
                } catch {
                  toast.error("Places lookup is not configured");
                }
              }}
            >
              Search
            </Button>
          </div>
          <p className="text-xs text-muted-foreground">
            Customer address search and reverse-geocoding go through the backend places proxy, so keys stay server-side.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
