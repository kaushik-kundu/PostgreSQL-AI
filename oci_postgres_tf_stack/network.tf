# Copyright © 2025, 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_vcn" "vcn1" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr[0]]
  display_name   = "vcn1"
  dns_label      = "vcn1"
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "vcn1_sgway" {
  compartment_id = var.compartment_ocid
  display_name   = "SRVC_GTWY"
  vcn_id         = oci_core_vcn.vcn1.id
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

resource "oci_core_route_table" "VCN1_RT" {
  compartment_id = var.compartment_ocid
  display_name   = "VCN1-RT"
  vcn_id         = oci_core_vcn.vcn1.id
  route_rules {
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.vcn1_sgway.id
    description       = "OCI services only; no internet or NAT route"
  }
}

resource "oci_core_security_list" "VCN1_PRIVATE_SL" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "VCN1-PRIVATE-SL"

  egress_security_rules {
    destination      = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Bastion's private endpoint must be able to initiate a connection to PostgreSQL.
  egress_security_rules {
    destination      = cidrsubnet(var.vcn_cidr[0], 8, 1)
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
    tcp_options {
      min = 5432
      max = 5432
    }
  }

  # Bastion private endpoints use an address in the target subnet.
  ingress_security_rules {
    protocol    = "6"
    source      = cidrsubnet(var.vcn_cidr[0], 8, 1)
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      min = 5432
      max = 5432
    }
  }
}

resource "oci_core_subnet" "vcn1_psql_priv_subnet" {
  cidr_block                 = cidrsubnet(var.vcn_cidr[0], 8, 1)
  compartment_id             = var.compartment_ocid
  dhcp_options_id            = oci_core_vcn.vcn1.default_dhcp_options_id
  display_name               = "psql-priv-subnet"
  dns_label                  = "psqlprivsubnet"
  prohibit_internet_ingress  = true
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.VCN1_RT.id
  security_list_ids          = [oci_core_security_list.VCN1_PRIVATE_SL.id]
  vcn_id                     = oci_core_vcn.vcn1.id
}

resource "oci_core_network_security_group" "vcn1_nsg" {
  compartment_id = var.compartment_ocid
  display_name   = "PSQLNSG"
  vcn_id         = oci_core_vcn.vcn1.id
}

resource "oci_core_network_security_group_security_rule" "vcn1_nsg_rule_0" {
  network_security_group_id = oci_core_network_security_group.vcn1_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  description               = "PostgreSQL from Bastion target subnet"
  source                    = oci_core_subnet.vcn1_psql_priv_subnet.cidr_block
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  tcp_options {
    destination_port_range {
      min = 5432
      max = 5432
    }
  }
}

resource "oci_core_network_security_group_security_rule" "vcn1_nsg_rule_1" {
  network_security_group_id = oci_core_network_security_group.vcn1_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  description               = "PostgreSQL backups to OCI services"
  destination_type          = "SERVICE_CIDR_BLOCK"
  destination               = data.oci_core_services.all_oci_services.services[0].cidr_block
  stateless                 = false
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_bastion_bastion" "postgres" {
  bastion_type                 = "standard"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = oci_core_subnet.vcn1_psql_priv_subnet.id
  name                         = "postgres-workshop-bastion"
  client_cidr_block_allow_list = var.bastion_client_cidrs
  max_session_ttl_in_seconds   = 10800
}
