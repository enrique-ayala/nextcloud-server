#!/bin/bash
set -e

# This script automates the full setup of the Dockerized Nextcloud environment,
# including disk preparation, ZFS setup, and Nextcloud configuration.

# --- Configuration ---
# IMPORTANT: Before running, ensure this is the correct disk for your setup.
DISK="/dev/sdb"
POOL_NAME="data"
DATASET_NAME="nextcloud"
MOUNT_POINT="/mnt/nextcloud"

# --- ZFS Setup ---
echo "--- Preparing disk and setting up ZFS ---"

# Check if ZFS pool already exists
if ! zpool list -H -o name | grep -q "^${POOL_NAME}$"; then
    echo "ZFS pool '${POOL_NAME}' not found. Creating it..."

    # Install ZFS utilities if not present
    if ! command -v zpool &> /dev/null; then
        echo "Installing zfsutils-linux..."
        sudo apt-get update
        sudo apt-get install -y zfsutils-linux
    fi

    # Clean up LVM metadata if present (idempotent)
    sudo pvremove -ff -y "${DISK}" || true

    # Create a new GPT partition table and a single partition
    sudo parted "${DISK}" mklabel gpt
    sudo parted -a optimal "${DISK}" mkpart primary 0% 100%

    # Find the stable disk ID
    DISK_ID_PATH=$(find /dev/disk/by-id -lname "*/${DISK##*/}" | head -n 1)
    if [ -z "$DISK_ID_PATH" ]; then
        echo "Error: Could not find stable disk ID for ${DISK}"
        exit 1
    fi

    echo "Creating ZFS pool '${POOL_NAME}' on ${DISK_ID_PATH}..."
    sudo zpool create -f -o ashift=12 "${POOL_NAME}" "${DISK_ID_PATH}"
else
    echo "ZFS pool '${POOL_NAME}' already exists."
fi

# Check if ZFS dataset already exists
if ! zfs list -H -o name | grep -q "^${POOL_NAME}/${DATASET_NAME}$"; then
    echo "ZFS dataset '${POOL_NAME}/${DATASET_NAME}' not found. Creating it..."
    sudo zfs create "${POOL_NAME}/${DATASET_NAME}"
    sudo zfs set mountpoint="${MOUNT_POINT}" "${POOL_NAME}/${DATASET_NAME}"
else
    echo "ZFS dataset '${POOL_NAME}/${DATASET_NAME}' already exists."
fi

# --- Nextcloud Setup ---
echo "--- Starting Nextcloud containers ---"
if [ ! -f ".env" ]; then
    echo "Error: .env file not found. Please create it before running this script."
    exit 1
fi
docker compose up -d

# --- Post-installation Setup ---
echo "--- Performing post-installation setup ---"
echo "Waiting for Nextcloud to initialize (this may take a couple of minutes)..."
# A more robust check would be to loop until the container is healthy.
# For simplicity in this script, we use a sleep command.
sleep 120

echo "Setting background job mode to 'cron'..."
# This command might fail if run immediately after the first setup, which is fine.
docker exec --user www-data nextcloud_docker-app-1 php occ background:cron || echo "Cron mode already set or failed to set. This is often okay on subsequent runs."

echo ""
echo "--- Setup complete! ---"
echo "Nextcloud should be available at http://<your-server-ip>:8080"

