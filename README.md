# Home Server Deployment

This repository contains the `master.yaml` Docker Compose configuration for my home server stack. It integrates networking, security, media, and automation into a single deployable unit.

## Overview

The stack is organized into the following categories:

*   **Networking & Proxy:**
    *   **Traefik:** Reverse proxy handling SSL certificates (Let's Encrypt) and routing.
    *   **Cloudflared:** Secure tunnel to expose services without opening ports.
*   **Authentication:**
    *   **Authentik:** SSO provider protecting sensitive services (Traefik, Filebrowser, etc.).
*   **Media & Streaming:**
    *   **Jellyfin:** Video streaming.
    *   **Navidrome:** Music streaming.
    *   **Audiobookshelf & Kavita:** Books and audiobooks.
*   **Downloads (VPN-Gated):**
    *   **Gluetun:** VPN client (NordVPN/Wireguard) acting as a gateway.
    *   **qBittorrent & Sonarr:** Routed through Gluetun for privacy.
*   **Photos:**
    *   **Immich:** Self-hosted photo and video backup solution.
*   **Smart Home:**
    *   **Home Assistant & ESPHome:** Home automation control.
*   **Management:**
    *   **Homepage:** Dashboard for all services.
    *   **Filebrowser:** Web-based file manager.

## Prerequisites

*   Docker & Docker Compose
*   A valid domain name managed by Cloudflare.
*   A `.env` file in the same directory containing the required environment variables.

## Configuration

Create a `.env` file with the following keys (adjust paths and IDs as necessary):

```bash
# General
DOMAIN=example.com
EMAIL=your@email.com
TZ=America/New_York
VER=latest

# User IDs (PUID/PGID)
SERVERU_ID=1000
FILEU_ID=1000
STREAMU_ID=1000
TORRENTU_ID=1000
PHOTOU_ID=1000

# Directories
NWU_HOME_DIR=/path/to/network/config
SERVERU_HOME_DIR=/path/to/server/config
FILEU_HOME_DIR=/path/to/file/config
STREAMU_DIR=/path/to/stream/config
TORRENTU_HOME_DIR=/path/to/torrent/config
STORAGE_DIR=/path/to/media/storage

# Secrets & Tokens
CF_SECURE_TOKEN=your_cloudflared_token
CF_DNS_TOKEN=your_cloudflare_dns_api_token
PG_PASS=postgres_password
AUTHENTIK_SECRET_KEY=authentik_secret
WIREGUARD_PRIVATE_KEY=vpn_private_key
GLUETUN_API=gluetun_api_key
VPN_COUNTRY=selected_country_for_vpn

# Immich Specific
UPLOAD_LOCATION=/path/to/photos
DB_PASSWORD=immich_db_pass
DB_USERNAME=immich_db_user
DB_DATABASE_NAME=immich
