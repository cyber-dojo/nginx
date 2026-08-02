import requests

_NGINX_PORT = 8180
_BASE_URL = f"http://localhost:{_NGINX_PORT}"


def test_4d9b2e01():
    """/dashboard/... reaches the dashboard app with its prefix intact.

    nginx no longer rewrites the prefix away, so the app serves the path from
    its own /dashboard mount. A 404 here means either the rewrite came back or
    the app is serving only at /.
    """
    r = requests.get(f"{_BASE_URL}/dashboard/alive", timeout=2)
    assert r.status_code == 200, f"expected 200, got {r.status_code}"
    assert r.json() == {"alive?": True}, f"body={r.text!r}"
