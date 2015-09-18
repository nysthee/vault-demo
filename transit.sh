#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

VALUE=$(echo -n "Testing" | base64)
OUT=$(vault write -format=json transit/encrypt/demo plaintext="$VALUE")

echo $OUT | jq -r .data.ciphertext
