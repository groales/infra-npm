#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "No existe $ENV_FILE"
  echo "Crea el archivo con: cp .env.example .env"
  exit 1
fi

stop_stack() {
  local stack_dir="$1"
  echo "Parando $stack_dir"
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/$stack_dir/compose.yaml" down
}

stop_stack "heimdall"
stop_stack "tailscale"
stop_stack "arcane"
stop_stack "nginx-proxy-manager"

echo "Infra detenida correctamente."
