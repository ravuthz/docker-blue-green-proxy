#!/bin/sh

# curl -L -o deploy.sh https://github.com/ravuthz/docker-blue-green-proxy/raw/main/deploy.sh && chmod +x deploy.sh && chmod +x deploy.sh

curl -L -o deploy.sh https://raw.githubusercontent.com/ravuthz/docker-blue-green-proxy/refs/heads/main/deploy.sh && chmod +x deploy.sh

mkdir nginx

curl -L -o nginx/blue.conf https://raw.githubusercontent.com/ravuthz/docker-blue-green-proxy/refs/heads/main/nginx/blue.conf
curl -L -o nginx/green.conf https://raw.githubusercontent.com/ravuthz/docker-blue-green-proxy/refs/heads/main/nginx/green.conf
curl -L -o nginx/nginx.conf https://raw.githubusercontent.com/ravuthz/docker-blue-green-proxy/refs/heads/main/nginx/nginx.conf
curl -L -o nginx/Dockerfile.proxy https://raw.githubusercontent.com/ravuthz/docker-blue-green-proxy/refs/heads/main/nginx/Dockerfile.proxy
