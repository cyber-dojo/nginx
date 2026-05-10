import requests

_NGINX_PORT = 8180
_BASE_URL = f"http://localhost:{_NGINX_PORT}"


def test_c7a2f101():
    """The production image starts and nginx redirects / to /creator/home."""
    r = requests.get(f"{_BASE_URL}/", timeout=2, allow_redirects=False)
    assert r.status_code == 301
    assert r.headers["Location"].endswith("/creator/home")
