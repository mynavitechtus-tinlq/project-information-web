# Form Patterns

This project uses React Hook Form + Zod + UI primitives for all forms.

## Pattern Overview

1. **Zod schema** in `features/[feature]/lib/schemas.ts` (accepts `t` translation function)
2. **React Hook Form** with `@hookform/resolvers/zod`
3. **Form components** from `@/components/ui/form`
4. **Field layout** from `@/components/ui/field`
5. **Input primitives** from `@/components/ui/*`

## Schema Definition

```tsx
// features/[feature]/lib/schemas.ts
import { z } from 'zod';

export const createLoginSchema = (t: (key: string) => string) =>
  z.object({
    email: z.string().email(t('validation.email')),
    password: z.string().min(8, t('validation.password_min')),
  });

export type LoginFormValues = z.infer<ReturnType<typeof createLoginSchema>>;
```

## Form Component

```tsx
// features/[feature]/components/login-form.tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTranslations } from 'next-intl';

import { Form, FormField, FormItem, FormControl, FormMessage } from '@/components/ui/form';
import { Field, FieldLabel } from '@/components/ui/field';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

import { createLoginSchema, type LoginFormValues } from '../lib/schemas';

export function LoginForm() {
  const t = useTranslations();
  const schema = createLoginSchema(t);

  const form = useForm<LoginFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { email: '', password: '' },
  });

  const onSubmit = async (values: LoginFormValues) => {
    // Call server action
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <Field>
                <FieldLabel>{t('auth.email')}</FieldLabel>
                <FormControl>
                  <Input type="email" {...field} />
                </FormControl>
                <FormMessage />
              </Field>
            </FormItem>
          )}
        />
        <Button type="submit">
          {t('auth.login')}
        </Button>
      </form>
    </Form>
  );
}
```

## Key Rules

1. Schema factories always accept `t` function for i18n error messages
2. Use `FormField` + `FormItem` + `FormControl` for each field
3. Use `Field` + `FieldLabel` for layout (supports vertical/horizontal/responsive)
4. Never use raw `<input>`, `<select>`, `<textarea>` in forms
5. Server actions go in `features/[feature]/api/`
6. Export form components through feature's `index.ts`
