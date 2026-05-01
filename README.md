# Nginx Infra (Docker Compose)

Production-oriented Nginx reverse proxy that:
- runs in a container,
- accepts public traffic on port 80/443,
- routes requests by subdomain to different Docker containers/ports,
- uses editable local volumes for config/logs,
- supports quick config validation/reload,
- limits container resources,
- is configured through `.env`.

## 1) Clone and start on Ubuntu

```bash
git clone <your-repo-url>
cd nginx-infra
docker compose up -d
```

Default behavior after startup:
- Nginx listens on host ports `${HTTP_PORT}`/`${HTTPS_PORT}` from `.env`.
- Requests are routed by `Host` header using `nginx/upstreams/hosts.map`.
- A demo upstream container (`app`, using `traefik/whoami`) is included so it works instantly.

## 2) Configure your domain

1. Point DNS `A`/`AAAA` record(s) for your domain to the Ubuntu server public IP.
2. Set `SERVER_NAME` in `.env` (example: `shop.example.com www.shop.example.com`).
3. Restart stack:

```bash
docker compose up -d
```

## 3) Route different subdomains to different containers

Edit `nginx/upstreams/hosts.map`:

```nginx
api.example.com api-service:3000;
admin.example.com admin-service:8080;
shop.example.com shop-service:80;
```

Important:
- Left side is the incoming subdomain (`Host` header).
- Right side is the target upstream in `host:port` format.
- Upstream host should be a Docker service/container name reachable on the `backend` network.
- If your app is in another compose project, connect it to `${COMPOSE_PROJECT_NAME}-backend` network.

## 4) Editable config volumes

- Nginx template: `nginx/templates/default.conf.template`
- Host map: `nginx/upstreams/hosts.map`
- Certs mount: `nginx/certs/`
- Logs: `nginx/logs/`
- Cache: `nginx/cache/`

## 5) Validate and reload config (no container restart)

```bash
bash scripts/test-nginx.sh
bash scripts/reload-nginx.sh
```

Equivalent manual commands:

```bash
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
```

## 6) Using another env file (optional)

```bash
docker compose --env-file .env.production up -d
```

## 7) HTTPS notes

This setup exposes 443 and mounts `nginx/certs`, but TLS server blocks/cert config are not enabled by default.
Add your certificate config to `nginx/templates/default.conf.template` when ready.
