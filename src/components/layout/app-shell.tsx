"use client";

import { useState, type ReactNode } from "react";
import { Sidebar, type SidebarNavItem } from "@/components/layout/sidebar";
import { Topbar } from "@/components/layout/topbar";
import { Sheet, SheetContent, SheetTitle } from "@/components/ui/sheet";
import { defaultNavItems } from "@/components/layout/nav-config";

interface AppShellProps {
  navItems?: SidebarNavItem[];
  pageTitle?: string;
  topbarActions?: ReactNode;
  companyName?: string;
  userFullName?: string;
  userEmail?: string;
  children: ReactNode;
}

export function AppShell({
  navItems = defaultNavItems,
  pageTitle,
  topbarActions,
  companyName,
  userFullName,
  userEmail,
  children,
}: AppShellProps) {
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <div className="flex h-dvh overflow-hidden bg-background">
      <div className="hidden lg:block">
        <Sidebar
          items={navItems}
          collapsed={collapsed}
          onCollapsedChange={setCollapsed}
        />
      </div>

      <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
        <SheetContent side="left" className="w-64 border-r-0 bg-sidebar p-0 text-sidebar-foreground">
          <SheetTitle className="sr-only">Menu de navegação</SheetTitle>
          <Sidebar items={navItems} className="border-r-0" />
        </SheetContent>
      </Sheet>

      <div className="flex min-w-0 flex-1 flex-col">
        <Topbar
          title={pageTitle}
          onMenuClick={() => setMobileOpen(true)}
          actions={topbarActions}
          companyName={companyName}
          userFullName={userFullName}
          userEmail={userEmail}
        />
        <main className="flex-1 overflow-y-auto">{children}</main>
      </div>
    </div>
  );
}
