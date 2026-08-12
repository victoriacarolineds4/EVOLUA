"use client";

import { createContext, useContext, useState, type ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ThemeProvider } from "next-themes";
import type { SupabaseClient } from "@supabase/supabase-js";
import { Toaster } from "@/components/ui/sonner";
import { createClient } from "@/lib/supabase/client";

const SupabaseContext = createContext<SupabaseClient | null>(null);

export function useSupabase() {
  const context = useContext(SupabaseContext);
  if (!context) {
    throw new Error("useSupabase deve ser usado dentro de <Providers>");
  }
  return context;
}

export function Providers({ children }: { children: ReactNode }) {
  const [supabase] = useState(() => createClient());
  const [queryClient] = useState(() => new QueryClient());

  return (
    <QueryClientProvider client={queryClient}>
      <SupabaseContext.Provider value={supabase}>
        <ThemeProvider attribute="class" defaultTheme="light" enableSystem={false}>
          {children}
          <Toaster />
        </ThemeProvider>
      </SupabaseContext.Provider>
    </QueryClientProvider>
  );
}
