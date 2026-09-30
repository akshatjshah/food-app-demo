"use client";

import { useState } from "react";
import apiClient from "@/lib/api-client";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { Upload, X, Loader2 } from "lucide-react";

const API_BASE =
  (process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api/v1").replace(/\/api\/v1$/, "");

/** Resolves a stored image ref to a loadable URL (absolute, /uploads/..., or bare filename). */
export function resolveImageUrl(ref?: string | null): string | null {
  if (!ref) return null;
  if (ref.startsWith("http://") || ref.startsWith("https://")) return ref;
  if (ref.startsWith("/uploads/")) return `${API_BASE}${ref}`;
  if (ref.startsWith("/")) return `${API_BASE}${ref}`;
  return `${API_BASE}/uploads/${ref}`;
}

export function ImageUpload({
  value,
  onChange,
  label = "Image",
  kind = "image",
  accept = "image/jpeg,image/png,image/webp,image/gif",
}: {
  value?: string;
  onChange: (url: string) => void;
  label?: string;
  kind?: "image" | "video";
  accept?: string;
}) {
  const [uploading, setUploading] = useState(false);
  const preview = resolveImageUrl(value);

  const handleFile = async (file: File | undefined) => {
    if (!file) return;
    const form = new FormData();
    form.append("file", file);
    setUploading(true);
    try {
      const res = await apiClient.post(`/media/upload?kind=${kind}`, form, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      const url = res.data?.data?.url as string;
      onChange(url);
      toast.success("Image uploaded");
    } catch (e: any) {
      toast.error(e?.response?.data?.error?.message || "Upload failed");
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="space-y-2">
      <Label>{label}</Label>
      {preview && kind === "image" && (
        <div className="relative inline-block">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={preview} alt="preview" className="h-24 w-24 rounded-lg border object-cover" />
          <Button
            type="button"
            variant="destructive"
            size="icon"
            className="absolute -right-2 -top-2 h-6 w-6 rounded-full"
            onClick={() => onChange("")}
          >
            <X className="h-3 w-3" />
          </Button>
        </div>
      )}
      {value && kind === "video" && (
        <p className="truncate text-xs text-muted-foreground">{value}</p>
      )}
      <div className="flex items-center gap-2">
        <Input type="file" accept={accept} disabled={uploading} onChange={(e) => handleFile(e.target.files?.[0])} />
        {uploading && <Loader2 className="h-4 w-4 animate-spin" />}
      </div>
      <div className="flex items-center gap-2">
        <Input
          placeholder="…or paste image URL"
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
        />
      </div>
      <p className="flex items-center gap-1 text-xs text-muted-foreground">
        <Upload className="h-3 w-3" /> Uploads to backend media storage; the customer app loads the same URL.
      </p>
    </div>
  );
}
