import DOMPurify, { type Config } from 'dompurify';

/**
 * Sanitize HTML content for safe rendering
 * @param dirty - Untrusted HTML string
 * @param options - Optional DOMPurify configuration
 * @returns Sanitized HTML safe for rendering
 * @example
 * ```tsx
 * <div dangerouslySetInnerHTML={{ __html: sanitizeHTML(userContent) }} />
 * ```
 */
export function sanitizeHTML(dirty: string, options?: Config): string {
  const defaultConfig: Config = {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: ['href', 'target', 'rel'],
    ALLOW_DATA_ATTR: false,
  };
  const parseMediaType = {
    PARSER_MEDIA_TYPE:
      options?.PARSER_MEDIA_TYPE as unknown as DOMParserSupportedType,
  };
  return DOMPurify.sanitize(dirty, {
    ...defaultConfig,
    ...options,
    ...parseMediaType,
    RETURN_TRUSTED_TYPE: false,
  }) as string;
}

/**
 * Sanitize and validate URLs
 * @param url - URL string to validate
 * @param allowedProtocols - Allowed URL protocols (default: http, https)
 * @returns Sanitized URL or safe fallback '#'
 * @example
 * ```tsx
 * <a href={sanitizeURL(userProvidedURL)} target="_blank" rel="noopener noreferrer">
 *   Link
 * </a>
 * ```
 */
export function sanitizeURL(
  url: string,
  allowedProtocols: string[] = ['http:', 'https:'],
): string {
  try {
    const parsed = new URL(url);
    if (allowedProtocols.includes(parsed.protocol)) {
      return parsed.href;
    }
  } catch {
    // Silently handle invalid URLs - return safe fallback
    // In production, you might want to log this to a monitoring service
  }
  return '#'; // Safe fallback
}

/**
 * Sanitize CSS values to prevent injection
 * @param value - CSS value string
 * @returns Sanitized CSS value with dangerous characters removed
 * @example
 * ```tsx
 * <div style={{ color: sanitizeCSSValue(userColor) }} />
 * ```
 */
export function sanitizeCSSValue(value: string): string {
  // Remove any potential CSS injection patterns
  const dangerous = /[<>{}()]/g;
  return value.replace(dangerous, '');
}

/**
 * Sanitize CSS color values
 * @param color - Color string (hex, rgb, rgba, hsl, hsla, CSS variables, named colors)
 * @returns Validated color string or empty string if invalid
 * @example
 * ```tsx
 * const safeColor = sanitizeColor(userInputColor);
 * if (safeColor) {
 *   // Use the color
 * }
 * ```
 */
export function sanitizeColor(color: string): string {
  const trimmedColor = color.trim();

  // Allow valid CSS color formats
  const validColorPattern =
    /^(?:#[0-9a-f]{3,8}|rgb\([^)]+\)|rgba\([^)]+\)|hsl\([^)]+\)|hsla\([^)]+\)|var\([^)]+\)|[a-z]+)$/i;

  if (!validColorPattern.test(trimmedColor)) {
    return '';
  }

  // Additional check: ensure no CSS injection patterns like `;` `}` `{`
  if (/[;{}]/.test(trimmedColor)) {
    return '';
  }

  return trimmedColor;
}

/**
 * Sanitize CSS identifier (class names, IDs, custom property names)
 * @param identifier - CSS identifier string
 * @returns Sanitized identifier with only safe characters
 * @example
 * ```tsx
 * const safeId = sanitizeCSSIdentifier(userProvidedId);
 * ```
 */
export function sanitizeCSSIdentifier(identifier: string): string {
  // Allow only alphanumeric characters, hyphens, and underscores
  return identifier.replace(/[^\w-]/g, '');
}

/**
 * Sanitize CSS for use in style tags
 * Uses DOMPurify with strict CSS-only configuration
 * @param css - CSS string to sanitize
 * @returns Sanitized CSS safe for style tag injection
 * @example
 * ```tsx
 * <style dangerouslySetInnerHTML={{ __html: sanitizeCSS(dynamicCSS) }} />
 * ```
 */
export function sanitizeCSS(css: string): string {
  return DOMPurify.sanitize(css, {
    ALLOWED_TAGS: [],
    ALLOWED_ATTR: [],
    KEEP_CONTENT: true,
    RETURN_TRUSTED_TYPE: false,
  }) as string;
}
