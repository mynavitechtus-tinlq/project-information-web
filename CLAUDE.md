# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

```bash
# Development
npm run dev                    # Start development server at http://localhost:3000

# Building
npm run build                  # Production build
npm run start                  # Run production build locally
npm run build-stats            # Build with bundle analyzer

# Testing
npm run test:unit              # Run Vitest unit tests
npm run test:e2e               # Run Playwright E2E tests
npx playwright install         # Install Playwright browsers (first time only)

# Code Quality
npm run lint                   # Run ESLint
npm run lint:fix               # Fix auto-fixable linting issues
npm run check:types            # TypeScript type checking

# Security
npm run security:audit         # Check for vulnerabilities
npm run security:fix           # Auto-fix vulnerabilities
npm run security:check         # Run both audit and lint

# i18n
npm run i18n:import            # Import translations from .i18n/source.xlsx

# Cleanup
npm run clean                  # Remove .next, out, and coverage directories
```

## Architecture Overview

### Tech Stack

- **Framework**: Next.js 16+ (App Router with React 19)
- **Language**: TypeScript (strict mode enabled)
- **Styling**: Tailwind CSS 4 with SCSS support
- **UI Components**: Radix UI primitives
- **Forms**: React Hook Form + Zod validation
- **i18n**: next-intl (locales: en, ja)
- **Testing**: Vitest (unit) + Playwright (E2E)
- **Error Monitoring**: Sentry
- **Git Hooks**: LeftHook

### Project Structure Philosophy

The codebase follows the **Bulletproof Next.js** architecture pattern with feature-based organization and clear separation of concerns:

#### Core Directories

- **`src/app/[locale]`**: Next.js App Router with locale-based routing
  - Uses `(routes)` route groups for organization
  - No middleware.ts file - routing handled by next-intl configuration
  - Pages should be thin and primarily import from features

- **`src/features`**: Feature-based modules (Bulletproof Next.js pattern)
  - Each feature is self-contained and includes all related code
  - Structure: `features/[feature-name]/`
    - `api/`: Server Actions and API calls
    - `components/`: Feature-specific components
    - `config/`: Feature-specific configuration (constants, storage keys, etc.)
    - `hooks/`: Feature-specific React hooks
    - `lib/`: Feature-specific utilities, schemas, and business logic
    - `types/`: Feature-specific TypeScript types
    - `index.ts`: Public API (exports only what should be used outside the feature)
  - Example: `features/auth/` contains login functionality, schemas, storage keys, and components

- **`src/components`**: Shared component library
  - `ui/`: Reusable UI primitives (based on Radix UI)
  - `providers/`: Context providers (ThemeProvider, etc.)
  - `templates/`: Layout components (header, footer, etc.)

- **`src/lib`**: Third-party integrations and utilities
  - `env.ts`: Type-safe environment variables using T3 Env
  - `i18n.ts` + `i18n-routing.ts`: next-intl configuration
  - Shared utilities used across multiple features

- **`src/config`**: Application configuration
  - `app-config.ts`: App settings (locales, name, etc.)
  - Note: Feature-specific configuration (like storage keys) should be in `features/[feature]/config/`

- **`src/hooks`**: Shared React hooks (used across multiple features)

- **`src/stores`**: State management (currently empty, ready for Zustand/Redux)

- **`src/types`**: Global TypeScript types and utilities

- **`tests/`**: Test organization
  - `unit/`: Vitest tests (run with jsdom environment for .tsx files)
  - `e2e/`: Playwright tests (includes Monitoring as Code)
  - `integration/`: Integration tests

### Key Architectural Patterns

#### 1. Type-Safe Environment Variables

Environment variables are validated at build time using T3 Env in `src/lib/env.ts`. Always import from `@/lib/env` rather than using `process.env` directly.

#### 2. Internationalization (i18n)

- Locale files in `public/locales/[locale]/` as JSON
- Translations imported via `@/public/locales/${locale}`
- Use `next-intl` hooks in components for translations
- Locale routing configured in `src/lib/i18n-routing.ts`
- Supports `en` (default) and `ja` locales

