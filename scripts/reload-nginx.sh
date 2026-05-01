#!/usr/bin/env bash
set -euo pipefail

docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
echo "Nginx config reloaded successfully."