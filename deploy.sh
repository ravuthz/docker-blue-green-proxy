#!/bin/sh

set -e
export COMPOSE_BAKE=true

# Define color codes
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color / reset

# Load .env file located in the same directory as the script, if it exists
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit 1; pwd)
if [ -f "$SCRIPT_DIR/.env" ]; then
  # Use dot to source .env in POSIX sh
  . "$SCRIPT_DIR/.env"
fi

print() {
  printf "\n%s\n\n" "$1"
}

# Check required environment variables
if [ -z "$DOMAIN" ]; then
  echo "Error: DOMAIN is not set."
  exit 1
fi

if [ -z "$APP_NAME" ]; then
  echo "Error: APP_NAME is not set."
  exit 1
fi

if [ -z "$ENVIRONMENT" ]; then
  echo "Error: ENVIRONMENT is not set."
  exit 1
fi

RUNNING_SERVICES=$(docker compose ps --status running --services)

# Properly handle multiline output from RUNNING_SERVICES
CURRENT_COLOR=$(printf '%s\n' "$RUNNING_SERVICES" | grep -E '^(blue|green)$' | head -n 1 || true)

echo " "
echo "=================================="
echo " 🚀  ${BLUE}Blue${NC}-${GREEN}Green${NC} Lazy Deployment 🚀 "
echo "=================================="
echo " "
if [ "$CURRENT_COLOR" = "blue" ]; then
  echo "${YELLOW}COLOR${NC} ${BLUE}$CURRENT_COLOR${NC}"
elif [ "$CURRENT_COLOR" = "green" ]; then
  echo "${YELLOW}COLOR${NC} ${GREEN}$CURRENT_COLOR${NC}"
else
  echo "${YELLOW}COLOR${NC} $CURRENT_COLOR"
fi

echo "${YELLOW}DOMAIN${NC}: $DOMAIN"
echo "${YELLOW}APP_NAME${NC}: $APP_NAME"
echo "${YELLOW}ENVIRONMENT${NC}: $ENVIRONMENT"

echo " "
if [ -z "$CURRENT_COLOR" ]; then
  echo " "
  echo "No blue or green service are running"
  echo "Debug error via 'docker compose ps' or 'docker ps --filter=\"name=$APP_NAME*\"'"
  echo " "
  docker compose ps
  echo " "
  docker compose up -d
else
  docker compose up proxy -d --build
fi

if [ "$CURRENT_COLOR" = "blue" ]; then
  print "🏗️  Building green images..."
  docker compose build green
  print "🏁 Starting green services..."
  docker compose up green -d

  # Let nginx swap to green
  docker compose cp nginx/green.conf proxy:/etc/nginx/conf.d/default.conf

  docker compose stop blue
else
  print "🏗️  Building blue images..."
  docker compose build blue
  print "🏁 Starting blue services..."
  docker compose up blue -d

  # Let nginx swap to blue
  docker compose cp nginx/blue.conf proxy:/etc/nginx/conf.d/default.conf

  docker compose stop green
fi

# Wait the container ready that reload confiure of proxy

docker compose exec proxy nginx -s reload

printf "\n⌛ Ping proxy localhost:80 ... "

sleep 3

docker compose exec proxy sh -c 'curl -s -o /dev/null -w "%{http_code}" http://localhost:80'

printf "\n⌛ Ping $DOMAIN ... \n"

sleep 3

if curl -s -f -k --max-time 3 "$DOMAIN" >/dev/null 2>&1; then
  print "✅ $APP_NAME can access via $DOMAIN"
else
  print "⚠️ $APP_NAME can not access from $DOMAIN"
fi

docker compose ps
