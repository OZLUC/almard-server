# Establishes system wide user permissions
# Writes storage directory permissions

## --- System Permissions --

## --- Storage Permissions --
#!/bin/bash

# Target directory (The root of your dpool)
TARGET="/mnt/dpool"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./set_perms.sh)"
  exit
fi

echo "Starting permission reset on $TARGET..."

# --- 1. Define Groups ---

# Media & General (drwxr-s--- / 2750)
STREAM_DIRS=("Anime" "Books" "Movies" "Music" "Podcasts" "TV" "Test")

# Downloads & Ingest (drwxrws--- / 2770)
TORRENT_DIRS=("Completed" "Staging" "Torrents")

# Photography (drwxrws--- / 2770)
PHOTO_DIRS=("ExternalPhotos" "Photos")

# --- 2. Apply Permissions ---

# Function to apply permissions
# Usage: apply_perms [array of dirs] [owner:group] [dir_mode] [file_mode]
apply_perms() {
    local dirs=("${!1}")
    local ownership=$2
    local d_mode=$3
    local f_mode=$4

    for dir in "${dirs[@]}"; do
        if [ -d "$TARGET/$dir" ]; then
            echo "Processing: $dir -> $ownership ($d_mode)"
            chown -R "$ownership" "$TARGET/$dir"
            find "$TARGET/$dir" -type d -exec chmod "$d_mode" {} +
            find "$TARGET/$dir" -type f -exec chmod "$f_mode" {} +
        else
            echo "Skipping: $dir (Directory not found)"
        fi
    done
}

# Execute for Stream Group
apply_perms STREAM_DIRS[@] "fileuser:streamuser" 2750 640

# Execute for Torrent Group
apply_perms TORRENT_DIRS[@] "fileuser:torrentuser" 2770 660

# Execute for Photo Group
apply_perms PHOTO_DIRS[@] "fileuser:photouser" 2770 660

echo "Permissions reset complete!"
root@almard:/home# 
