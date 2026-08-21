#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"
source "${BIN_DIR}/echo_env_vars.sh"
export $(echo_env_vars)

remove_old_images()
{
  echo; echo Removing old images
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_current "${dil}" "${CYBER_DOJO_NGINX_IMAGE}"
}

# Keeps :latest, which local tooling in dependent repos refers to, and this
# commit's tag, which names the build just made. Every older tag goes, and an
# earlier build whose last tag was one of those goes with it.
remove_all_but_current()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  # grep exits non-zero when the machine holds no nginx image, eg one whose
  # images have just been cleared, so an empty list must not end the build.
  local tagged_name
  for tagged_name in $(echo "${docker_image_ls}" | grep "^${name}:" || true)
  do
    if [ "${tagged_name}" != "${name}:latest" ] \
    && [ "${tagged_name}" != "$(tagged_image_name)" ]; then
      docker image rm --force "${tagged_name}" || echo "  skipped ${tagged_name} (in use)"
    fi
  done
}

build_tagged_image()
{
  echo; echo Building tagged image
  docker build \
    --platform linux/amd64 \
    --no-cache \
    --build-arg COMMIT_SHA="${CYBER_DOJO_NGINX_SHA}" \
    --tag "$(tagged_image_name)" \
    "$(repo_root)"
}

tagged_image_name()
{
  echo "${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}"
}

tag_image_to_latest()
{
  echo; echo Tagging image to :latest
  docker tag "$(tagged_image_name)" "${CYBER_DOJO_NGINX_IMAGE}:latest"
}

check_embedded_SHA_env_var()
{
  echo; echo Checking SHA env-var embedded inside image matches git commit sha
  local -r expected="$(git_commit_sha)"
  local -r actual="$(sha_inside_image)"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: unexpected env-var inside image $(tagged_image_name)"
    echo "expected: 'SHA=${expected}'"
    echo "  actual: 'SHA=${actual}'"
    exit 42
  fi
}

show_SHA_env_var()
{
  echo
  echo "  echo CYBER_DOJO_NGINX_SHA=${CYBER_DOJO_NGINX_SHA}"
  echo "  echo CYBER_DOJO_NGINX_TAG=${CYBER_DOJO_NGINX_TAG}"
  echo
}

sha_inside_image()
{
  docker run --rm "$(tagged_image_name)" sh -c 'echo ${SHA}'
}

build_tagged_image
tag_image_to_latest
# After tagging, so removing an earlier build's tags takes its last tag with
# them and the image itself goes, rather than being left dangling when :latest
# moves to this build.
remove_old_images
check_embedded_SHA_env_var
show_SHA_env_var

