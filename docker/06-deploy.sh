# --- ALMARD SERVER: 06-DEPLOY ---
# Purpose: Bootstraps Portainer and performs a final system 
# readiness check before manual Master Compose deployment.
# ---------------------------------

#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./06-deploy.sh)"
  exit 1
fi

echo "🔍 Final System Readiness Check..."

# 1. Verify MergerFS Pool
if mountpoint -q /mnt/dpool; then
    echo "✅ /mnt/dpool is mounted and ready."
else
    echo "🚨 ERROR: /mnt/dpool is NOT mounted. Check 03-storage.sh."
    exit 1
fi

# 2. Verify Essential Configs exist (Sample check)
if [ -f "/home/networkuser/caddy/Caddyfile" ]; then
    echo "✅ Essential configs detected."
else
    echo "🚨 ERROR: Config files missing. Check 05-service-config.sh."
    exit 1
fi

# 3. Bootstrap Portainer
echo "⚓ Deploying Portainer Server..."

# We deploy Portainer as 'root' or 'sysadmin' since it needs docker.sock access
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/sysadmin/portainer_data:/data \
  portainer/portainer-ce:latest

echo "------------------------------------------------"
echo "🎉 ALMARD SERVER IS READY FOR DEPLOYMENT!"
echo "------------------------------------------------"
echo "1. Open your browser to: https://192.168.1.150:9443"
echo "2. Create your admin account."
echo "3. Go to 'Stacks' -> 'Add Stack'."
echo "4. Paste your Master Compose file from your Mac/GitHub."
echo "5. Click 'Deploy the stack'."
echo "------------------------------------------------"