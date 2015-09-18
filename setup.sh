#!/usr/bin/env bash

set -e

# Get the parent directory of where this script is.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Change into that directory
pushd $DIR &>/dev/null

echo "==> Creating required infrastructure..."
envchain aws terraform apply &>/dev/null
POSTGRES_ADDR=$(terraform output postgresql)

echo "==> Starting Vault..."
vault server -dev &>vault.log &
sleep 1
VAULT_PID=$!
export VAULT_ADDR=http://127.0.0.1:8200
echo "==> Vault is running ($VAULT_PID)"

# Stop vault when we stop the script
trap "kill $VAULT_PID" SIGINT SIGTERM EXIT

# AWS
echo "==> Setting up AWS backend..."
vault mount aws &>/dev/null
envchain aws /bin/bash <<EOH
  vault write aws/config/root \
    access_key="\$AWS_ACCESS_KEY_ID" \
    secret_key="\$AWS_SECRET_ACCESS_KEY" \
    region=us-east-1 &>/dev/null
EOH
vault write aws/config/lease \
  lease="1h" \
  lease_max="12h" &>/dev/null
echo "==> Creating AWS policy for developers..."
vault write aws/roles/developer \
  policy="@$PWD/policies/aws/developer.json" &>/dev/null
echo "==> Creating AWS policy for assets..."
vault write aws/roles/assets \
  policy="@$PWD/policies/aws/assets.json" &>/dev/null

# PKI

# Postgresql
echo "==> Setting up Postgresql backend..."
vault mount postgresql &>/dev/null
vault write postgresql/config/connection \
  value="postgresql://vault:vaultpassword@$POSTGRES_ADDR:5432" &>/dev/null
vault write postgresql/config/lease \
  lease="1h" \
  lease_max="24h" &>/dev/null
vault write postgresql/roles/readonly \
  sql="
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";
  " &>/dev/null

# Transit
echo "==> Setting up Transit backend..."
vault mount transit &>/dev/null
vault write -f transit/keys/demo &>/dev/null


# All good!
echo "==> Ready!"

# Basically block so the server runs in the background
wait $VAULT_PID

echo "==> Cleaning up..."

popd
