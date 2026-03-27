import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// API URL injected at build time via VITE_API_URL env var
// Fallback to localhost for local dev
const apiUrl = process.env.VITE_API_URL || 'http://localhost:8080'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: apiUrl,
        changeOrigin: true,
        // Optional: log proxy requests in dev
        // configure: (proxy) => { proxy.on('proxyReq', ...) }
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
  // Make env vars available as import.meta.env
  envPrefix: ['VITE_', 'NEXT_PUBLIC_'],
})

