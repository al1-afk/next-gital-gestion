import * as React from 'react'
import { cn } from '@/lib/utils'

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

/**
 * Input — spec:
 * Height   : 40px
 * Border   : 1px solid #E2E8F0 (light) / border-border (dark)
 * Focus    : border-color #378ADD + box-shadow 0 0 0 3px rgba(55,138,221,0.15)
 * Placeholder: #B4B2A9
 */
const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          // Layout
          'flex h-10 w-full rounded-lg px-3 py-2 text-sm',
          // Colors — light
          'border border-border bg-[var(--surface-input)] text-foreground',
          'placeholder:text-[#B4B2A9] dark:placeholder:text-slate-500',
          // File input reset
          'file:border-0 file:bg-transparent file:text-sm file:font-medium',
          // Transition
          'transition-all duration-150',
          // Focus — spec: border #378ADD + shadow 0 0 0 3px rgba(55,138,221,0.15)
          'focus-visible:outline-none',
          'focus-visible:border-[#378ADD]',
          'focus-visible:shadow-[0_0_0_3px_rgba(55,138,221,0.15)]',
          // Disabled
          'disabled:cursor-not-allowed disabled:opacity-50',
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Input.displayName = 'Input'

export { Input }
