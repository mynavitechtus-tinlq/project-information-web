import { useTranslations } from 'next-intl';
import { getTranslations } from 'next-intl/server';

export async function generateMetadata(props: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await props.params;
  const t = await getTranslations({
    locale,
    namespace: 'common',
  });

  return {
    title: t('title'),
  };
}

export default function Index() {
  const t = useTranslations('common');

  return (
    <div className="py-5 [&_p]:my-6">
      <h1 className="text-3xl font-bold">{t('app_name')}</h1>
    </div>
  );
}
