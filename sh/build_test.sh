#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly SH_DIR="$(repo_root)/sh"
source "${SH_DIR}/echo_env_vars.sh"
export $(echo_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - - -
remove_old_image_layers()
{
  echo; echo Removing old image layers
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_latest "${dil}" "${CYBER_DOJO_NGINX_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image in $(echo "${docker_image_ls}" | grep "${name}:")
  do
    if [ "${image}" != "${name}:latest" ]; then
      if [ "${image}" != "${name}:<none>" ]; then
        docker image rm "${image}"
      fi
    fi
  done
  docker system prune --force
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_tagged_image()
{
  echo; echo Building tagged image
  docker build \
    --no-cache \
    --build-arg COMMIT_SHA="${CYBER_DOJO_NGINX_SHA}" \
    --tag "${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}" \
    "$(repo_root)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_image_to_latest()
{
  echo; echo Tagging image to :latest
  docker tag "${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}" "${CYBER_DOJO_NGINX_IMAGE}:latest"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
check_embedded_SHA_env_var()
{
  echo; echo Checking SHA env-var embedded inside image matches git commit sha
  local -r expected="$(git_commit_sha)"
  local -r actual="$(sha_inside_image)"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: unexpected env-var inside image ${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}"
    echo "expected: 'SHA=${expected}'"
    echo "  actual: 'SHA=${actual}'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
show_SHA_env_var()
{
  echo
  echo "CYBER_DOJO_NGINX_SHA=${CYBER_DOJO_NGINX_SHA}"
  echo "CYBER_DOJO_NGINX_TAG=${CYBER_DOJO_NGINX_TAG}"
  echo
}

# - - - - - - - - - - - - - - - - - - - - - - - -
sha_inside_image()
{
  docker run --rm "${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}" sh -c 'echo ${SHA}'
}


# - - - - - - - - - - - - - - - - - - - - - - - -
remove_old_image_layers
build_tagged_image
tag_image_to_latest
check_embedded_SHA_env_var
show_SHA_env_var

