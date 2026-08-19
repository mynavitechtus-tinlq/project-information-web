import react from '@vitejs/plugin-react';
import { loadEnv } from 'vite';
import tsconfigPaths from 'vite-tsconfig-paths';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  test: {
    globals: true, // This is needed by @testing-library to be cleaned up after each test
    include: ['tests/unit/**/*.test.{js,jsx,ts,tsx}'],
    coverage: {
      include: ['src/**/*'],
      exclude: ['**/*.d.ts'],
    },
    projects: [
      {
        extends: true, // Inherit root config (plugins, globals, coverage, setupFiles, env)
        test: {
          include: ['**/*.test.tsx'],
          environment: 'jsdom',
          name: 'jsdom',
        },
      },
    ],
    setupFiles: ['./vitest-setup.ts'],
    env: loadEnv('', process.cwd(), ''),
  },
});
