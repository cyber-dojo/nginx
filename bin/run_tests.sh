#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"
readonly TEST_DIR="$(repo_root)/test"
readonly COMPOSE_FILE="${TEST_DIR}/docker-compose.yml"

source "${BIN_DIR}/echo_env_vars.sh"
export $(echo_env_vars)

docker build \
  --build-arg COMMIT_SHA="${CYBER_DOJO_NGINX_SHA}" \
  --tag "${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}" \
  "$(repo_root)"

docker compose --file "${COMPOSE_FILE}" down --remove-orphans

trap "docker compose --file '${COMPOSE_FILE}' down --remove-orphans" EXIT

docker compose \
  --file "${COMPOSE_FILE}" \
  up \
  --detach \
  --no-build \
  --wait \
  --wait-timeout 60

python3 -m pip install -q -r "${TEST_DIR}/requirements.txt"
python3 -m pytest "${TEST_DIR}/" -v "$@"
