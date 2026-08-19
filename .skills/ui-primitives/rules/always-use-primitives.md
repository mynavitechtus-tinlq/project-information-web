# Always Use Primitives

## Why

- **Consistency**: Unified look across the app via shared design tokens
- **Accessibility**: Radix UI primitives handle ARIA, focus management, keyboard nav
- **Theming**: Components respond to light/dark mode via CSS variables
- **Maintenance**: Bug fixes and improvements apply everywhere at once

## Rule

Before creating any UI element, search the Component Registry in `SKILL.md`. If a matching primitive exists, use it.

## Correct vs Incorrect

### Buttons

```tsx
// INCORRECT - raw HTML button
<button className="bg-blue-500 text-white px-4 py-2 rounded" onClick={handleClick}>
  Submit
</button>

// CORRECT - use Button primitive
import { Button } from '@/components/ui/button';

<Button variant="default" onClick={handleClick}>
  Submit
</Button>
```

### Inputs

```tsx
// INCORRECT - raw HTML input
<input type="text" className="border rounded px-3 py-2" />

// CORRECT - use Input primitive
import { Input } from '@/components/ui/input';

<Input type="text" placeholder="Enter value..." />
```

### Modals

```tsx
// INCORRECT - custom modal div
<div className="fixed inset-0 bg-black/50">
  <div className="bg-white rounded p-6">...</div>
</div>

// CORRECT - use Dialog primitive
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';

<Dialog open={open} onOpenChange={setOpen}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Title</DialogTitle>
    </DialogHeader>
    ...
  </DialogContent>
</Dialog>
```

### Tables

```tsx
// INCORRECT - raw HTML table
<table className="w-full">
  <thead><tr><th>Name</th></tr></thead>
  <tbody><tr><td>John</td></tr></tbody>
</table>

// CORRECT - use Table primitive
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from '@/components/ui/table';

<Table>
  <TableHeader>
    <TableRow><TableHead>Name</TableHead></TableRow>
  </TableHeader>
  <TableBody>
    <TableRow><TableCell>John</TableCell></TableRow>
  </TableBody>
</Table>
```

## Full Raw HTML to Primitive Mapping

| Raw HTML | Primitive | Import |
|----------|-----------|--------|
| `<button>` | `Button` | `@/components/ui/button` |
| `<input>` | `Input` | `@/components/ui/input` |
| `<textarea>` | `Textarea` | `@/components/ui/textarea` |
| `<select>` | `Select` | `@/components/ui/select` |
| `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<th>`, `<td>` | `Table`, `TableHeader`, `TableBody`, `TableRow`, `TableHead`, `TableCell` | `@/components/ui/table` |
| `<dialog>` | `Dialog` | `@/components/ui/dialog` |
| `<label>` | `Label` | `@/components/ui/label` |
| `<progress>` | `Progress` | `@/components/ui/progress` |

## When No Primitive Exists

If you need a component not in the registry:
1. **Ask the user** before creating it
2. Consider if an existing primitive can be composed to achieve the goal
3. If a new component is truly needed, create it in `src/components/ui/` following the same patterns
