# Design System

A comprehensive design token system built with Tailwind CSS 4 for managing design tokens.

## Overview

This design system provides a structured approach to managing design tokens using Tailwind CSS 4's `@theme` directive. Design tokens are the foundational visual elements that ensure consistency across your application.

## Design Token Philosophy

- **Single Source of Truth**: All design decisions are centralized in theme variables
- **Semantic Naming**: Variables are named for their purpose, not their visual appearance
- **Scalable Architecture**: Easy to extend and maintain across projects
- **CSS Custom Properties**: Leverages native CSS variables for runtime flexibility

## Theme Variable Structure

### Core Naming Convention

Our design tokens follow this pattern:

```
--{category}-{variant}-{scale}
```

Examples:

- `--color-primary-500` - Primary color at medium scale
- `--spacing-md` - Medium spacing value
- `--radius-lg` - Large border radius

### Semantic Token Pattern

We use a semantic naming convention that maps theme variables to base CSS custom properties:

```css
@theme {
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
}
```

This pattern provides:

- **Semantic clarity**: `--color-primary` describes purpose, not appearance
- **Theme flexibility**: Base values can change without updating theme mappings
- **Consistent structure**: All color tokens follow the same naming pattern
- **Easy maintenance**: Update base values once, all references update automatically

### Base Variable Naming

Base CSS custom properties use simple, semantic names:

```css
:root {
  --primary: oklch(0.208 0.042 265.755);
  --primary-foreground: oklch(0.984 0.003 247.858);
  --secondary: oklch(0.968 0.007 247.896);
  --secondary-foreground: oklch(0.208 0.042 265.755);
}
```

### Theme Variable Mapping

Theme variables reference base variables with descriptive prefixes:

```css
@theme {
  /* Interactive Colors */
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);

  /* Component Colors */
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);

  /* UI Colors */
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
}
```

### Categories([reference](https://tailwindcss.com/docs/theme#theme-variable-namespaces))

1. **Colors** (`--color-*`)
2. **Typography** (`--font-*`, `--text-*`, `--leading-*`, `--tracking-*`)
3. **Spacing** (`--spacing-*`, `--padding-*`, `--margin-*`)
4. **Layout** (`--container-*`, `--breakpoint-*`)
5. **Effects** (`--shadow-*`, `--blur-*`)
6. **Borders** (`--radius-*`, `--border-*`)
7. **Transitions** (`--ease-*`, `--duration-*`)
8. **Z-Index** (`--z-*`)

## Color System

### Semantic Color Tokens

```css
/* Base Colors */
--color-background: var(--background) --color-foreground: var(--foreground)
  /* Component Colors */ --color-card: var(--card)
  --color-card-foreground: var(--card-foreground)
  --color-popover: var(--popover)
  --color-popover-foreground: var(--popover-foreground) /* Interactive Colors */
  --color-primary: var(--primary)
  --color-primary-foreground: var(--primary-foreground)
  --color-secondary: var(--secondary)
  --color-secondary-foreground: var(--secondary-foreground)
  --color-accent: var(--accent)
  --color-accent-foreground: var(--accent-foreground) /* State Colors */
  --color-destructive: var(--destructive) --color-muted: var(--muted)
  --color-muted-foreground: var(--muted-foreground) /* UI Colors */
  --color-border: var(--border) --color-input: var(--input)
  --color-ring: var(--ring) /* Sidebar Colors */ --color-sidebar: var(--sidebar)
  --color-sidebar-foreground: var(--sidebar-foreground)
  --color-sidebar-primary: var(--sidebar-primary)
  --color-sidebar-primary-foreground: var(--sidebar-primary-foreground)
  --color-sidebar-accent: var(--sidebar-accent)
  --color-sidebar-accent-foreground: var(--sidebar-accent-foreground)
  --color-sidebar-border: var(--sidebar-border)
  --color-sidebar-ring: var(--sidebar-ring) /* Chart Colors */
  --color-chart-1: var(--chart-1) --color-chart-2: var(--chart-2)
  --color-chart-3: var(--chart-3) --color-chart-4: var(--chart-4)
  --color-chart-5: var(--chart-5);
```

### Color Scale Convention

When extending the color system, follow this scale:

- `50` - Lightest tint
- `100` - Very light tint
- `200` - Light tint
- `300` - Medium light tint
- `400` - Medium tint
- `500` - Base color
- `600` - Medium dark tint
- `700` - Dark tint
- `800` - Very dark tint
- `900` - Darkest tint

Example:

```css
@theme {
  --color-blue-500: oklch(0.5 0.2 250);
  --color-blue-600: oklch(0.4 0.2 250);
  --color-blue-700: oklch(0.3 0.2 250);
}
```

