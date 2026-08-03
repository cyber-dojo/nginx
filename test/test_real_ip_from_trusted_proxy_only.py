import os
import subprocess

import requests

_NGINX_PORT = 8180
_BASE_URL = f"http://localhost:{_NGINX_PORT}"
_IMAGE = f"{os.environ['CYBER_DOJO_NGINX_IMAGE']}:{os.environ['CYBER_DOJO_NGINX_TAG']}"


def _statuses_with_spoofed_client(path, count):
    """GETs path count times, each claiming a different client address."""
    codes = []
    for n in range(count):
        headers = {"X-Forwarded-For": f"203.0.113.{n + 1}"}
        codes.append(
            requests.get(f"{_BASE_URL}{path}", headers=headers, timeout=2).status_code
        )
    return codes


def test_e83b1701():
    """X-Forwarded-For from an untrusted peer wins no new rate-limit bucket.

    The test client is outside CYBER_DOJO_TRUSTED_PROXY_CIDR, which is loopback
    under docker, so nginx must keep keying on the real peer address. Exhaust
    the zone first, then claim a different client address on each of three
    further requests: all three must still be refused. If the trusted range ever
    widened to include the caller, each would land in a fresh bucket and answer
    404 from the app instead - which is also how a client would evade every
    limit.

    This exhausts creator_create itself rather than relying on test order, and
    it sorts after test_production_rate_limiting.py, whose burst test for the
    same zone would otherwise see the budget already spent.
    """
    for _ in range(5):
        requests.get(f"{_BASE_URL}/creator/create.json", timeout=2)
    codes = _statuses_with_spoofed_client("/creator/create.json", 3)
    assert codes == [429, 429, 429], codes


def test_e83b1702():
    """The trusted-proxy range is rendered from the ports env file.

    The behavioural test above passes both when the range is right and when the
    directive is missing altogether, since nginx ignores X-Forwarded-For by
    default. This one fails if the directive is lost.
    """
    cmd = [
        "docker", "run", "--rm", "--entrypoint", "sh", _IMAGE, "-c",
        "/docker-entrypoint.d/template-port-env-subst.sh"
        "; grep set_real_ip_from /etc/nginx/conf.d/default.conf",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
    assert result.returncode == 0, result.stderr
    assert "set_real_ip_from 127.0.0.1/32;" in result.stdout, result.stdout
