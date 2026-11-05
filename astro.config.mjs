// @ts-check
import { defineConfig, envField } from 'astro/config';

import node from '@astrojs/node';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  output: 'server',
  adapter: node({ mode: 'standalone' }),
  env: {
    schema: {
      API_URL: envField.string({ context: 'server', access: 'secret', url: true }),
    },
  },
  vite: {
    plugins: [tailwindcss()]
  }
});
