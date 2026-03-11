# --- ALMARD SERVER: 02-USERS ---
# Purpose: Establishes the User Matrix (UIDs 1000-1006) 
# and builds the service directory structure in /home.
# -------------------------------

#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

echo "Creating Almard User Identity Matrix..."

# Function to create service users with no shell access for security
# Usage: create_svc_user [name] [uid]
create_svc_user() {
    local name=$1
    local uid=$2
    if ! id "$name" &>/dev/null; then
        # -m: create home, -u: specific UID, -s: restricted shell
        useradd -m -u "$uid" -s /usr/sbin/nologin "$name"
        echo "✅ Created $name ($uid)"
    else
        echo "ℹ️ $name ($uid) already exists."
    fi
}

# 1. Create Sysadmin (With shell access and sudo)
if ! id "sysadmin" &>/dev/null; then
    useradd -m -u 1000 -s /bin/bash sysadmin
    usermod -aG sudo sysadmin
    echo "✅ Created sysadmin (1000) with sudo access."
fi

# 2. Create Service Users (Restricted shell)
create_svc_user "streamuser"  1001
create_svc_user "torrentuser" 1002
create_svc_user "fileuser"    1003
create_svc_user "serveruser"  1004
create_svc_user "networkuser" 1005
create_svc_user "photouser"   1006

# 3. Build Service Directory Structure
echo "Building directory tree and setting ownership..."

# Function to safely create dir and set owner
mk_service_dir() {
    local path=$1
    local owner=$2
    mkdir -p "$path"
    chown -R "$owner:$owner" "$path"
}

# --- streamuser (Media) ---
mk_service_dir "/home/streamuser/jellyfin/config" "streamuser"
mk_service_dir "/home/streamuser/jellyfin/cache"  "streamuser"
mk_service_dir "/home/streamuser/kavita/config"   "streamuser"
mk_service_dir "/home/streamuser/navidrome/data"  "streamuser"
mk_service_dir "/home/streamuser/audiobookshelf/config" "streamuser"

# --- torrentuser (Arrs & VPN) ---
mk_service_dir "/home/torrentuser/sonarr/config"      "torrentuser"
mk_service_dir "/home/torrentuser/qbittorrent/config" "torrentuser"
mk_service_dir "/home/torrentuser/jackett/config"     "torrentuser"
mk_service_dir "/home/torrentuser/slskd/config"       "torrentuser"

# --- networkuser (Proxy & Auth) ---
mk_service_dir "/home/networkuser/caddy/data"    "networkuser"
mk_service_dir "/home/networkuser/caddy/config"  "networkuser"
mk_service_dir "/home/networkuser/authelia/config" "networkuser"
mk_service_dir "/home/networkuser/gluetun"       "networkuser"

# --- fileuser ---
mk_service_dir "/home/fileuser/filebrowser/config" "fileuser"
mk_service_dir "/home/fileuser/filebrowser/database" "fileuser"

# --- photouser ---
mk_service_dir "/home/photouser/immich/postgres" "photouser"
mk_service_dir "/home/photouser/immich/redis"    "photouser"
mk_service_dir "/home/photouser/immich/model-cache" "photouser"

# --- serveruser (Management & HA) ---
mk_service_dir "/home/serveruser/homepage/config" "serveruser"
mk_service_dir "/home/serveruser/home-assistant"  "serveruser"
mk_service_dir "/home/serveruser/esphome/config"  "serveruser"

echo "------------------------------------------------"
echo "User Matrix and Directory Structure complete!"
echo "run <sudo passwd sysadmin> to set sysadmin password for ssh access"
echo "Next step: Run 03-storage.sh to mount your dpool."
echo "------------------------------------------------"