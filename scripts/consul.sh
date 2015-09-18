#!/bin/bash
set -e

echo "Waiting for cloud-init..."
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done

echo "Installing dependencies..."
sudo apt-get update -y &>/dev/null
sudo apt-get install -y unzip &>/dev/null

echo "Fetching Consul..."
cd /tmp
wget https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip -O consul.zip -q &>/dev/null

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/service

echo "Installing Upstart service..."
sudo mv /tmp/consul.conf /etc/init/consul.conf

echo "Starting Consul..."
sudo start consul
