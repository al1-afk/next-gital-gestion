import { QueryClient } from '@tanstack/react-query'

/* Singleton QueryClient — exported so the logout helper in
   src/lib/session.ts can call queryClient.clear() without
   React context access. */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 2,
      retry: 1,
    },
  },
})
