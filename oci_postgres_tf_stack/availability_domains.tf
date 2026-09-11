# # Copyright © 2025, 2026 Oracle and/or its affiliates.
# #
# # This software is under the Apache License 2.0
# # (LICENSE-APACHE or http://www.apache.org/licenses/LICENSE-2.0) or Universal Permissive License
# # (UPL) 1.0 (LICENSE-UPL or https://oss.oracle.com/licenses/upl), at your option.

# Dynamically discover available Availability Domains for the target region/tenancy.
# This avoids hard-coding AD-1/2/3 which can fail in single-AD regions or regions with different AD counts.
data "oci_identity_availability_domains" "ads" {
  compartment_id = coalesce(var.tenancy_ocid, var.compartment_ocid)
}
