#!/bin/bash

# --- ALMARD SERVER: 05-SERVICE-CONFIG (Minimalist Edition) ---
# Purpose: Deploys ONLY the essential logic files required for 
# a successful "Cold Start" of the Docker stack.
# -----------------------------------------------------------

REPO_ROOT="$HOME/almard-server/config/services"

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./05-service-config.sh)"
  exit 1
fi

echo "🚀 Deploying Essential Logic Files..."

# Function to deploy and set permissions
# Usage: deploy_config [service_name] [file_name] [target_user] [sub_dir]
deploy_config() {
    local service=$1
    local file=$2
    local user=$3
    local subdir=$4
    local target="/home/$user/$service/$subdir"

    mkdir -p "$target"
    
    if [ -f "$REPO_ROOT/$service/$file" ]; then
        echo "✅ Deploying $file to $service..."
        cp "$REPO_ROOT/$service/$file" "$target"
        chown -R "$user:$user" "/home/$user/$service"
        chmod 700 "/home/$user/$service"
    else
        echo "⚠️  Warning: $file not found in repo for $service"
    fi
}

# --- 1. Networking & Auth (networkuser) ---
deploy_config "caddy" "Caddyfile" "networkuser" ""
deploy_config "authelia" "configuration.yml" "networkuser" "config"
deploy_config "authelia" "users_database.yml" "networkuser" "config"

# --- 2. Dashboards (serveruser) ---
deploy_config "homepage" "services.yaml" "serveruser" "config"
deploy_config "homepage" "widgets.yaml" "serveruser" "config"
deploy_config "homepage" "settings.yaml" "serveruser" "config"
deploy_config "homepage" "docker.yaml" "serveruser" "config"

# --- 3. Automations (serveruser) ---
deploy_config "home-assistant" "configuration.yaml" "serveruser" ""
deploy_config "home-assistant" "secrets.yaml" "serveruser" ""
deploy_config "esphome" "*.yaml" "serveruser" "config"

# --- 4. Torrent Settings (torrentuser) ---
deploy_config "qbittorrent" "qBittorrent.conf" "torrentuser" "config"

echo "------------------------------------------------"
echo "Logic Deployment Complete!"
echo "Your server is now 'Configured' but 'Empty'."
echo "------------------------------------------------"