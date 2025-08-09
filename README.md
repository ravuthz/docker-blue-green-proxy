# Blue Green deployment with nginx as proxy

### Usage:

#### Clone or Copy only _nginx_ folder and _deploy.sh_ files

```bash

# Clone project or copy only (nginx, deploy.sh)
git clone https://github.com/ravuthz/docker-blue-green-proxy.git
cp -r ./docker-blue-green-proxy/nginx ./nginx
cp ./docker-blue-green-proxy/deploy.sh .

# Make sure deploy.sh is executable or use command below
chmod +x deploy.sh

```

#### Update docker-compose.yml create new if not exists

Update the _docker-compose.yml_ make sure have 3 sevices required blue, green and proxy. Make those services at same network exampe `same_network_proxy`. Just expose port for proxy only. Disable traefik is optional server without traefik `traefik.enable=false`

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