## Typography System

### Font Families

```css
--font-sans: var(--font-geist-sans) --font-mono: var(--font-geist-mono);
```

### Font Sizes

```css
--text-xs: 0.75rem --text-sm: 0.875rem --text-base: 1rem --text-lg: 1.125rem
  --text-xl: 1.25rem --text-2xl: 1.5rem --text-3xl: 1.875rem --text-4xl: 2.25rem
  --text-5xl: 3rem --text-6xl: 3.75rem --text-7xl: 4.5rem --text-8xl: 6rem
  --text-9xl: 8rem;
```

### Line Heights

```css
--text-xs--line-height: calc(1 / 0.75)
  --text-sm--line-height: calc(1.25 / 0.875)
  --text-base--line-height: calc(1.5 / 1)
  --text-lg--line-height: calc(1.75 / 1.125)
  --text-xl--line-height: calc(1.75 / 1.25)
  --text-2xl--line-height: calc(2 / 1.5)
  --text-3xl--line-height: calc(2.25 / 1.875)
  --text-4xl--line-height: calc(2.5 / 2.25) --text-5xl--line-height: 1
  --text-6xl--line-height: 1 --text-7xl--line-height: 1
  --text-8xl--line-height: 1 --text-9xl--line-height: 1;
```

### Font Weights

```css
--font-weight-thin: 100 --font-weight-extralight: 200 --font-weight-light: 300
  --font-weight-normal: 400 --font-weight-medium: 500
  --font-weight-semibold: 600 --font-weight-bold: 700
  --font-weight-extrabold: 800 --font-weight-black: 900;
```

### Letter Spacing

```css
--tracking-tighter: -0.05em --tracking-tight: -0.025em --tracking-normal: 0em
  --tracking-wide: 0.025em --tracking-wider: 0.05em --tracking-widest: 0.1em;
```

### Line Height Utilities

```css
--leading-tight: 1.25 --leading-snug: 1.375 --leading-normal: 1.5
  --leading-relaxed: 1.625 --leading-loose: 2;
```

## Spacing System

### Container Sizes

```css
--container-3xs: 16rem --container-2xs: 18rem --container-xs: 20rem
  --container-sm: 24rem --container-md: 28rem --container-lg: 32rem
  --container-xl: 36rem --container-2xl: 42rem --container-3xl: 48rem
  --container-4xl: 56rem --container-5xl: 64rem --container-6xl: 72rem
  --container-7xl: 80rem;
```

### Breakpoints

```css
--breakpoint-sm: 40rem --breakpoint-md: 48rem --breakpoint-lg: 64rem
  --breakpoint-xl: 80rem --breakpoint-2xl: 96rem;
```

## Border Radius System

```css
--radius-xs: 0.125rem --radius-sm: 0.25rem --radius-md: 0.375rem
  --radius-lg: 0.5rem --radius-xl: 0.75rem --radius-2xl: 1rem
  --radius-3xl: 1.5rem --radius-4xl: 2rem;
```

### Dynamic Radius Calculation

```css
--radius: 0.625rem --radius-sm: calc(var(--radius) - 4px)
  --radius-md: calc(var(--radius) - 2px) --radius-lg: var(--radius)
  --radius-xl: calc(var(--radius) + 4px);
```

## Shadow System

### Box Shadows

```css
--shadow-2xs:
  0 1px rgb(0 0 0 / 0.05) --shadow-xs: 0 1px 2px 0 rgb(0 0 0 / 0.05)
    --shadow-sm: 0 1px 3px 0 rgb(0 0 0 / 0.1),
  0 1px 2px -1px rgb(0 0 0 / 0.1) --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1),
  0 2px 4px -2px rgb(0 0 0 / 0.1) --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1),
  0 4px 6px -4px rgb(0 0 0 / 0.1) --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1),
  0 8px 10px -6px rgb(0 0 0 / 0.1) --shadow-2xl: 0 25px 50px -12px
    rgb(0 0 0 / 0.25);
```

### Inset Shadows

```css
--inset-shadow-2xs: inset 0 1px rgb(0 0 0 / 0.05) --inset-shadow-xs: inset 0 1px
  1px rgb(0 0 0 / 0.05) --inset-shadow-sm: inset 0 2px 4px rgb(0 0 0 / 0.05);
```

### Drop Shadows

```css
--drop-shadow-xs: 0 1px 1px rgb(0 0 0 / 0.05) --drop-shadow-sm: 0 1px 2px
  rgb(0 0 0 / 0.15) --drop-shadow-md: 0 3px 3px rgb(0 0 0 / 0.12)
  --drop-shadow-lg: 0 4px 4px rgb(0 0 0 / 0.15) --drop-shadow-xl: 0 9px 7px
  rgb(0 0 0 / 0.1) --drop-shadow-2xl: 0 25px 25px rgb(0 0 0 / 0.15);
```

