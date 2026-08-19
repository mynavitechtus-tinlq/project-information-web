# Boilerplate and Starter for Next.js 16+, Tailwind CSS 4, and TypeScript.

### Features

Developer experience first, extremely flexible code structure and only keep what you need:

- ⚡ [Next.js](https://nextjs.org) with App Router support
- 🔥 Type checking [TypeScript](https://www.typescriptlang.org)
- 💎 Integrate with [Tailwind CSS](https://tailwindcss.com)
- ✅ Strict Mode for TypeScript and React 19
- 🌐 Multi-language (i18n) with [next-intl](https://next-intl-docs.vercel.app/)
- ♻️ Type-safe environment variables with T3 Env
- ⌨️ Form handling with React Hook Form
- 🔴 Validation library with Zod
- 📏 Linter with [ESLint](https://eslint.org)
- 💖 Code Formatter with [Prettier](https://prettier.io)
- 🦊 LeftHook for Git Hooks
- 🦺 Unit Testing with Vitest and React Testing Library
- 🧪 Integration and E2E Testing with Playwright
- 🚨 Error Monitoring with [Sentry](https://sentry.io/for/nextjs)
- 💡 Absolute Imports using `@` prefix
- 🗺️ Sitemap.xml and robots.txt
- ⚙️ [Bundler Analyzer](https://www.npmjs.com/package/@next/bundle-analyzer)

Built-in feature from Next.js:

- ☕ Minify HTML & CSS
- 💨 Live reload
- ✅ Cache busting

### Requirements

- Node.js 24.11.1+ and npm 10.9.2+

### Getting started

You can run the project locally in development mode with live reload by executing:

```shell
npm run dev
```

Open http://localhost:3000 with your favorite browser to see your project.

### Project structure

```shell
.
├── README.md                                   # README file
├── .i18n                                       # I18n scripts
├── docs                                        # Documentation folder
│   └── components                              # Documentation components
├── public                                      # Public assets folder
│   ├── assets                                  # Assets folder
│   └── locales                                 # Locales for i18n
├── src
│   ├── app                                     # Next JS App (App Router)
│   │   ├─ [locale]                             # Locale-specific routes
│   │   │   ├─ (routes)                         # Route groups
│   │   │   ├─ layout.tsx                       # Root layout
│   │   │   └─ page.tsx                         # Root page
│   │   ├─ global-error.tsx                     # Global error handler
│   │   ├─ robots.ts                            # Robots.txt
│   │   └─ sitemap.ts                           # Sitemap.xml
│   ├── components                              # Shared component library
│   │   ├── ui                                  # UI primitives (buttons, modals, etc.)
│   │   ├── providers                          # Context providers (ThemeProvider, etc.)
│   │   └── templates                           # Layout components (header, footer, etc.)
│   ├── features                                # Feature-based modules (Bulletproof Next.js)
│   │   └── [feature-name]/                     # Self-contained feature modules
│   │       ├── api/                            # Server Actions and API calls
│   │       ├── components/                    # Feature-specific components
│   │       ├── config/                         # Feature configuration (constants, storage keys)
│   │       ├── hooks/                          # Feature-specific React hooks
│   │       ├── lib/                            # Feature utilities, schemas, business logic
│   │       ├── types/                          # Feature-specific TypeScript types
│   │       └── index.ts                        # Public API (exports only)
│   ├── config                                  # Application configuration
│   │   └── app-config.ts                       # App settings (locales, name, etc.)
│   ├── hooks                                   # Shared React hooks
│   ├── lib                                     # Third-party integrations and utilities
│   ├── stores                                  # State management (Zustand, Redux, etc.)
│   ├── styles                                  # Tailwind, tokens, themes, global styles
│   │   └── globals.css                         # Global styles
│   ├── types                                   # Global types, utilities types
│   ├── instrumentation.ts                      # Sentry instrumentation files
│   ├── instrumentation-client.ts               # Sentry client-side instrumentation
│   └── proxy.ts                                # Middleware for routing and auth
├── tests
│   ├── unit                                    # Unit tests
│   ├── e2e                                     # E2E tests, also includes Monitoring as Code
│   └── integration                             # Integration tests
└── tsconfig.json                               # TypeScript configuration
```

### Testing

All unit tests are located alongside the source code in the same directory, making them easier to find. The project uses Vitest and React Testing Library for unit testing. You can run the tests with the following command:

```shell
npm run test:unit
```

### Integration & E2E Testing

The project uses Playwright for integration and end-to-end (E2E) testing. You can run the tests with the following commands:

```shell
npx playwright install # Only for the first time in a new environment
npm run test:e2e
```

### Linting and Formatting

The project uses ESLint and Prettier for linting and formatting. You can run the linter with the following command:

```shell
npm run lint
```

### Deploy to production

You can generate a production build with:

```shell
$ npm run build
```

It generates an optimized production build of the boilerplate. To test the generated build, run:

```shell
$ npm run start
```

This command starts a local server using the production build. You can now open http://localhost:3000 in your preferred browser to see the result.

### Docker

Build the production image (standalone output) with:

```shell
docker build -t nals-fe-reactjs .
```

Run the container locally and expose it on port 3000:

```shell
docker run --rm -p 3000:3000 --env-file .env.production nals-fe-reactjs
```

Replace `.env.production` with the file that holds your production-ready environment variables before deploying.

### Error Monitoring

The project uses [Sentry](https://sentry.io/for/nextjs/) to monitor errors. In the development environment, no additional setup is needed: Next.js Boilerplate is pre-configured to use Sentry and Spotlight (Sentry for Development). All errors will automatically be sent to your local Spotlight instance, allowing you to experience Sentry locally.

For production environment, you'll need to create a Sentry account and a new project. Then, in `next.config.mjs`, you need to update the `org` and `project` attributes in `withSentryConfig` function. Additionally, add your Sentry DSN to `instrumentation-client.ts`, `instrumentation.ts`.

### Useful commands

#### Bundle Analyzer

TechTus Next.js includes a built-in bundle analyzer. It can be used to analyze the size of your JavaScript bundles. To begin, run the following command:

```shell
npm run build-stats
```

By running the command, it'll automatically open a new browser window with the results.

### Deploy to AWS Amplify

- [Making environment variables accessible to server-side runtimes](https://docs.aws.amazon.com/amplify/latest/userguide/ssr-environment-variables.html)
- [Failed to find Server Action](https://nextjs.org/docs/app/guides/data-security#overwriting-encryption-keys-advanced)
# project-information-web
