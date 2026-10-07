# Copyright © 2025, 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

variable "region" {
  type    = string
  default = "us-chicago-1"
}

variable "compartment_ocid" {
  type        = string
  description = "Attendee compartment OCID for the PostgreSQL DB System and configuration; shared networking can be in another compartment."
}

variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID (used for AD discovery). If empty, compartment_ocid is used."
  default     = ""
}

## Network

variable "psql_subnet_ocid" {
  type        = string
  description = "OCID of the existing IPv4-only private subnet provided by LiveLabs. It may be in a different compartment from the DB System."
  validation {
    condition     = startswith(var.psql_subnet_ocid, "ocid1.subnet.") && var.psql_subnet_ocid == trimspace(var.psql_subnet_ocid)
    error_message = "Provide the existing private subnet OCID, without surrounding whitespace."
  }
}

variable "psql_nsg_ocids" {
  type        = list(string)
  description = "Existing PostgreSQL NSG OCIDs provided by LiveLabs, in the same VCN as the subnet. Leave empty only when LiveLabs supplies the required rules through subnet security lists."
  default     = []
  validation {
    condition     = alltrue([for id in var.psql_nsg_ocids : startswith(id, "ocid1.networksecuritygroup.") && id == trimspace(id)])
    error_message = "Each NSG value must be a network security group OCID without surrounding whitespace."
  }
}

## Credentials

variable "psql_admin_password" {
  type        = string
  description = "Optional admin password. Leave empty to auto-generate a strong random password."
  default     = ""
  sensitive   = true
}

## PostgreSQL

variable "psql_admin" {
  type        = string
  description = "Name of PostgreSQL admin username"
}

variable "psql_version" {
  type    = number
  default = 16
}

variable "inst_count" {
  type    = number
  default = 1
}

variable "num_ocpu" {
  type    = number
  default = 2
}

variable "psql_shape_name" {
  type        = string
  description = "PostgreSQL shape family name"
  default     = "PostgreSQL.VM.Standard.E5.Flex"
}

variable "psql_iops" {
  type = map(number)
  default = {
    75  = 75000
    150 = 150000
    225 = 225000
    300 = 300000
  }
}

# variable "psql_passwd_type" { default = "PLAIN_TEXT" }

## OCI PostgreSQL Configuration (optional)

variable "create_psql_configuration" {
  type        = bool
  description = "Whether to create an OCI PostgreSQL configuration in this stack"
  default     = true
}

variable "psql_configuration_ocid" {
  type        = string
  description = "Existing OCI PostgreSQL configuration OCID to use (if provided, skips creation)"
  default     = ""
}

variable "psql_config_display_name" {
  type        = string
  description = "Display name for the OCI PostgreSQL configuration (when created)"
  default     = "livelab_flexible_configuration"
}

variable "psql_config_is_flexible" {
  type        = bool
  description = "Whether the configuration is flexible"
  default     = true
}

variable "psql_config_compatible_shapes" {
  type        = list(string)
  description = "List of compatible shapes for the configuration"
  default = [
    "VM.Standard.E5.Flex",
    "VM.Standard.E6.Flex",
    "VM.Standard3.Flex"
  ]
}

variable "psql_config_description" {
  type        = string
  description = "Description for the PostgreSQL configuration"
  default     = "test configuration created by terraform"
}

# Map of config_key => overridden_config_value
# Example:
# {
#   "oci.admin_enabled_extensions" = "pg_stat_statements,pglogical,vector"
#   "pglogical.conflict_log_level" = "debug1"
#   "pg_stat_statements.max"       = "5000"
# }
variable "psql_config_overrides" {
  type        = map(string)
  description = "Configuration overrides as key/value pairs"
  default = {
    "oci.admin_enabled_extensions" = "pg_stat_statements,pglogical,vector"
    "pglogical.conflict_log_level" = "debug1"
    "pg_stat_statements.max"       = "5000"
  }
}
