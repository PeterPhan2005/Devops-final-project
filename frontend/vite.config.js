import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      // Dev: Vite proxy /api/* → backend at localhost:8080
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      }
    }
  },
  build: {
    // Output directory for production build
    outDir: 'dist',
    // Source map for debugging in production
    sourcemap: false,
    // Chunk size warning limit
    chunkSizeWarningLimit: 1000,
  },
  // Expose env vars with VITE_ prefix to the app
  envPrefix: ['VITE_'],
})

