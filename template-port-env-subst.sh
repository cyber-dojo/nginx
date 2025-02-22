#!/bin/bash -e

# This script is automatically run by the nginx server when it starts.
# See docker-entrypoint.sh in the root of an nginx container.
# In k8s microservices can use the same port. In Docker they can't.

readonly nginx_docker_dir=/docker-entrypoint.d

ports_filename()
{
  if [[ -z "${CYBER_DOJO_K8S_PORT}" ]] && [[ -z "${DEPLOY_TO_ECS}" ]]; then
    echo docker > /tmp/port.mode
    echo "${nginx_docker_dir}/ports.docker.env"
  elif [[ "${DEPLOY_TO_ECS}" = true ]]; then
    echo ecs > /tmp/port.mode
    echo "${nginx_docker_dir}/ports.ecs.env"
  else
    echo k8s > /tmp/port.mode
    echo "${nginx_docker_dir}/ports.k8s.env"
  fi
}

readonly template_path="${nginx_docker_dir}/nginx.conf.template"
readonly defined_envs="$(printf '${SHA}'; printf '${%s}' $(cat "$(ports_filename)" | cut -d= -f1))"
export $(cat "$(ports_filename)")
export SHA="${SHA}"
envsubst "${defined_envs}" < "${template_path}" > "/etc/nginx/conf.d/default.conf"
