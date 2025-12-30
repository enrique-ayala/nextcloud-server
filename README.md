# Dockerized Nextcloud

This repository contains a `docker-compose.yml` file for running a Nextcloud instance with a PostgreSQL database.

## Setup

1.  **Create a `.env` file:**

    Create a `.env` file in this directory with the following content, replacing the placeholder values with your own secrets:

    ```
    POSTGRES_DB=nextcloud
    POSTGRES_USER=nextcloud
    POSTGRES_PASSWORD=<your_postgres_password>
    NEXTCLOUD_ADMIN_USER=<your_admin_username>
    NEXTCLOUD_ADMIN_PASSWORD=<your_admin_password>
    ```

2.  **Prepare Data and Config Directories:**

    This setup assumes you have two directories on the host machine for persistent data:
    -   `/mnt/nextcloud` for user data.
    -   A Docker volume named `config` for the Nextcloud configuration.

3.  **Run Nextcloud:**

    Start the Nextcloud stack using Docker Compose:

    ```sh
    docker compose up -d
    ```

    Nextcloud will be accessible at `http://<your-server-ip>:8080`.
