"use client";

import React, { createContext, useContext, useState, useEffect, useCallback } from "react";
import apiClient from "@/lib/api-client";

interface AdminUser {
  id: string;
  email: string;
  name: string;
}

interface AuthContextType {
  user: AdminUser | null;
  token: string | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AdminAuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AdminUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    try {
      const storedToken = localStorage.getItem("admin_token");
      const storedUser = localStorage.getItem("admin_user");
      if (storedToken && storedUser) {
        setToken(storedToken);
        setUser(JSON.parse(storedUser));
      }
    } catch {
      // Corrupt storage must never brick the app — start logged out.
      localStorage.removeItem("admin_token");
      localStorage.removeItem("admin_user");
    }
    setIsLoading(false);
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const response = await apiClient.post("/auth/admin-login", { email, password });
    const { access_token, user: adminUser } = response.data.data;
    localStorage.setItem("admin_token", access_token);
    localStorage.setItem("admin_user", JSON.stringify(adminUser));
    setToken(access_token);
    setUser(adminUser);
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem("admin_token");
    localStorage.removeItem("admin_user");
    setToken(null);
    setUser(null);
    window.location.href = "/login";
  }, []);

  return (
    <AdminAuthContext.Provider value={{ user, token, isLoading, login, logout }}>
      {children}
    </AdminAuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AdminAuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
}
