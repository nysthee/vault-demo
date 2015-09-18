#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200
OUT=$(vault read -format=json postgresql/creds/readonly)

PG_HOST=$(terraform output postgresql)
PG_USER=$(echo $OUT | jq -r .data.username)
PG_PASS=$(echo $OUT | jq -r .data.password)

echo $PG_HOST
echo $PG_USER
echo $PG_PASS

export PGPASSWORD=$PG_PASS
psql \
  --host="$PG_HOST" \
  --username=$PG_USER \
  --no-password \
  --dbname=vault
