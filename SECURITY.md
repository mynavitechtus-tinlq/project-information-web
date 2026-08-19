# Security Guidelines

This document outlines security best practices and guidelines for the Fair Foreign Event Restaurant Frontend application.

## Table of Contents

- [XSS Prevention](#xss-prevention)
- [Using Sanitization Helpers](#using-sanitization-helpers)
- [Security Checklist](#security-checklist)
- [Reporting Security Issues](#reporting-security-issues)

## XSS Prevention

### ✅ DO

- **Use React's JSX for rendering user content** - React automatically escapes content
- **Validate and sanitize all user inputs** - Use Zod schemas for validation
- **Use sanitization helpers** - Import from `@/lib/sanitize` for HTML, URLs, CSS
- **Implement CSP headers** - Already configured in `next.config.ts`
- **Keep dependencies updated** - Run `npm run security:audit` regularly
- **Use TypeScript strictly** - Leverage type safety to prevent injection
- **Validate API responses** - Don't trust external data sources

### ❌ DON'T

- **Never use `dangerouslySetInnerHTML` without sanitization** - Always use `sanitizeHTML()` first
- **Never trust user input** - Always validate and sanitize
- **Never concatenate user data into HTML/CSS/JS strings** - Use template parameters
- **Never disable security features** - Keep CSP headers enabled
- **Never use `eval()` or `Function()` constructor** - They execute arbitrary code
- **Never use `innerHTML`, `outerHTML`, or `document.write`** - Use safe DOM methods
- **Never bypass ESLint security warnings** - Fix the underlying issue instead

## Using Sanitization Helpers

The `@/lib/sanitize` module provides helper functions for safe content handling.

### Sanitizing HTML Content

```tsx
import { sanitizeHTML } from '@/lib/sanitize';

// Safe HTML rendering
function MyComponent({ userContent }: { userContent: string }) {
  return (
    <div
      dangerouslySetInnerHTML={{
        __html: sanitizeHTML(userContent),
      }}
    />
  );
}
```

### Sanitizing URLs

```tsx
import { sanitizeURL } from '@/lib/sanitize';

// Safe URL handling
function MyLink({ userProvidedURL }: { userProvidedURL: string }) {
  return (
    <a
      href={sanitizeURL(userProvidedURL)}
      target="_blank"
      rel="noopener noreferrer"
    >
      Visit Link
    </a>
  );
}
```

### Sanitizing CSS Colors

```tsx
import { sanitizeColor } from '@/lib/sanitize';

// Safe color value handling (for chart components, themes, etc.)
function ColorPicker({ userColor }: { userColor: string }) {
  const safeColor = sanitizeColor(userColor);

  if (!safeColor) {
    return <div>Invalid color</div>;
  }

  return <div style={{ backgroundColor: safeColor }}>Color Preview</div>;
}
```

### Sanitizing CSS Identifiers

```tsx
import { sanitizeCSSIdentifier } from '@/lib/sanitize';

// Safe CSS class/id generation
function DynamicComponent({ userId }: { userId: string }) {
  const safeId = sanitizeCSSIdentifier(userId);

  return <div id={`user-${safeId}`}>User Content</div>;
}
```

### Custom Sanitization Options

```tsx
import { sanitizeHTML } from '@/lib/sanitize';

// Allow specific HTML tags and attributes
const clean = sanitizeHTML(dirty, {
  ALLOWED_TAGS: ['div', 'span', 'b', 'i', 'strong', 'em'],
  ALLOWED_ATTR: ['class', 'id'],
});
```

## Security Checklist

### Before Each Commit

- [ ] Run `npm run lint` (no errors)
- [ ] Run `npm run test:unit` (all tests passing)
- [ ] Review changes for security implications
- [ ] Check for hardcoded secrets or API keys

### Before Each Pull Request

- [ ] Run `npm run security:audit` (no moderate+ vulnerabilities)
- [ ] Update tests for new features
- [ ] Document security-relevant changes
- [ ] Request security-focused code review

### Before Each Release

- [ ] Run full security audit: `npm run security:check`
- [ ] Update all dependencies: `npm update`
- [ ] Review and update CSP policy if needed
- [ ] Test authentication flows
- [ ] Verify HTTPS enforcement in production

### Development Best Practices

#### Authentication & Authorization

- **Use httpOnly cookies** - Already configured for JWT tokens
- **Implement proper session management** - Tokens expire after x hour
- **Use secure cookie flags** - `httpOnly`, `secure`, `sameSite: 'strict'`
- **Validate tokens on server-side** - Never trust client-side validation alone

#### Input Validation

```tsx
import { z } from 'zod';

// Always define schemas for user inputs
const formSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().max(100),
});

// Use with React Hook Form
const form = useForm({
  resolver: zodResolver(formSchema),
});
```

#### API Security

- **Validate all API responses** - Don't trust external APIs
- **Use environment variables for secrets** - Never commit secrets
- **Implement rate limiting** - Prevent abuse
- **Use HTTPS only** - Enforce in production

#### Form Handling

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

function SecureForm() {
  const form = useForm({
    resolver: zodResolver(schema), // ✅ Always use schema validation
  });

  async function onSubmit(data: FormData) {
    // ✅ Data is validated by Zod schema
    // ✅ React Hook Form handles sanitization
    await submitToAPI(data);
  }

  return <form onSubmit={form.handleSubmit(onSubmit)}>...</form>;
}
```

## Common Vulnerabilities & Mitigations

### XSS (Cross-Site Scripting)

**Risk**: Attackers inject malicious scripts into web pages

**Mitigations**:

- ✅ React's automatic escaping (use JSX)
- ✅ Sanitization helpers for `dangerouslySetInnerHTML`
- ✅ Content Security Policy headers
- ✅ ESLint security rules

### CSRF (Cross-Site Request Forgery)

**Risk**: Attackers trick users into performing unwanted actions

**Mitigations**:

- ✅ `sameSite: 'strict'` cookie flag
- ✅ CSRF tokens (implement if needed)
- ✅ Validate request origin

### Injection Attacks

**Risk**: SQL/NoSQL/Command injection through user input

**Mitigations**:

- ✅ Zod schema validation
- ✅ Parameterized queries (use ORM)
- ✅ Never concatenate user input into queries

### Sensitive Data Exposure

**Risk**: Exposing sensitive information in logs, errors, or responses

**Mitigations**:

- ✅ Don't log sensitive data
- ✅ Use environment variables for secrets
- ✅ Sanitize error messages shown to users
- ✅ Don't expose stack traces in production

## Security Testing

### Running Security Audits

```bash
# Check for known vulnerabilities in dependencies
npm run security:audit

# Fix automatically fixable vulnerabilities
npm run security:fix

# Run security audit + linting
npm run security:check
```

### Manual Testing

Test for XSS vulnerabilities by attempting to inject:

```javascript
// Try these in user inputs (should all be blocked)
<script>alert('XSS')</script>
javascript:alert('XSS')
<img src=x onerror=alert('XSS')>
'; DROP TABLE users; --
```

## Reporting Security Issues

If you discover a security vulnerability in this application:

1. **DO NOT** create a public GitHub/Bitbucket/Gitlab issue
2. **DO NOT** disclose the vulnerability publicly
3. Email the security team immediately: `security@yourcompany.com`
4. Include detailed steps to reproduce the vulnerability
5. Wait for confirmation and a fix before disclosing

### What to Include in Security Reports

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Affected versions/components
- Suggested fix (if you have one)

## Security Resources

### Documentation

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [React Security Best Practices](https://react.dev/learn/reacting-to-input-with-state#security-considerations)
- [Next.js Security Headers](https://nextjs.org/docs/app/building-your-application/configuring/content-security-policy)
- [DOMPurify Documentation](https://github.com/cure53/DOMPurify)

### Tools

- [npm audit](https://docs.npmjs.com/cli/v8/commands/npm-audit)
- [ESLint Security Plugin](https://github.com/eslint-community/eslint-plugin-security)
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)

## Revision History

| Version | Date       | Author        | Changes                     |
| ------- | ---------- | ------------- | --------------------------- |
| 1.0.0   | 2025-10-31 | Security Team | Initial security guidelines |

---

**Last Updated**: October 31, 2025
**Next Review**: January 31, 2026
