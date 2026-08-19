import z from 'zod';

export const createLoginFormSchema = (t: TFunction) =>
  z.object({
    email: z.email(t('errors.email', { label: t('login.email') })),
    password: z
      .string()
      .min(1, t('errors.required', { label: t('login.password') })),
  });

export type LoginFormData = z.infer<ReturnType<typeof createLoginFormSchema>>;
