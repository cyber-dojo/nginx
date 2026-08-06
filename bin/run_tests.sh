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

# The requirements go into a venv rather than the host interpreter, which
# refuses a system-wide install when it is externally managed (PEP 668) - the
# default for Homebrew and for recent distro pythons. Creating an existing
# venv again is a no-op, so this costs nothing on repeat runs.
readonly VENV_DIR="$(repo_root)/.venv"
python3 -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/pip" install --quiet --requirement "${TEST_DIR}/requirements.txt"
"${VENV_DIR}/bin/pytest" "${TEST_DIR}/" --verbose "$@"
