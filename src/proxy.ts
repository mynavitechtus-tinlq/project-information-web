import type { NextRequest } from 'next/server';
import createMiddleware from 'next-intl/middleware';
import { NextResponse } from 'next/server';

import { AUTH_STORAGE_KEY } from '@/features/auth';
import { routing } from '@/lib/i18n-routing';
import { createRouteMatcher } from '@/lib/route-matcher';
import { Logger } from './lib/logger';

const middlewareLogger = Logger.create('middleware');
const handleI18nRouting = createMiddleware(routing);

const isProtectedMatcher = createRouteMatcher([`/{:locale/}dashboard{/*path}`]);

export default async function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Check if current path is protected
  const isProtectedRoute = isProtectedMatcher(request);

  // Get authentication token from cookies
  const token = request.cookies.get(AUTH_STORAGE_KEY.ACCESS_TOKEN)?.value;
  middlewareLogger.info(
    `Handling request for pathname: ${pathname} with token: ${token ? 'present' : 'absent'}`,
  );

  // If the route is protected and no token is found, redirect to login
  if (isProtectedRoute && !token) {
    const redirectUrl = new URL('/login', request.nextUrl.origin);

    return NextResponse.redirect(redirectUrl);
  }

  return handleI18nRouting(request);
}

export const config = {
  // Match all pathnames except for
  // - … if they start with `/api`, `/trpc`, `/_next` or `/_vercel`
  // - … the ones containing a dot (e.g. `favicon.ico`)
  matcher: '/((?!_next|_vercel|monitoring|.*\\..*).*)',
};
