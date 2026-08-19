import { describe, expect, it } from 'vitest';
import {
  sanitizeColor,
  sanitizeCSS,
  sanitizeCSSIdentifier,
  sanitizeCSSValue,
  sanitizeHTML,
  sanitizeURL,
} from '@/lib/sanitize';

describe('sanitizeColor', () => {
  it('should allow valid hex colors', () => {
    expect(sanitizeColor('#fff')).toBe('#fff');
    expect(sanitizeColor('#ffffff')).toBe('#ffffff');
    expect(sanitizeColor('#ff00ff')).toBe('#ff00ff');
    expect(sanitizeColor('#FF00FF')).toBe('#FF00FF');
    expect(sanitizeColor('#f0f0f080')).toBe('#f0f0f080'); // 8-digit hex with alpha
  });

  it('should allow valid rgb/rgba colors', () => {
    expect(sanitizeColor('rgb(255, 0, 0)')).toBe('rgb(255, 0, 0)');
    expect(sanitizeColor('rgba(255, 0, 0, 0.5)')).toBe('rgba(255, 0, 0, 0.5)');
    expect(sanitizeColor('rgb(100%, 0%, 0%)')).toBe('rgb(100%, 0%, 0%)');
  });

  it('should allow valid hsl/hsla colors', () => {
    expect(sanitizeColor('hsl(120, 100%, 50%)')).toBe('hsl(120, 100%, 50%)');
    expect(sanitizeColor('hsla(120, 100%, 50%, 0.5)')).toBe(
      'hsla(120, 100%, 50%, 0.5)',
    );
  });

  it('should allow CSS variables', () => {
    expect(sanitizeColor('var(--primary-color)')).toBe('var(--primary-color)');
    expect(sanitizeColor('var(--bg-color)')).toBe('var(--bg-color)');
  });

  it('should allow named colors', () => {
    expect(sanitizeColor('red')).toBe('red');
    expect(sanitizeColor('blue')).toBe('blue');
    expect(sanitizeColor('transparent')).toBe('transparent');
  });

  it('should reject CSS injection attempts with semicolons', () => {
    expect(sanitizeColor('red;} body{display:none;}')).toBe('');
    expect(sanitizeColor('#fff; background: url(evil)')).toBe('');
  });

  it('should reject CSS injection attempts with braces', () => {
    expect(sanitizeColor('red} .malicious{color:red')).toBe('');
    expect(sanitizeColor('{background:red}')).toBe('');
  });

  it('should reject javascript: protocol attempts', () => {
    expect(sanitizeColor('url(javascript:alert(1))')).toBe('');
  });

  it('should reject invalid color formats', () => {
    expect(sanitizeColor('not-a-color-123')).toBe('');
    expect(sanitizeColor('rgb(999, 999, 999) extra')).toBe('');
    expect(sanitizeColor('<script>alert(1)</script>')).toBe('');
  });

  it('should handle empty and whitespace strings', () => {
    expect(sanitizeColor('')).toBe('');
    expect(sanitizeColor('   ')).toBe('');
    expect(sanitizeColor('  #fff  ')).toBe('#fff'); // Should trim
  });
});

