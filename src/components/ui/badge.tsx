import * as React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

/**
 * Badge system — spec exact colors:
 * Light:  semantic pastel backgrounds with colored text + matching border
 * Dark:   semi-transparent tinted equivalents
 *
 * Base shape: 20px pill, 12px/500 text, 1px border, 4px 10px padding
 */
const badgeVariants = cva(
  'inline-flex items-center gap-1 rounded-full border font-medium transition-colors whitespace-nowrap',
  {
    variants: {
      variant: {
        // ── Paid / Revenue / Positive ──────────────────────────────────
        success: [
          'bg-[#EAF3DE] border-[#97C459] text-[#27500A]',
          'dark:bg-emerald-950/50 dark:border-emerald-700/40 dark:text-emerald-300',
        ],
        // ── Pending / Warning / Waiting ────────────────────────────────
        warning: [
          'bg-[#FAEEDA] border-[#FAC775] text-[#633806]',
          'dark:bg-amber-950/50 dark:border-amber-700/40 dark:text-amber-300',
        ],
        // ── Unpaid / Danger / Overdue ──────────────────────────────────
        destructive: [
          'bg-[#FCEBEB] border-[#F09595] text-[#A32D2D]',
          'dark:bg-red-950/50 dark:border-red-700/40 dark:text-red-300',
        ],
        // ── Info / Pipeline / Neutral metric ──────────────────────────
        default: [
          'bg-[#E6F1FB] border-[#85B7EB] text-[#0C447C]',
          'dark:bg-blue-950/50 dark:border-blue-700/40 dark:text-blue-300',
        ],
        // ── Cancelled / Archived ──────────────────────────────────────
        secondary: [
          'bg-[#F1EFE8] border-[#B4B2A9] text-[#5F5E5A]',
          'dark:bg-slate-800/60 dark:border-slate-600/50 dark:text-slate-400',
        ],
        // ── AI / Premium ───────────────────────────────────────────────
        purple: [
          'bg-[#EEEDFE] border-[#A79FF4] text-[#3C3489]',
          'dark:bg-purple-950/50 dark:border-purple-700/40 dark:text-purple-300',
        ],
        // ── Outline (border only) ─────────────────────────────────────
        outline: [
          'bg-transparent border-[#B4B2A9] text-[#5F5E5A]',
          'dark:border-slate-600 dark:text-slate-400',
        ],
      },
      size: {
        default: 'px-2.5 py-0.5 text-xs',
        sm:      'px-2 py-px text-[10px]',
        lg:      'px-3 py-1 text-sm',
      },
    },
    defaultVariants: { variant: 'default', size: 'default' },
  }
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, size, ...props }: BadgeProps) {
  return (
    <div
      className={cn(badgeVariants({ variant, size }), className)}
      {...props}
    />
  )
}

export { Badge, badgeVariants }
