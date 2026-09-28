#!/usr/bin/env bash
# Deploys the Caddy gateway on the VPS. Run from CI over SSH, or by hand:
#   ssh root@<vps> bash /opt/caddy/deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

# Project repos drop their Caddyfile snippets here
mkdir -p sites
# Shared network that project containers join; ignore "already exists"
docker network create caddy_net 2>/dev/null || true
docker compose pull
docker compose up -d

# Reload Caddy to apply the new configuration.
# Retry: if `up -d` just recreated the container, the admin API (:2019)
# needs a moment before it accepts connections.
for i in $(seq 1 15); do
  if docker exec caddy-gateway caddy reload --config /etc/caddy/Caddyfile; then
    exit 0
  fi
  echo "Caddy admin API not ready (attempt $i/15), retrying in 2s..."
  sleep 2
done

docker logs --tail 50 caddy-gateway
exit 1
