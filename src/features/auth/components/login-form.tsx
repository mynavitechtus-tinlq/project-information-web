'use client';

import type { LoginFormData } from '../lib/schemas';
import { zodResolver } from '@hookform/resolvers/zod';
import { Eye, EyeOff, Loader2 } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { useState, useTransition } from 'react';
import { useForm } from 'react-hook-form';

import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import {
  InputGroup,
  InputGroupAddon,
  InputGroupButton,
  InputGroupInput,
} from '@/components/ui/input-group';
import { login } from '../api/auth-action';
import { createLoginFormSchema } from '../lib/schemas';

export default function LoginForm() {
  const t = useTranslations();
  const [isPending, startTransition] = useTransition();
  const [hidePassword, setHidePassword] = useState(true);
  const [serverMessage, setServerMessage] = useState<{
    success: boolean;
    message: string;
  } | null>(null);

  const LoginFormSchema = createLoginFormSchema(t);

  const form = useForm<LoginFormData>({
    resolver: zodResolver(LoginFormSchema),
    defaultValues: {
      email: '',
      password: '',
    },
    mode: 'onBlur',
  });

  const onSubmit = (data: LoginFormData) => {
    setServerMessage(null);

    startTransition(async () => {
      const result = await login(data);
      setServerMessage(result);
    });
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted p-4">
      <Card className="w-full max-w-md bg-card text-card-foreground shadow-sm">
        <CardHeader className="space-y-1 text-center">
          <CardTitle className="text-2xl font-bold tracking-tight">
            {t('login.title')}
          </CardTitle>
          <CardDescription>{t('login.sub_title')}</CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              <FormField
                control={form.control}
                name="email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('login.email')}</FormLabel>
                    <FormControl>
                      <Input
                        {...field}
                        type="text"
                        placeholder={t('login.email_placeholder')}
                        disabled={isPending}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('login.password')}</FormLabel>
                    <FormControl>
                      <InputGroup>
                        <InputGroupInput
                          {...field}
                          type={hidePassword ? 'password' : 'text'}
                          placeholder={t('login.password_placeholder')}
                          disabled={isPending}
                        />
                        <InputGroupAddon align="inline-end">
                          <InputGroupButton
                            type="button"
                            size="icon-xs"
                            aria-label={
                              hidePassword
                                ? t('login.show_password')
                                : t('login.hide_password')
                            }
                            onClick={() => setHidePassword(prev => !prev)}
                            disabled={isPending}
                          >
                            {hidePassword ? <EyeOff /> : <Eye />}
                          </InputGroupButton>
                        </InputGroupAddon>
                      </InputGroup>
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <Button
                type="submit"
                className="h-10 w-full font-medium"
                disabled={isPending}
              >
                {isPending ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    {t('login.signing_in')}
                  </>
                ) : (
                  t('login.sign_in')
                )}
              </Button>

              {serverMessage && (
                <div
                  className={`flex items-center gap-2 rounded-md p-3 text-sm ${
                    serverMessage.success
                      ? 'border border-green-200 bg-green-50 text-green-700 dark:border-green-800 dark:bg-green-900/20 dark:text-green-300'
                      : 'border border-red-200 bg-red-50 text-red-700 dark:border-red-800 dark:bg-red-900/20 dark:text-red-300'
                  }`}
                >
                  {serverMessage.message}
                </div>
              )}
            </form>
          </Form>

          <div className="mt-6 text-center">
            <p className="text-sm">
              {t('login.no_account')}
              <button
                type="button"
                className="font-medium underline-offset-4 hover:underline"
              >
                {t('login.sign_up')}
              </button>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
