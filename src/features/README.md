# Features

This directory contains feature-based modules following the **Bulletproof Next.js** architecture pattern. Each feature is self-contained and includes all its related code.

## Feature Structure

```
features/
└── [feature-name]/
    ├── api/              # Server Actions and API calls
    ├── components/       # Feature-specific components
    ├── config/           # Feature-specific configuration (constants, storage keys, etc.)
    ├── hooks/            # Feature-specific React hooks
    ├── lib/              # Feature-specific utilities, schemas, and business logic
    ├── types/            # Feature-specific TypeScript types
    └── index.ts          # Public API (exports only what should be used outside)
```

## Example Feature: Auth

```typescript
// features/auth/index.ts
export { login } from './api/auth-action';
export { default as LoginForm } from './components/login-form';
export { createLoginFormSchema, type LoginFormData } from './lib/schemas';
export { AUTH_STORAGE_KEY } from './config/storage';
```

## Best Practices

1. **Self-contained**: Each feature should be independent and not directly import from other features
2. **Public API**: Use `index.ts` to control what's exported from a feature - only export what other features/pages need
3. **Naming**: Use kebab-case for feature folder names (e.g., `user-profile`, `product-catalog`)
4. **Imports**: Always import from feature's public API (`index.ts`), not internal files:
   - ✅ `import { LoginForm } from '@/features/auth'`
   - ❌ `import LoginForm from '@/features/auth/components/login-form'`
5. **Shared Code**: If code is used by multiple features, move it to:
   - `src/components/shared/` for shared components
   - `src/lib/` for shared utilities
   - `src/hooks/` for shared hooks

## Feature Organization

### API (`api/`)

- Server Actions (marked with `'use server'`)
- API route handlers
- External API integrations

### Components (`components/`)

- Feature-specific React components
- Should not be used outside the feature (unless exported via `index.ts`)

### Hooks (`hooks/`)

- Feature-specific React hooks
- Custom hooks that encapsulate feature logic

### Config (`config/`)

- Feature-specific configuration constants
- Storage keys (e.g., `AUTH_STORAGE_KEY`)
- Feature settings and constants
- Should contain only configuration, not business logic

### Lib (`lib/`)

- Zod schemas and validation
- Business logic
- Feature-specific utilities
- Type definitions related to the feature

### Types (`types/`)

- Feature-specific TypeScript types and interfaces
- Type utilities

### Index (`index.ts`)

- **Public API** of the feature
- Only export what should be used outside the feature
- This is the only file other features/pages should import from
