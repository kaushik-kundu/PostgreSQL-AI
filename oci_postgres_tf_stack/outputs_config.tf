# Copyright © 2025, 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

output "psql_configuration_id" {
  value = var.psql_configuration_ocid != "" ? var.psql_configuration_ocid : (length(oci_psql_configuration.psql_flex_config) > 0 ? oci_psql_configuration.psql_flex_config[0].id : null)
}
