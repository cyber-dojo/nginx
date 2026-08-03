import requests

_NGINX_PORT = 8180
_BASE_URL = f"http://localhost:{_NGINX_PORT}"


def test_7c41af01():
    """/creator/... reaches the creator app with its prefix intact.

    nginx no longer rewrites the prefix away in any of the creator locations,
    so the app serves the path from its own /creator mount. A 404 here means
    either a rewrite came back or the app is serving only at /.

    /creator/alive has its own location, outside the rate-limited ones, so
    this request spends no burst budget the rate-limiting tests depend on.
    """
    r = requests.get(f"{_BASE_URL}/creator/alive", timeout=2)
    assert r.status_code == 200, f"expected 200, got {r.status_code}"
    assert r.json() == {"alive?": True}, f"body={r.text!r}"
