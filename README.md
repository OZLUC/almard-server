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
 
    
Almard Server: Nuclear Redeploy

This repository contains the complete "Rebuild" state for the Almard Home Server. Following a OS reinstall this repository will rebuild the server from dependency to deployment. 

Procedure:
The recovery is split into six scripts. Each handles a specific layer of the stack, from hardware mounting to service deployment.

1. System Establishment (01-setup.sh)
    - Updates apt repositories.
    - Installs essential dependencies (mergerfs, snapraid, git, curl).
    - Installs the Docker Engine and Compose plugin.

2. User Management (02-users.sh)
    - Creates dedicated service users with nologin shells.
    - Establishes the sysadmin user with sudo privileges.
    - Creates /home directory structure.

3. Storage Reconstruction (03-storage.sh)
    - Verifies physical drive presence via UUIDs (D1, D2, P1).
    - Configures /etc/fstab for persistent mounts.
    - Deploys MergerFs to establish drive pool formation. 
    - Rebuilds the SnapRAID configuration file.

4. Permission Hardening (04-permissions.sh)
    - Applies the Principle of Least Privilege (700 on home dirs).
    - Implements SGID (Set Group ID) and Least Privilege on the dpool.

5. Logic Deployment (05-service-config.sh)
    - Maps the Essential Logic (YAMLs, Caddyfiles) from this repository to the respective /home directories.
    - Essential Files include:
        - Caddyfile, authelia/configuration.yml
        - homepage/services.yaml, home-assistant/configuration.yaml

6. Server Redeployment (06-deploy.sh)
    - Performs a final health check on the storage pool.
    - Bootstraps Portainer CE for GUI-based management.

Final Step: Manual deployment of the Master Compose Stack via Portainer.

📂 Repository Structure
Plaintext
.
├── scripts/
│   ├── 01-setup.sh
│   ├── ...
│   └── 06-deploy.sh
└── config/
    └── services/
        ├── authelia/
        ├── caddy/
        ├── home-assistant/
        └── homepage/

Security Note: Sensitive files (e.g., secrets.yaml, users_database.yml) are encrypted using git-crypt.
To unlock the repository after cloning:
<git-crypt unlock /path/to/your/key>

Post-Deployment Checklist
[ ] Log into Portainer (Port 9443) and deploy the Master Stack.
[ ] Run snapraid diff to verify parity status.
[ ] Update Home Assistant secrets.yaml with any new integration tokens.
[ ] Verify Caddy SSL certificate propagation for *.almard.dev.

How to use this for your Rebuild:
Reinstall Debian Linux (Minimal).
Clone this repo: git clone https://github.com/your-repo/almard-server.git.
Run the scripts in order: sudo ./scripts/01-setup.sh, etc.