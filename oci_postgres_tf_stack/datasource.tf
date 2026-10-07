# Copyright © 2025, 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Random password generation and local selection logic
# If psql_admin_password is provided, it will be used.
# Otherwise, a strong random password will be generated at apply time.

resource "random_password" "psql_admin_password" {
  length           = 16
  upper            = true
  lower            = true
  numeric          = true
  special          = true
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 1
  override_special = "!@#$%^&*()-_=+[]{}<>?"
}

locals {
  psql_admin_password = var.psql_admin_password != "" ? var.psql_admin_password : random_password.psql_admin_password.result
}
