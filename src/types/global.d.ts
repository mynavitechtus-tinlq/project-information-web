import type { getTranslations } from 'next-intl/server';

// Use type safe message keys with `next-intl`
type Messages = typeof import('@/public/locales/en');

// eslint-disable-next-line
declare interface IntlMessages extends Messages {}

declare global {
  type TFunction = Awaited<ReturnType<typeof getTranslations>>;
}
