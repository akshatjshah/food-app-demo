"use client";

import { useEffect } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { io, Socket } from "socket.io-client";

let socket: Socket | null = null;

function socketBaseUrl(): string {
  const api = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api/v1";
  // Socket.IO serves at the server root, not under /api/v1.
  return api.replace(/\/api\/v1\/?$/, "");
}

function getAdminToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("admin_token");
}

export function getOrderSocket(): Socket | null {
  if (typeof window === "undefined") return null;
  const token = getAdminToken();
  if (!token) return null;
  if (socket?.connected) return socket;
  try {
    socket?.disconnect();
  } catch {
    // ignore
  }
  socket = io(socketBaseUrl(), {
    auth: { token },
    transports: ["websocket", "polling"],
    reconnection: true,
    reconnectionAttempts: Infinity,
    reconnectionDelay: 2000,
  });
  return socket;
}

/**
 * Live Admin Orders updates (no refresh, no polling):
 * - `new_order` → new customer order appears in the list automatically.
 * - `order_status_update` ({ orderId, newStatus|status }) → list + open
 *   detail update automatically.
 */
export function useAdminOrdersRealtime(active: boolean = true) {
  const qc = useQueryClient();

  useEffect(() => {
    if (!active) return;
    const s = getOrderSocket();
    if (!s) return;

    const onNewOrder = () => {
      qc.invalidateQueries({ queryKey: ["admin-orders"] });
    };
    const onStatus = (payload: any) => {
      const orderId = payload?.orderId;
      qc.invalidateQueries({ queryKey: ["admin-orders"] });
      if (orderId) {
        qc.invalidateQueries({ queryKey: ["admin-order-detail", orderId] });
      }
    };

    s.on("new_order", onNewOrder);
    s.on("order_status_update", onStatus);
    return () => {
      s.off("new_order", onNewOrder);
      s.off("order_status_update", onStatus);
    };
  }, [qc, active]);
}
