"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-provider";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { UtensilsCrossed } from "lucide-react";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [redirecting, setRedirecting] = useState(false);
  const { login, user, isLoading: authLoading } = useAuth();
  const router = useRouter();

  // Compile/dashboard chunks while the user types, so post-login
  // navigation is instant even when the dev server compiles on demand.
  useEffect(() => {
    router.prefetch("/dashboard");
  }, [router]);

  // If already authenticated (e.g. token restored from storage),
  // don't sit on the login form — go to the dashboard.
  useEffect(() => {
    if (!authLoading && user) {
      setRedirecting(true);
      router.replace("/dashboard");
    }
  }, [authLoading, user, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login(email, password);
      toast.success("Logged in successfully");
      // Keep the form disabled until navigation completes; otherwise the
      // login button re-enables while the dashboard route is still loading
      // and it looks like the login went nowhere.
      setRedirecting(true);
      router.replace("/dashboard");
    } catch (err: any) {
      toast.error(err?.response?.data?.error?.message || "Invalid credentials");
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/30">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1 text-center">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
            <UtensilsCrossed className="h-6 w-6 text-primary" />
          </div>
          <CardTitle className="text-2xl font-bold">Parabdi Admin</CardTitle>
          <CardDescription>Sign in to manage your restaurant</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Email</label>
              <Input
                type="email"
                placeholder="admin@parabdi.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Password</label>
              <Input
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading || redirecting}>
              {redirecting ? "Redirecting to dashboard..." : loading ? "Signing in..." : "Sign In"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
