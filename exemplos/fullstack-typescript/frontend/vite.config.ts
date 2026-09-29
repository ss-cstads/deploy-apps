import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Em desenvolvimento (npm run dev) o Vite repassa /api para o backend local na 8080,
// como o nginx faz no cluster (nginx.conf). No build, o resultado vai para dist/.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: { '/api': 'http://localhost:8080' },
  },
});
