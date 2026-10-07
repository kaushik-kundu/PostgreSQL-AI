# Copyright © 2025, 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

output "psql_admin_pwd" {
  value     = local.psql_admin_password
  sensitive = true
}

output "postgres_private_ip" {
  value = oci_psql_db_system.psql_inst_1.network_details[0].primary_db_endpoint_private_ip
}