#### 3. Form Validation Pattern

Forms use a consistent pattern:

1. Define Zod schema in `src/features/[feature]/lib/schemas.ts`
2. Schema factories accept translation function for error messages
3. React Hook Form + `@hookform/resolvers` for form handling
4. Server Actions in `src/features/[feature]/api/` for submission

#### 4. Absolute Imports

Use `@/` prefix for imports (resolves to `src/`):

```typescript
import { AppConfig } from '@/config/app-config';
import { login, LoginForm, AUTH_STORAGE_KEY } from '@/features/auth';
```

**Feature Imports**: Always import from feature's public API (`index.ts`), not internal files:

- ✅ `import { LoginForm } from '@/features/auth'`
- ❌ `import LoginForm from '@/features/auth/components/login-form'`

#### 5. Security Headers

`next.config.ts` includes strict CSP and security headers. Note:

- Development allows 'unsafe-eval' for HMR
- Production uses more restrictive policies
- Sentry tunneling via `/monitoring` route

### Testing Strategy

#### Unit Tests

- Located in `tests/unit/` directory
- Use Vitest with React Testing Library
- Browser-based tests run in jsdom environment
- Import paths work via `vite-tsconfig-paths`

#### E2E Tests

- Playwright tests in `tests/` with `.spec.ts` or `.e2e.ts` extensions
- Auto-starts dev server (or production build in CI)
- Runs Chromium locally, adds Firefox in CI
- Sentry disabled during tests via `NEXT_PUBLIC_SENTRY_DISABLED`

### Git Workflow

#### Pre-commit Hooks (LeftHook)

1. **Lint**: Auto-fixes ESLint issues on staged files
2. **Type Check**: Runs `tsc --noEmit` on .ts/.tsx files

### Docker Deployment

- Standalone output mode configured in `next.config.ts`
- Build: `docker build -t nals-fe-reactjs .`
- Run: `docker run --rm -p 3000:3000 --env-file .env.production nals-fe-reactjs`

### Environment Variables

Create `.env.local` for sensitive data (not tracked by Git):

- `NEXT_SERVER_ACTIONS_ENCRYPTION_KEY`: Required for server actions security
- Sentry variables: `NEXT_PUBLIC_SENTRY_DSN`, `NEXT_PUBLIC_SENTRY_ORG`, `NEXT_PUBLIC_SENTRY_PROJECT`

See `.env.example` for all available variables.

### Important Configuration Files

- **`next.config.ts`**: Next.js config with Sentry, next-intl, and bundle analyzer
- **`tsconfig.json`**: Strict TypeScript with extensive safety checks
- **`vitest.config.mts`**: Unit test configuration
- **`playwright.config.ts`**: E2E test configuration
- **`lefthook.yml`**: Git hooks configuration

## Skills

This project uses `.skills/` for AI agent instructions (Vercel Agent Skills format).

### UI Primitives (CRITICAL)

When implementing UI, ALWAYS read `.skills/ui-primitives/SKILL.md` first.

- 53 reusable primitives in `src/components/ui/`
- NEVER create new components without checking registry
- NEVER use raw HTML elements when primitives exist

### React Best Practices

Read `.skills/react-best-practices/SKILL.md` when writing React/Next.js code.

### Composition Patterns

Read `.skills/composition-patterns/SKILL.md` when designing component architecture.

### Web Design Guidelines

Read `.skills/web-design-guidelines/SKILL.md` when reviewing UI for accessibility/UX.

## Code Style Notes

- **Prettier**: Semi-colons, single quotes, 2-space tabs, 80 char width
- **ESLint**: Uses @antfu/eslint-config with security plugins
- **TypeScript**: Strict mode with `noUncheckedIndexedAccess` enabled
- Avoid `// @ts-ignore` - fix type issues properly
- Security-focused: XSS prevention, CSP headers, no-unsanitized plugin active
