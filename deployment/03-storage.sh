#!/bin/bash

# --- ALMARD SERVER: 03-STORAGE ---
# Purpose: Configures physical drive mounts, MergerFS pooling, 
# and SnapRAID parity based on documented UUIDs.
# ---------------------------------

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

# --- 1. Define drive UUIDs from your fstab ---
D1_UUID="c85aa558-fe6e-4404-9329-11a40a226232"
D2_UUID="d7a0e0bf-9fc8-420e-baeb-2bc0cd434895"
P1_UUID="9a520d22-1e8e-42bf-9abe-fbcceab7c45b"

echo "🔍 Verifying physical drive presence..."

# Function to check if UUID exists in the system
check_uuid() {
    if ! blkid -U "$1" > /dev/null; then
        echo "🚨 ERROR: Drive with UUID $1 not found! Check cables."
        exit 1
    fi
}

check_uuid "$D1_UUID"
check_uuid "$D2_UUID"
check_uuid "$P1_UUID"

echo "✅ All physical drives detected."

# --- 2. Create Mount Points ---
echo "Creating mount points..."
mkdir -p /mnt/d1 /mnt/d2 /mnt/p1 /mnt/dpool

# --- 3. Backup and Update /etc/fstab ---
if ! grep -q "mergerfs" /etc/fstab; then
    echo "Backing up fstab to /etc/fstab.bak..."
    cp /etc/fstab /etc/fstab.bak

    echo "Writing mount entries to /etc/fstab..."
    cat <<EOT >> /etc/fstab

# --- Almard Storage Stack ---
# Data Drives
UUID=$D1_UUID /mnt/d1 ext4 defaults 0 2
UUID=$D2_UUID /mnt/d2 ext4 defaults 0 2

# Parity Drive
UUID=$P1_UUID /mnt/p1 ext4 defaults 0 2

# MergerFS Pool
# category.create=mfs balances files based on Most Free Space
/mnt/d1:/mnt/d2 /mnt/dpool fuse.mergerfs rw,nonempty,allow_other,use_ino,cache.files=off,moveonenospc=true,category.create=mfs,dropcacheonclose=true,minfreespace=250G,fsname=mergerfs 0 0
EOT
else
    echo "ℹ️ fstab already contains storage entries. Skipping write."
fi

# --- 4. Mount Everything ---
echo "Mounting all drives..."
systemctl daemon-reload
mount -a

# --- 5. Reconstruct SnapRAID Config ---
echo "Configuring SnapRAID..."
cat <<EOT > /etc/snapraid.conf
# SnapRAID configuration for Almard Server
parity /mnt/p1/snapraid.parity
content /mnt/d1/.snapraid.content
content /mnt/d2/.snapraid.content
data d1 /mnt/d1
data d2 /mnt/d2
exclude /lost+found/
EOT

echo "------------------------------------------------"
echo "Storage Stack Reconstruction Complete!"
df -h | grep -E 'mnt|mergerfs'
echo "------------------------------------------------"
echo "Next step: Run 04-permissions.sh to secure the pool."