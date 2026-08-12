"use client";

import { useTransition } from "react";
import { LogOut, User } from "lucide-react";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { logoutAction } from "@/features/auth/actions/auth.actions";

interface UserMenuProps {
  companyName?: string;
  userFullName?: string;
  userEmail?: string;
}

function getInitials(name?: string, email?: string): string {
  if (name) {
    const parts = name.trim().split(" ");
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return parts[0].slice(0, 2).toUpperCase();
  }
  if (email) return email.slice(0, 2).toUpperCase();
  return "??";
}

export function UserMenu({ companyName, userFullName, userEmail }: UserMenuProps) {
  const [isPending, startTransition] = useTransition();

  const initials = getInitials(userFullName ?? undefined, userEmail);
  const displayName = userFullName || userEmail || "Usuário";

  return (
    <div className="flex items-center gap-3">
      {companyName && (
        <span className="hidden text-sm font-medium text-foreground/80 sm:block">
          {companyName}
        </span>
      )}

      <DropdownMenu>
        <DropdownMenuTrigger className="flex items-center gap-2 rounded-full outline-none ring-ring transition-shadow focus-visible:ring-2">
          <Avatar className="size-8 cursor-pointer">
            <AvatarFallback className="bg-primary/20 text-xs font-semibold text-primary">
              {initials}
            </AvatarFallback>
          </Avatar>
        </DropdownMenuTrigger>

        <DropdownMenuContent align="end" className="w-56">
          <DropdownMenuLabel className="font-normal">
            <p className="text-sm font-medium leading-none">{displayName}</p>
            {userEmail && (
              <p className="mt-1 text-xs leading-none text-muted-foreground">
                {userEmail}
              </p>
            )}
          </DropdownMenuLabel>

          <DropdownMenuSeparator />

          <DropdownMenuGroup>
            <DropdownMenuItem disabled>
              <User className="mr-2 size-4" />
              Perfil
            </DropdownMenuItem>
          </DropdownMenuGroup>

          <DropdownMenuSeparator />

          <DropdownMenuItem
            className="text-destructive focus:text-destructive"
            disabled={isPending}
            onClick={() => startTransition(() => logoutAction())}
          >
            <LogOut className="mr-2 size-4" />
            Sair
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
}
