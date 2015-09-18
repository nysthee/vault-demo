#!/bin/bash
set -e

echo "Waiting for cloud-init..."
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done

echo "Installing dependencies..."
sudo apt-get update -y &>/dev/null
sudo apt-get install -y postgresql &>/dev/null

echo "Configuring Postgres..."
sudo -u postgres createuser vault \
  --createrole
sudo -u postgres psql -c "ALTER USER vault WITH PASSWORD 'vaultpassword'"
sudo -u postgres createdb vault \
  --owner=vault

sudo sed -i "/listen_addresses = 'localhost'/c\listen_addresses = '*'" /etc/postgresql/9.4/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/9.4/main/pg_hba.conf
sudo service postgresql restart
