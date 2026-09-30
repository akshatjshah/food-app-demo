"use client";

import StaffPage from "@/components/admin/staff-page";

export default function ChefsPage() {
  return (
    <StaffPage
      role="chef"
      title="Chefs"
      description="Kitchen staff. Chef apps only see orders assigned to them or awaiting acceptance."
    />
  );
}
