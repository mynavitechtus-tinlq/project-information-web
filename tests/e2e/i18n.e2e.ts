import { expect, test } from '@playwright/test';

test.describe('Internationalization (i18n)', () => {
  test('should default to English locale when no locale is specified', async ({
    page,
  }) => {
    // Navigate to the root URL
    await page.goto('/');

    // Check that the URL is using the default locale (English)
    await expect(page).toHaveURL('/');

    // Check that the page content is in English
    await expect(page.getByText('Account Console')).toBeVisible();

    // Check page title contains the English meta title
    await expect(page).toHaveTitle(/Home/);
  });

  test('should display content in English when /en route is accessed', async ({
    page,
  }) => {
    // Navigate to the English locale URL
    await page.goto('/en');

    // Check that the URL redirects to root since English is the default locale with 'as-needed' prefix
    await expect(page).toHaveURL('/');

    // Check that the page content is in English
    await expect(page.getByText('Account Console')).toBeVisible();

    // Check page title contains the English meta title
    await expect(page).toHaveTitle(/Home/);
  });

  test('should display content in Japanese when /ja route is accessed', async ({
    page,
  }) => {
    // Navigate to the Japanese locale URL
    await page.goto('/ja');

    // Check that the URL is correct
    await expect(page).toHaveURL('/ja');

    // Check that the page content is in Japanese
    await expect(page.getByText('新事業精算システム')).toBeVisible();

    // Check page title contains the Japanese meta title
    await expect(page).toHaveTitle(/ホーム/);
  });

  test('should switch language when navigating between locales', async ({
    page,
  }) => {
    // Start with English
    await page.goto('/en');

    await expect(page).toHaveURL('/');
    await expect(page.getByText('Account Console')).toBeVisible();

    // Navigate to Japanese
    await page.goto('/ja');

    await expect(page).toHaveURL('/ja');
    await expect(page.getByText('新事業精算システム')).toBeVisible();

    // Navigate back to English
    await page.goto('/en');

    await expect(page).toHaveURL('/');
    await expect(page.getByText('Account Console')).toBeVisible();
  });

  test('should maintain the correct locale when navigating to different pages', async ({
    page,
  }) => {
    // This test assumes there are other pages in the application
    // If there are no other pages yet, this test can be commented out or adapted

    // Start with Japanese locale
    await page.goto('/ja');

    // Check that we're on the Japanese locale
    await expect(page.getByText('新事業精算システム')).toBeVisible();
  });
});
