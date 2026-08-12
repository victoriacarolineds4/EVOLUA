import { redirect } from "next/navigation";
import type { ReactNode } from "react";
import { createClient } from "@/lib/supabase/server";
import { AppShell } from "@/components/layout/app-shell";
import { getProfileWithCompany } from "@/services/profile.service";

export default async function DashboardLayout({ children }: { children: ReactNode }) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const profile = await getProfileWithCompany(user.id);

  return (
    <AppShell
      userEmail={user.email}
      userFullName={profile?.full_name ?? undefined}
      companyName={profile?.company?.name ?? undefined}
    >
      {children}
    </AppShell>
  );
}
