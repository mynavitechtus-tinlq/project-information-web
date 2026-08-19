import type { NextRequest } from 'next/server';
import { describe, expect, it, vi } from 'vitest';

import { createRouteMatcher } from '@/lib/route-matcher';

const mockRequest = (pathname: string) =>
  ({
    nextUrl: { pathname },
  }) as unknown as NextRequest;

describe('createRouteMatcher', () => {
  it('delegates to the provided predicate when routes is a function', () => {
    const predicate = vi.fn().mockReturnValue(true);
    const matcher = createRouteMatcher(predicate);
    const req = mockRequest('/anything');

    expect(matcher(req)).toBe(true);
    expect(predicate).toHaveBeenCalledWith(req);
  });

  it('matches a request when the pathname satisfies at least one string pattern', () => {
    const matcher = createRouteMatcher(['/dashboard/:id', '/account/settings']);

    expect(matcher(mockRequest('/dashboard/42'))).toBe(true);
    expect(matcher(mockRequest('/account/settings'))).toBe(true);
    expect(matcher(mockRequest('/account/profile'))).toBe(false);
  });

  it('supports a mix of string patterns and regular expressions', () => {
    const matcher = createRouteMatcher(['/foo', /^\/bar\/\d+$/]);

    expect(matcher(mockRequest('/foo'))).toBe(true);
    expect(matcher(mockRequest('/bar/123'))).toBe(true);
    expect(matcher(mockRequest('/bar/abc'))).toBe(false);
  });
});
