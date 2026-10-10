import requests

_NGINX_PORT = 8180
_BASE_URL = f"http://localhost:{_NGINX_PORT}"
_HIGH_RATE_NGINX_PORT = 8181


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


def test_7c41af02():
    """A creator redirect names the client's host, never creator's own.

    creator builds a redirect's Location from the Host header it sees.
    nginx forwards the client's Host, so the redirect from
    /creator/choose_ltf to /creator/setup stays on nginx.

    The request goes to the high-rate nginx, so it spends none of the
    /creator/ burst budget the rate-limiting tests count on.
    """
    base_url = f"http://localhost:{_HIGH_RATE_NGINX_PORT}"
    r = requests.get(f"{base_url}/creator/choose_ltf",
                     allow_redirects=False, timeout=2)
    assert r.status_code == 302, f"expected 302, got {r.status_code}"
    assert r.headers["Location"] == f"{base_url}/creator/setup?"
