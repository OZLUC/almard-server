# --- ALMARD SERVER: 01-DEPENDENCIES ---
# Purpose: Installs OS-level requirements (Docker, MergerFS, SnapRAID) 
# Includes: Storage, Docker, GPU Transcoding, and Smart Home tools.
# --------------------------------------

#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./01-dependencies.sh)"
  exit 1
fi

echo "Updating system package lists..."
apt update && apt upgrade -y

echo "Installing QoL utilities and build essentials..."
apt install -y \
    curl \
    vim \
    git \
    tree \
    wget \
    gnupg \
    software-properties-common \
    git-crypt \
    build-essential

echo "Installing Storage Stack: MergerFS & SnapRAID..."
apt install -y mergerfs snapraid smartmontools # data pool, redundancy & drive health

echo "Installing Smart Home & Hardware Comm Utilities..."
apt install -y bluez dbus # Required for Home Assistant / Bluetooth

# --- GPU SUPPORT (for hardware acceleration) ---
# INTEL:
apt install -y intel-media-va-driver-non-free vainfo 

# NVIDIA:
# apt install -y nvidia-container-toolkit

# --- DOCKER INSTALLATION (Official Repo Method) ---
echo "Installing Docker Engine and Docker Compose..."

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-v2

echo "Enabling Docker service..."
systemctl enable --now docker

echo "------------------------------------------------"
echo "Dependencies installed successfully!"
echo "Next step: Run 02-users.sh to establish the service users."
echo "------------------------------------------------"