describe('sanitizeURL', () => {
  it('should allow valid HTTP/HTTPS URLs', () => {
    expect(sanitizeURL('https://example.com')).toBe('https://example.com/');
    expect(sanitizeURL('http://example.com')).toBe('http://example.com/');
    expect(sanitizeURL('https://example.com/path?query=value')).toContain(
      'https://example.com/path',
    );
  });

  it('should reject javascript: protocol', () => {
    expect(sanitizeURL('javascript:alert(1)')).toBe('#');
    expect(sanitizeURL('javascript:void(0)')).toBe('#');
  });

  it('should reject data: URIs by default', () => {
    expect(sanitizeURL('data:text/html,<script>alert(1)</script>')).toBe('#');
    expect(sanitizeURL('data:image/png;base64,abc123')).toBe('#');
  });

  it('should reject file: protocol', () => {
    expect(sanitizeURL('file:///etc/passwd')).toBe('#');
  });

  it('should reject vbscript: protocol', () => {
    expect(sanitizeURL('vbscript:msgbox(1)')).toBe('#');
  });

  it('should handle invalid URLs gracefully', () => {
    expect(sanitizeURL('not a url')).toBe('#');
    expect(sanitizeURL('://invalid')).toBe('#');
    expect(sanitizeURL('')).toBe('#');
  });

  it('should allow custom protocols when specified', () => {
    expect(sanitizeURL('mailto:test@example.com', ['mailto:'])).toBe(
      'mailto:test@example.com',
    );
    expect(sanitizeURL('tel:+1234567890', ['tel:'])).toBe('tel:+1234567890');
  });

  it('should preserve URL fragments and query params', () => {
    const url = sanitizeURL('https://example.com/page#section?foo=bar');

    expect(url).toContain('https://example.com/page');
  });
});

describe('sanitizeHTML', () => {
  it('should remove script tags', () => {
    const dirty = '<p>Hello</p><script>alert(1)</script>';
    const clean = sanitizeHTML(dirty);

    expect(clean).not.toContain('<script>');
    expect(clean).toContain('Hello');
  });

  it('should remove event handlers', () => {
    const dirty = '<a href="#" onclick="alert(1)">Link</a>';
    const clean = sanitizeHTML(dirty);

    expect(clean).not.toContain('onclick');
    expect(clean).toContain('Link');
  });

  it('should remove iframe tags', () => {
    const dirty = '<p>Text</p><iframe src="evil.com"></iframe>';
    const clean = sanitizeHTML(dirty);

    expect(clean).not.toContain('<iframe>');
    expect(clean).toContain('Text');
  });

  it('should allow safe tags', () => {
    const dirty = '<p>Paragraph</p><strong>Bold</strong><em>Italic</em>';
    const clean = sanitizeHTML(dirty);

    expect(clean).toContain('<p>');
    expect(clean).toContain('<strong>');
    expect(clean).toContain('<em>');
  });

  it('should allow safe links with proper attributes', () => {
    const dirty =
      '<a href="https://example.com" target="_blank" rel="noopener">Link</a>';
    const clean = sanitizeHTML(dirty);

    expect(clean).toContain('href');
    expect(clean).toContain('example.com');
  });

  it('should remove javascript: href', () => {
    const dirty = '<a href="javascript:alert(1)">Evil Link</a>';
    const clean = sanitizeHTML(dirty);

    expect(clean).not.toContain('javascript:');
  });

  it('should handle empty strings', () => {
    expect(sanitizeHTML('')).toBe('');
  });

  it('should allow custom configuration', () => {
    const dirty = '<div class="test">Content</div>';
    const clean = sanitizeHTML(dirty, {
      ALLOWED_TAGS: ['div'],
      ALLOWED_ATTR: ['class'],
    });

    expect(clean).toContain('<div');
    expect(clean).toContain('class');
  });
});

describe('sanitizeCSSValue', () => {
  it('should allow valid CSS values', () => {
    expect(sanitizeCSSValue('10px')).toBe('10px');
    expect(sanitizeCSSValue('red')).toBe('red');
    expect(sanitizeCSSValue('1.5em')).toBe('1.5em');
  });

  it('should remove dangerous characters', () => {
    expect(sanitizeCSSValue('10px<script>')).toBe('10pxscript');
    expect(sanitizeCSSValue('red{}')).toBe('red');
    expect(sanitizeCSSValue('blue()')).toBe('blue');
  });

  it('should handle empty strings', () => {
    expect(sanitizeCSSValue('')).toBe('');
  });
});