### Text Shadows

```css
--text-shadow-2xs:
  0px 1px 0px rgb(0 0 0 / 0.15) --text-shadow-xs: 0px 1px 1px rgb(0 0 0 / 0.2)
    --text-shadow-sm: 0px 1px 0px rgb(0 0 0 / 0.075),
  0px 1px 1px rgb(0 0 0 / 0.075),
  0px 2px 2px rgb(0 0 0 / 0.075) --text-shadow-md: 0px 1px 1px rgb(0 0 0 / 0.1),
  0px 1px 2px rgb(0 0 0 / 0.1),
  0px 2px 4px rgb(0 0 0 / 0.1) --text-shadow-lg: 0px 1px 2px rgb(0 0 0 / 0.1),
  0px 3px 2px rgb(0 0 0 / 0.1), 0px 4px 8px rgb(0 0 0 / 0.1);
```

## Effects System

### Blur Values

```css
--blur-xs: 4px --blur-sm: 8px --blur-md: 12px --blur-lg: 16px --blur-xl: 24px
  --blur-2xl: 40px --blur-3xl: 64px;
```

### Perspective Values

```css
--perspective-dramatic: 100px --perspective-near: 300px
  --perspective-normal: 500px --perspective-midrange: 800px
  --perspective-distant: 1200px;
```

## Animation System

### Easing Functions

```css
--ease-in: cubic-bezier(0.4, 0, 1, 1) --ease-out: cubic-bezier(0, 0, 0.2, 1)
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
```

### Animation Definitions

```css
--animate-spin: spin 1s linear infinite --animate-ping: ping 1s
  cubic-bezier(0, 0, 0.2, 1) infinite --animate-pulse: pulse 2s
  cubic-bezier(0.4, 0, 0.6, 1) infinite --animate-bounce: bounce 1s infinite;
```

### Keyframes

```css
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@keyframes ping {
  75%,
  100% {
    transform: scale(2);
    opacity: 0;
  }
}

@keyframes pulse {
  50% {
    opacity: 0.5;
  }
}

@keyframes bounce {
  0%,
  100% {
    transform: translateY(-25%);
    animation-timing-function: cubic-bezier(0.8, 0, 1, 1);
  }
  50% {
    transform: none;
    animation-timing-function: cubic-bezier(0, 0, 0.2, 1);
  }
}
```

## Dark Mode Support

The design system automatically supports dark mode through CSS custom properties. Each color token has both light and dark variants defined in the `:root` and `.dark` selectors.

### Dark Mode Implementation

```css
:root {
  /* Light mode colors */
  --background: oklch(1 0 0);
  --foreground: oklch(0.129 0.042 264.695);
}

.dark {
  /* Dark mode colors */
  --background: oklch(0.129 0.042 264.695);
  --foreground: oklch(0.984 0.003 247.858);
}
```

## Usage Guidelines

### 1. Adding New Design Tokens

When adding new design tokens:

1. **Define the base variable** in `:root` and `.dark`
2. **Map it to a theme variable** using `@theme`
3. **Follow the naming convention** for consistency

Example:

```css
:root {
  --success: oklch(0.7 0.2 150);
}

.dark {
  --success: oklch(0.6 0.2 150);
}

@theme {
  --color-success: var(--success);
}
```

### 2. Using Design Tokens

#### In HTML (Utility Classes)

```html
<div class="rounded-lg bg-primary p-4 text-primary-foreground shadow-md">
  Button
</div>
```

#### In CSS (Custom Properties)

```css
.custom-button {
  @apply rounded-lg bg-primary p-4 text-primary-foreground shadow-md;
}
```

or

```css
.custom-button {
  background-color: var(--color-primary);
  color: var(--color-primary-foreground);
  padding: var(--spacing-4);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
}
```

#### In JavaScript

```javascript
const primaryColor = getComputedStyle(
  document.documentElement,
).getPropertyValue('--color-primary');
```

### 3. Extending the System

#### Adding New Color Scales

```css
@theme {
  --color-emerald-500: oklch(0.6 0.2 150);
  --color-emerald-600: oklch(0.5 0.2 150);
  --color-emerald-700: oklch(0.4 0.2 150);
}
```

#### Adding Custom Spacing

```css
@theme {
  --spacing-18: 4.5rem;
  --spacing-88: 22rem;
}
```

#### Adding Custom Shadows

```css
@theme {
  --shadow-glow: 0 0 20px rgb(59 130 246 / 0.5);
}
```
