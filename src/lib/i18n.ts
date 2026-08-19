import { hasLocale } from 'next-intl';
import { getRequestConfig } from 'next-intl/server';

import { routing } from './i18n-routing';

export default getRequestConfig(async ({ requestLocale }) => {
  // Typically corresponds to the `[locale]` segment
  const requested = await requestLocale;
  const locale = hasLocale(routing.locales, requested)
    ? requested
    : routing.defaultLocale;

  return {
    locale,
    // Locale is validated by hasLocale() above, safe to use in dynamic import
    // eslint-disable-next-line no-unsanitized/method -- locale is validated
    messages: (await import(`@/public/locales/${locale}`)).default,
  };
});
