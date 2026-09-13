#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "No existe $ENV_FILE"
  echo "Crea el archivo con: cp .env.example .env"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [[ -z "${PROJECTS_DIRECTORY:-}" ]]; then
  echo "PROJECTS_DIRECTORY no esta definido en $ENV_FILE"
  exit 1
fi

mkdir -p \
  "$ROOT_DIR/nginx-proxy-manager/data" \
  "$ROOT_DIR/nginx-proxy-manager/letsencrypt" \
  "$ROOT_DIR/arcane/data" \
  "$ROOT_DIR/tailscale/state" \
  "$ROOT_DIR/heimdall/config"

if ! docker network inspect proxy >/dev/null 2>&1; then
  echo "Creando red externa proxy..."
  docker network create proxy >/dev/null
fi

run_stack() {
  local stack_dir="$1"
  echo "Validando $stack_dir/compose.yaml"
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/$stack_dir/compose.yaml" config >/dev/null
  echo "Levantando $stack_dir"
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/$stack_dir/compose.yaml" up -d
}

run_stack "nginx-proxy-manager"
run_stack "arcane"
run_stack "tailscale"
run_stack "heimdall"

echo "Infra arrancada correctamente."