describe('sanitizeCSSIdentifier', () => {
  it('should allow valid identifiers', () => {
    expect(sanitizeCSSIdentifier('my-class')).toBe('my-class');
    expect(sanitizeCSSIdentifier('my_class')).toBe('my_class');
    expect(sanitizeCSSIdentifier('class123')).toBe('class123');
  });

  it('should remove invalid characters', () => {
    expect(sanitizeCSSIdentifier('my class')).toBe('myclass');
    expect(sanitizeCSSIdentifier('class@name')).toBe('classname');
    expect(sanitizeCSSIdentifier('class!name#test')).toBe('classnametest');
  });

  it('should remove dangerous characters', () => {
    expect(sanitizeCSSIdentifier('class;}{<>')).toBe('class');
    expect(sanitizeCSSIdentifier('id"value"')).toBe('idvalue');
  });

  it('should handle empty strings', () => {
    expect(sanitizeCSSIdentifier('')).toBe('');
  });

  it('should preserve hyphens and underscores', () => {
    expect(sanitizeCSSIdentifier('btn-primary_active')).toBe(
      'btn-primary_active',
    );
  });
});

describe('sanitizeCSS', () => {
  it('should sanitize CSS content', () => {
    const css = '.class { color: red; }';
    const sanitized = sanitizeCSS(css);

    expect(sanitized).toBeTruthy();
    expect(sanitized).toContain('color');
  });

  it('should remove script tags from CSS', () => {
    const css = '.class { color: red; } <script>alert(1)</script>';
    const sanitized = sanitizeCSS(css);

    expect(sanitized).not.toContain('<script>');
  });

  it('should handle empty CSS', () => {
    expect(sanitizeCSS('')).toBe('');
  });

  it('should preserve CSS custom properties', () => {
    const css = ':root { --primary: #007bff; }';
    const sanitized = sanitizeCSS(css);

    expect(sanitized).toContain('--primary');
  });
});

describe('Integration: Chart Component Security', () => {
  it('should prevent CSS injection via color values', () => {
    const maliciousColor = 'red;} body{display:none;} .evil{';
    const sanitized = sanitizeColor(maliciousColor);

    expect(sanitized).toBe('');
  });

  it('should prevent CSS injection via identifier keys', () => {
    const maliciousKey = 'primary;} .evil{color:red';
    const sanitized = sanitizeCSSIdentifier(maliciousKey);

    expect(sanitized).not.toContain(';');
    expect(sanitized).not.toContain('{');
    expect(sanitized).not.toContain('}');
  });

  it('should handle valid chart configuration safely', () => {
    const validConfig = {
      id: 'chart-123',
      colors: {
        primary: '#007bff',
        secondary: 'rgb(108, 117, 125)',
        success: 'hsl(120, 100%, 50%)',
        warning: 'var(--warning-color)',
      },
    };

    // Test sanitization of all values
    expect(sanitizeColor(validConfig.colors.primary)).toBe('#007bff');
    expect(sanitizeColor(validConfig.colors.secondary)).toBe(
      'rgb(108, 117, 125)',
    );
    expect(sanitizeColor(validConfig.colors.success)).toBe(
      'hsl(120, 100%, 50%)',
    );
    expect(sanitizeColor(validConfig.colors.warning)).toBe(
      'var(--warning-color)',
    );
    expect(sanitizeCSSIdentifier(validConfig.id)).toBe('chart-123');
  });

  it('should reject all malicious chart configurations', () => {
    const maliciousConfigs = [
      { key: 'color', value: 'red;} body{background:url(evil.com)}' },
      { key: 'bg;}{.evil{', value: '#fff' },
      { key: 'primary', value: 'javascript:alert(1)' },
      { key: 'test', value: '<script>alert(1)</script>' },
    ];

    maliciousConfigs.forEach(({ key, value }) => {
      const sanitizedKey = sanitizeCSSIdentifier(key);
      const sanitizedValue = sanitizeColor(value);

      // Ensure no injection characters survive
      expect(sanitizedKey).not.toContain(';');
      expect(sanitizedKey).not.toContain('{');
      expect(sanitizedKey).not.toContain('}');
      expect(sanitizedValue).not.toContain(';');
      expect(sanitizedValue).not.toContain('{');
      expect(sanitizedValue).not.toContain('}');
      expect(sanitizedValue).not.toContain('<script>');
    });
  });
});
