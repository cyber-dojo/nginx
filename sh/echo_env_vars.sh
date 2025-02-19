
echo_env_vars()
{
  docker run --rm cyberdojo/versioner 2> /dev/null
  echo CYBER_DOJO_NGINX_SHA="$(git_commit_sha)"
  echo CYBER_DOJO_NGINX_TAG="$(git_commit_tag)"
}

git_commit_sha()
{
  echo "$(cd "$(repo_root)" && git rev-parse HEAD)"
}

git_commit_tag()
{
  local -r sha="$(git_commit_sha)"
  echo "${sha:0:7}"
}
