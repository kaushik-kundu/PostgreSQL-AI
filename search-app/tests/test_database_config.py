# Copyright © 2025, 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

from __future__ import annotations

import unittest

from app.config import Settings, build_database_url


class DatabaseConfigTests(unittest.TestCase):
    def test_build_database_url_encodes_reserved_credential_characters(self) -> None:
        settings = Settings(
            db_host="10.10.1.106",
            db_port=5432,
            db_name="postgres",
            db_user="app@user",
            db_password="password@with:/?#%",
            db_sslmode="require",
        )

        self.assertEqual(
            build_database_url(settings),
            "postgresql://app%40user:password%40with%3A%2F%3F%23%25@10.10.1.106:5432/postgres?sslmode=require",
        )

    def test_build_database_url_preserves_explicit_database_url(self) -> None:
        database_url = "postgresql://provided:password@example.test:5432/provided"
        settings = Settings(database_url=database_url)

        self.assertEqual(build_database_url(settings), database_url)


if __name__ == "__main__":
    unittest.main()
