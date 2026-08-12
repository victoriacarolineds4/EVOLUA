import { LayoutDashboard, AppWindow, FileBarChart2, CreditCard, Settings } from "lucide-react";
import type { SidebarNavItem } from "@/components/layout/sidebar";

export const defaultNavItems: SidebarNavItem[] = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "Aplicações", href: "/aplicacoes", icon: AppWindow },
  { label: "Relatórios", href: "/relatorio", icon: FileBarChart2 },
  { label: "Meu Plano", href: "/meu-plano", icon: CreditCard },
  { label: "Configurações", href: "/configuracoes", icon: Settings },
];
