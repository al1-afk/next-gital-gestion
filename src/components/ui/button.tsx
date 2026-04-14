import * as React from 'react'
import { Slot } from '@radix-ui/react-slot'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

/**
 * Button system — spec:
 * Primary   : bg #3a526b / text white / hover 10% darker / active scale(0.98)
 * Secondary : border #3a526b / color #3a526b / hover #F0F4F8
 * Danger    : bg #FCEBEB / color #A32D2D / border #F09595
 * Height    : 40px (h-10)
 * Radius    : 8px
 */
const buttonVariants = cva(
  [
    'inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-lg',
    'text-sm font-medium transition-all duration-150 cursor-pointer',
    'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#378ADD]/50 focus-visible:ring-offset-1',
    'disabled:pointer-events-none disabled:opacity-50',
    'active:scale-[0.98]',
  ].join(' '),
  {
    variants: {
      variant: {
        // ── Primary ────────────────────────────────────────────────────
        default: [
          'bg-[#3a526b] text-white shadow-sm',
          'hover:bg-[#2d4156]',
          'dark:bg-[#4a6d8c] dark:hover:bg-[#3a5a7a]',
        ],
        // ── Secondary ─────────────────────────────────────────────────
        secondary: [
          'border border-[#3a526b] text-[#3a526b] bg-transparent',
          'hover:bg-[#F0F4F8]',
          'dark:border-slate-500 dark:text-slate-300 dark:hover:bg-slate-700/50',
        ],
        // ── Destructive / Danger ───────────────────────────────────────
        destructive: [
          'bg-[#FCEBEB] border border-[#F09595] text-[#A32D2D]',
          'hover:bg-[#F09595]/30',
          'dark:bg-red-950/50 dark:border-red-700/40 dark:text-red-300 dark:hover:bg-red-900/50',
        ],
        // ── Outline ────────────────────────────────────────────────────
        outline: [
          'border border-border bg-transparent text-foreground',
          'hover:bg-muted',
        ],
        // ── Ghost ──────────────────────────────────────────────────────
        ghost: [
          'text-muted-foreground bg-transparent',
          'hover:text-foreground hover:bg-muted',
        ],
        // ── Link ───────────────────────────────────────────────────────
        link: [
          'text-[#378ADD] underline-offset-4',
          'hover:underline',
        ],
        // ── Success ────────────────────────────────────────────────────
        success: [
          'bg-[#EAF3DE] border border-[#97C459] text-[#27500A]',
          'hover:bg-[#97C459]/30',
          'dark:bg-emerald-950/50 dark:border-emerald-700/40 dark:text-emerald-300 dark:hover:bg-emerald-900/50',
        ],
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm:      'h-8 px-3 text-xs rounded-md',
        lg:      'h-11 px-8 text-base rounded-lg',
        icon:    'h-9 w-9',
      },
    },
    defaultVariants: { variant: 'default', size: 'default' },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button'
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = 'Button'

export { Button, buttonVariants }
