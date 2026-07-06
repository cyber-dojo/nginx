import requests

_NGINX_PORT = 8180
_BASE_URL = f"http://localhost:{_NGINX_PORT}"


def test_c7a2f101():
    """The production image starts and nginx 302-redirects / to the relative /creator/home."""
    r = requests.get(f"{_BASE_URL}/", timeout=2, allow_redirects=False)
    assert r.status_code == 302, f"expected 302, got {r.status_code}"
    assert r.headers["Location"] == "/creator/home", f"Location={r.headers['Location']!r}"
