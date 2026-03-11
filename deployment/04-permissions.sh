# --- ALMARD SERVER: 04-PERMISSIONS ---
# Purpose: Locks down /home directories for privacy and applies 
# the SGID bit to the dpool for seamless container sharing.
# -------------------------------------

#!/bin/bash

TARGET="/mnt/dpool"

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./04-permissions.sh)"
  exit 1
fi

echo "Step 1: Hardening System Permissions..."

# 1. Lockdown Home Directories
# 700 = User: rwx, Group: ---, Others: ---
# This ensures users cannot list or read files in other users' home folders.
USERS=("sysadmin" "streamuser" "torrentuser" "fileuser" "serveruser" "networkuser" "photouser")

for user in "${USERS[@]}"; do
    if [ -d "/home/$user" ]; then
        echo "Locking down /home/$user..."
        chown -R "$user:$user" "/home/$user"
        chmod 700 "/home/$user"
    fi
done

# 2. General System Hardening
# Restrict access to system logs and sensitive paths for service users
chmod 750 /var/log

echo "Step 2: Applying Storage Permissions on $TARGET..."

# --- Storage Group Definitions ---
STREAM_DIRS=("Anime" "Books" "Movies" "Music" "Podcasts" "TV" "Test")
TORRENT_DIRS=("Completed" "Staging" "Torrents")
PHOTO_DIRS=("ExternalPhotos" "Photos")

# Re-usable permission function
apply_perms() {
    local dirs=("${!1}")
    local ownership=$2
    local d_mode=$3
    local f_mode=$4

    for dir in "${dirs[@]}"; do
        if [ -d "$TARGET/$dir" ]; then
            echo "Processing: $dir -> $ownership ($d_mode)"
            chown -R "$ownership" "$TARGET/$dir"
            # Use 'find' to handle existing nested structures
            find "$TARGET/$dir" -type d -exec chmod "$d_mode" {} +
            find "$TARGET/$dir" -type f -exec chmod "$f_mode" {} +
        else
            echo "Skipping: $dir (Not found)"
        fi
    done
}

# --- Execution ---
# 2750: Group can read/traverse, but not write. SGID (2) ensures group inheritance.
apply_perms STREAM_DIRS[@] "fileuser:streamuser" 2750 640

# 2770: Group has full read/write for moving/deleting downloads.
apply_perms TORRENT_DIRS[@] "fileuser:torrentuser" 2770 660

# 2770: Full access for photouser.
apply_perms PHOTO_DIRS[@] "fileuser:photouser" 2770 660

echo "------------------------------------------------"
echo "System and Storage permissions established!"
echo "Next step: 05-service-config.sh (The Config Mover)"
echo "------------------------------------------------"