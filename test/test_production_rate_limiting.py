import requests

_NGINX_PORT = 8180
_BASE_URL = f"http://localhost:{_NGINX_PORT}"


def test_c7a2f102():
    """Production image: GET /creator/create.json burst=3 exhausts at 5th request."""
    codes = _statuses("GET", "/creator/create.json", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f106():
    """Production image: GET /creator/enter.json burst=3 exhausts at 5th request."""
    codes = _statuses("GET", "/creator/enter.json", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f103():
    """Production image: POST /kata/fork burst=3 exhausts at 5th request."""
    codes = _statuses("POST", "/kata/fork", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f107():
    """Production image: POST /group/fork burst=3 exhausts at 5th request."""
    codes = _statuses("POST", "/group/fork", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f108():
    """Production image: POST /kata/file_create burst=3 exhausts at 5th request."""
    codes = _statuses("POST", "/kata/file_create", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f109():
    """Production image: POST /kata/file_delete burst=3 exhausts at 5th request."""
    codes = _statuses("POST", "/kata/file_delete", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f10a():
    """Production image: POST /kata/file_rename burst=3 exhausts at 5th request."""
    codes = _statuses("POST", "/kata/file_rename", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f10b():
    """Production image: POST /kata/file_edit burst=3 exhausts at 5th request."""
    codes = _statuses("POST", "/kata/file_edit", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f10c():
    """Production image: POST /kata/option_set burst=4 exhausts at 6th request."""
    codes = _statuses("POST", "/kata/option_set", 6)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f104():
    """Production image: POST /kata/run_tests/{id} burst=2 exhausts at 4th request."""
    codes = _statuses("POST", "/kata/run_tests/a2f104", 4)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f10d():
    """Production image: GET /creator/choose_ltf burst=3 exhausts at 5th request."""
    codes = _statuses("GET", "/creator/choose_ltf", 5)
    assert codes[-1] == 429
    assert all(c != 429 for c in codes[:-1])


def test_c7a2f105():
    """Production image: /kata/run_tests rate limits per URI independently."""
    codes = _statuses("POST", "/kata/run_tests/b3e209", 4)
    assert codes[-1] == 429
    fresh = _statuses("POST", "/kata/run_tests/c4d518", 1)[0]
    assert fresh != 429


def _statuses(method, path, count):
    """Return list of HTTP status codes for `count` rapid requests."""
    fn = requests.get if method == "GET" else requests.post
    return [fn(f"{_BASE_URL}{path}", timeout=5).status_code for _ in range(count)]
