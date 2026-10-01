import unittest

from app.config import _session_secret_key


class SessionSecretTests(unittest.TestCase):
    def test_missing_secret_is_random_for_each_app_start(self) -> None:
        first = _session_secret_key({})
        second = _session_secret_key({})
        self.assertGreaterEqual(len(first), 32)
        self.assertNotEqual(first, second)

    def test_explicit_secret_is_preserved(self) -> None:
        self.assertEqual(_session_secret_key({"SECRET_KEY": "my-shared-secret"}), "my-shared-secret")

    def test_sample_secret_is_replaced(self) -> None:
        self.assertNotEqual(
            _session_secret_key({"SECRET_KEY": "GENERATE_A_LONG_RANDOM_VALUE"}),
            "GENERATE_A_LONG_RANDOM_VALUE",
        )


if __name__ == "__main__":
    unittest.main()
