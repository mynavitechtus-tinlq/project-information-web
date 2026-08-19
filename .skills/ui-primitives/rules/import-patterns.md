# Import Patterns

## UI Component Imports

Always use absolute paths with `@/components/ui/<name>`:

```tsx
// Single component
import { Button } from '@/components/ui/button';

// Multiple exports from same component
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';

// Multiple components
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
```

## Feature Component Imports

Import from the feature's public API (`index.ts`), never from internal files:

```tsx
// CORRECT
import { LoginForm } from '@/features/auth';

// INCORRECT
import LoginForm from '@/features/auth/components/login-form';
```

## Common Component Combinations

### Dialog with Form

```tsx
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Form, FormField, FormItem, FormControl, FormMessage } from '@/components/ui/form';
import { Field, FieldLabel } from '@/components/ui/field';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
```

### Data Table

```tsx
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
```

### Navigation

```tsx
import { Sidebar, SidebarContent, SidebarGroup, SidebarMenuItem } from '@/components/ui/sidebar';
import { NavigationMenu, NavigationMenuList, NavigationMenuItem } from '@/components/ui/navigation-menu';
import { Breadcrumb, BreadcrumbList, BreadcrumbItem, BreadcrumbLink } from '@/components/ui/breadcrumb';
```

## Rules

1. Always use `@/` prefix (resolves to `src/`)
2. Never use relative imports for UI components
3. Import specific exports, not default exports
4. Group related imports together
