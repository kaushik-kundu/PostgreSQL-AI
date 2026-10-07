# Copyright © 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

output "network_compartment_ocid" {
  value = var.compartment_ocid
}

output "vcn_ocid" {
  value       = oci_core_vcn.workshop.id
  description = "VCN to select when separately creating the Bastion."
}

output "psql_subnet_ocid" {
  value       = oci_core_subnet.private.id
  description = "Copy into the attendee PostgreSQL stack's psql_subnet_ocid. Also use as the Bastion target subnet."
}

output "psql_nsg_ocids" {
  value       = [oci_core_network_security_group.postgres.id]
  description = "Copy into the attendee PostgreSQL stack's psql_nsg_ocids."
}

output "private_subnet_cidr" {
  value = oci_core_subnet.private.cidr_block
}

output "oci_service_cidr" {
  value = data.oci_core_services.all_oci_services.services[0].cidr_block
}

output "private_route_table_ocid" {
  value = oci_core_route_table.private.id
}

output "private_security_list_ocid" {
  value = oci_core_security_list.private.id
}
