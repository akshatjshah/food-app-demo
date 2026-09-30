"use client";

import StaffPage from "@/components/admin/staff-page";

export default function RidersPage() {
  return (
    <StaffPage
      role="delivery"
      title="Delivery / Riders"
      description="Internal riders. External providers (Borzo/Shiprocket) plug into the same order assignment without changing customer logic."
    />
  );
}
