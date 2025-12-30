# Dockerized Nextcloud

This repository contains a `docker-compose.yml` file and setup script for running a Nextcloud instance with a PostgreSQL database and a ZFS-backed data store.

## Prerequisites

-   `docker` and `docker-compose` must be installed.
-   The script assumes the target disk for ZFS is `/dev/sdb`. **Warning:** This disk will be wiped. Edit `setup.sh` if you need to use a different disk.

## Setup

1.  **Create `.env` file:**

    Create a `.env` file in this directory by copying the example below. This file will contain your secrets.

    ```
    # .env file
    POSTGRES_DB=nextcloud
    POSTGRES_USER=nextcloud
    POSTGRES_PASSWORD=<your_postgres_password> # Generate a secure password
    NEXTCLOUD_ADMIN_USER=<your_admin_username>
    NEXTCLOUD_ADMIN_PASSWORD=<your_admin_password>
    ```

2.  **Run the setup script:**

    Execute the setup script to prepare the disk, set up ZFS, and launch the Nextcloud containers.

    ```sh
    sudo ./setup.sh
    ```

    The script is idempotent and can be run multiple times.

## Access

Once the setup is complete, Nextcloud will be accessible at `http://<your-server-ip>:8080`.
