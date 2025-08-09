# Build stage

FROM oven/bun:1.2.7 AS builder

WORKDIR /app

COPY vite-app/package*.json vite-app/bun.lock ./

RUN bun install

COPY vite-app /app

RUN bun run build

# Deploy stage

FROM nginx:1.28-alpine3.21

# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Write custom nginx config
RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
    listen       80;
    listen  [::]:80;
    server_name localhost;
    client_max_body_size 100M;

    root /usr/share/nginx/html;
    index index.html;

    # Handle static assets
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri $uri/ =404;
    }

    # Handle root and client-side routes (SPA fallback)
    location / {
        try_files $uri /index.html;
    }

    # Optional: enable gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_proxied any;
    gzip_vary on;
}
EOF

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]