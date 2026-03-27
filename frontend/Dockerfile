# ─────────────────────────────────────────────────────────
# Stage 1: Build
# ─────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files first (better Docker cache)
COPY package*.json ./

# Install dependencies
RUN npm ci --ci --prefer-offline

# Copy source code
COPY . .

# Build with API URL injected at build time
ARG API_URL=http://localhost:8080
ENV VITE_API_URL=$API_URL

RUN npm run build

# ─────────────────────────────────────────────────────────
# Stage 2: Production (NGINX)
# ─────────────────────────────────────────────────────────
FROM nginx:1.25-alpine

# Remove default NGINX config
RUN rm /etc/nginx/conf.d/default.conf

# Copy built React app
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Security: run as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
