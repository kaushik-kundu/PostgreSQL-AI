# # Copyright © 2025, 2026 Oracle and/or its affiliates.
# #
# # This software is under the Apache License 2.0
# # (LICENSE-APACHE or http://www.apache.org/licenses/LICENSE-2.0) or Universal Permissive License
# # (UPL) 1.0 (LICENSE-UPL or https://oss.oracle.com/licenses/upl), at your option.

# OCI PostgreSQL Configuration (optional)

resource "oci_psql_configuration" "psql_flex_config" {
  count          = var.create_psql_configuration == true && var.psql_configuration_ocid == "" && length(var.psql_config_overrides) > 0 ? 1 : 0
  compartment_id = var.compartment_ocid

  dynamic "db_configuration_overrides" {
    for_each = length(var.psql_config_overrides) > 0 ? [1] : []
    content {
      dynamic "items" {
        for_each = var.psql_config_overrides
        content {
          config_key             = items.key
          overriden_config_value = items.value
        }
      }
    }
  }

  db_version         = tostring(var.psql_version)
  display_name       = var.psql_config_display_name
  is_flexible        = var.psql_config_is_flexible
  compatible_shapes  = var.psql_config_compatible_shapes
  description        = var.psql_config_description
}
