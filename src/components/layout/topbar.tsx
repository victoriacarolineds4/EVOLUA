"use client";

import { Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import { UserMenu } from "@/components/layout/user-menu";
import { cn } from "@/lib/utils";

interface TopbarProps {
  title?: string;
  onMenuClick?: () => void;
  actions?: React.ReactNode;
  companyName?: string;
  userFullName?: string;
  userEmail?: string;
  className?: string;
}

export function Topbar({
  title,
  onMenuClick,
  actions,
  companyName,
  userFullName,
  userEmail,
  className,
}: TopbarProps) {
  return (
    <header
      className={cn(
        "flex h-16 shrink-0 items-center justify-between border-b border-border bg-background/80 px-4 backdrop-blur-sm sm:px-6",
        className,
      )}
    >
      <div className="flex items-center gap-3">
        {onMenuClick && (
          <Button variant="ghost" size="icon" className="lg:hidden" onClick={onMenuClick}>
            <Menu className="size-5" />
          </Button>
        )}
        {title && <h1 className="text-base font-semibold text-foreground">{title}</h1>}
      </div>

      <div className="flex items-center gap-3">
        {actions && <div className="flex items-center gap-2">{actions}</div>}
        <UserMenu
          companyName={companyName}
          userFullName={userFullName}
          userEmail={userEmail}
        />
      </div>
    </header>
  );
}
