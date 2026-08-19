import type Link from 'next/link';
import type { NextRequest } from 'next/server';

/**
 * Enables autocompletion for a union type, while keeping the ability to use any string
 * or type of `T`
 *
 * @internal
 */
export type Autocomplete<U extends T$1, T$1 = string> =
  | U
  | (T$1 & Record<never, never>);

export type WithPathPatternWildcard<T = string> = `${T & string}{/*path}`;

export type NextTypedRoute<T = Parameters<typeof Link>['0']['href']> =
  T extends string ? T : never;

export type RouteMatcherWithNextTypedRoutes = Autocomplete<
  WithPathPatternWildcard<NextTypedRoute> | NextTypedRoute
>;

export type RouteMatcherParam =
  | Array<RegExp | RouteMatcherWithNextTypedRoutes>
  | RegExp
  | RouteMatcherWithNextTypedRoutes
  | ((req: NextRequest) => boolean);

export type PathPattern = Autocomplete<WithPathPatternWildcard>;

export type PathMatcherParam =
  | Array<RegExp | PathPattern>
  | RegExp
  | PathPattern;
