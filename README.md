# Blue Green deployment with nginx as proxy

## Usage:

### 1. Create nginx and deploy files
Clone or Copy only _nginx_ folder and _deploy.sh_ files

```bash

# Clone project or copy only (nginx, deploy.sh)
git clone https://github.com/ravuthz/docker-blue-green-proxy.git
cp -r ./docker-blue-green-proxy/nginx ./nginx
cp ./docker-blue-green-proxy/deploy.sh .

# Make sure deploy.sh is executable or use command below
chmod +x deploy.sh

```

Or use `install.sh` from this repository with exists `curl` command

```bash
curl -L https://raw.githubusercontent.com/ravuthz/docker-blue-green-proxy/refs/heads/main/install.sh | sh
```

### 2. Update `.env` if not exist then copy from `.env.example`

```bash
# .env.example

DOMAIN=local.app
APP_NAME=vite.app
ENVIRONMENT=production

# For Laravel app
APP_ENV=${ENVIRONMENT}

# For NodeJS app
NODE_ENV=${ENVIRONMENT}

```

### 3. Update docker-compose.yml create new if not exists

Update the _docker-compose.yml_ make sure have 3 sevices required blue, green and proxy. Make those services at same network exampe `same_network_proxy`. Just expose port for proxy only. Disable traefik is optional server without traefik `traefik.enable=false`

Deploy without Traefik

```yml
services:
  blue:
    restart: always
    build:
      context: .
      dockerfile: ./Dockerfile
    expose:
      - "80"
    environment:
      NODE_ENV: ${ENVIRONMENT}
    container_name: ${APP_NAME}-${ENVIRONMENT}-blue
    networks:
      - same_network_proxy
    labels:
      - "traefik.enable=false"

  green:
    restart: always
    build:
      context: .
      dockerfile: ./Dockerfile.node
    expose:
      - "80"
    environment:
      NODE_ENV: ${ENVIRONMENT}
    container_name: ${APP_NAME}-${ENVIRONMENT}-green
    networks:
      - same_network_proxy
    labels:
      - "traefik.enable=false"

  proxy:
    restart: always
    build:
      context: .
      dockerfile: nginx/Dockerfile.proxy
    container_name: ${APP_NAME}-${ENVIRONMENT}
    networks:
      - same_network_proxy
    ports:
      - "9192:80"
    depends_on:
      - blue
      - green
networks:
  same_network_proxy:
    driver: bridge
```

Deploy with Traefik

```yml
services:
  blue:
    restart: always
    build:
      context: .
      dockerfile: ./Dockerfile
    expose:
      - "80"
    container_name: ${APP_NAME}-${ENVIRONMENT}-blue
    networks:
      - traefik
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.rule=Host(`${DOMAIN}`)'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.entrypoints=websecure'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.tls=true'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.tls.certresolver=myresolver'
      - 'traefik.http.services.${APP_NAME}-${ENVIRONMENT}.loadbalancer.server.port=80'
  green:
    restart: always
    build:
      context: .
      dockerfile: ./Dockerfile
    expose:
      - "80"
    container_name: ${APP_NAME}-${ENVIRONMENT}-green
    networks:
      - traefik
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.rule=Host(`${DOMAIN}`)'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.entrypoints=websecure'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.tls=true'
      - 'traefik.http.routers.${APP_NAME}-${ENVIRONMENT}.tls.certresolver=myresolver'
      - 'traefik.http.services.${APP_NAME}-${ENVIRONMENT}.loadbalancer.server.port=80'
  proxy:
    restart: always
    build:
      context: .
      dockerfile: nginx/Dockerfile.proxy
    container_name: ${APP_NAME}-${ENVIRONMENT}
    networks:
      - traefik
    ports:
      - "9191:80"
    depends_on:
      - blue
      - green
```
