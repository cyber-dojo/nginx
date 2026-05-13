#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"
readonly TEST_DIR="$(repo_root)/test"
readonly COMPOSE_FILE="${TEST_DIR}/docker-compose.yml"

source "${BIN_DIR}/echo_env_vars.sh"
export $(echo_env_vars)
export DOCKER_DEFAULT_PLATFORM=linux/amd64

docker build \
  --build-arg COMMIT_SHA="${CYBER_DOJO_NGINX_SHA}" \
  --tag "${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}" \
  "$(repo_root)"

docker compose --file "${COMPOSE_FILE}" down --remove-orphans

dump_logs_and_down() {
  docker compose --file "${COMPOSE_FILE}" logs --no-color
  docker compose --file "${COMPOSE_FILE}" down --remove-orphans
}
trap dump_logs_and_down EXIT

docker compose \
  --file "${COMPOSE_FILE}" \
  up \
  --detach \
  --no-build \
  --wait \
  --wait-timeout 60

python3 -m pip install --quiet --requirement "${TEST_DIR}/requirements.txt"
python3 -m pytest "${TEST_DIR}/" --verbose "$@"
