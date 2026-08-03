import os
import subprocess

_IMAGE = f"{os.environ['CYBER_DOJO_NGINX_IMAGE']}:{os.environ['CYBER_DOJO_NGINX_TAG']}"

# Renders the template the way the container does at startup, then reads back
# the creator_choose zone. Run in a throwaway container so the compose stack,
# which the other tests depend on, is untouched.
_RENDER = (
    "/docker-entrypoint.d/template-port-env-subst.sh"
    "; grep 'zone=creator_choose' /etc/nginx/conf.d/default.conf"
)


def _rendered(env):
    cmd = ["docker", "run", "--rm"]
    for name, value in env.items():
        cmd += ["--env", f"{name}={value}"]
    cmd += ["--entrypoint", "sh", _IMAGE, "-c", _RENDER]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
    assert result.returncode == 0, result.stderr
    return result.stdout


def test_b52c9e01():
    """With nothing set, a rate comes from the ports env file baked into the image."""
    rendered = _rendered({})
    assert "rate=60r/m;" in rendered, rendered


def test_b52c9e02():
    """An environment variable wins over the ports env file.

    This is what lets a test run turn a limit up while exercising this same
    image and template. Without it the file's value would clobber the caller's.
    """
    rendered = _rendered({"CYBER_DOJO_CREATOR_CHOOSE_RATE": "6000r/m"})
    assert "rate=6000r/m;" in rendered, rendered
