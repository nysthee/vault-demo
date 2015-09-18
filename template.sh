#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(cat $HOME/.vault-token)

consul-template \
  -template="in.ctmpl" \
  -dry
