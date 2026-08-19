import type { NextRequest } from 'next/server';
import type {
  PathMatcherParam,
  RouteMatcherParam,
} from '@/types/route-matcher';
import { pathToRegexp } from 'path-to-regexp';

const precomputePathRegex = (patterns: Array<string | RegExp>) => {
  return patterns.map(pattern =>
    pattern instanceof RegExp ? pattern : pathToRegexp(pattern).regexp,
  );
};

/**
 * Creates a function that matches paths against a set of patterns.
 *
 * @param patterns - A string, RegExp, or array of patterns to match against
 * @returns A function that takes a pathname and returns true if it matches any of the patterns
 */
export const createPathMatcher = (patterns: PathMatcherParam) => {
  const routePatterns = [patterns || ''].flat().filter(Boolean);
  const matchers = precomputePathRegex(routePatterns);

  return (pathname: string) => matchers.some(matcher => matcher.test(pathname));
};

/**
 * Returns a function that accepts a `Request` object and returns whether the request matches the list of
 * predefined routes that can be passed in as the first argument.
 *
 * You can use glob patterns to match multiple routes or a function to match against the request object.
 * Path patterns and regular expressions are supported, for example: `['/foo', '/bar(.*)'] or `[/^\/foo\/.*$/]`
 */
export const createRouteMatcher = (routes: RouteMatcherParam) => {
  if (typeof routes === 'function') {
    return (req: NextRequest) => routes(req);
  }
  const matcher = createPathMatcher(routes);
  return (req: NextRequest) => matcher(req.nextUrl.pathname);
};
