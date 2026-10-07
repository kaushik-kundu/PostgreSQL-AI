# Copyright © 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_vcn" "workshop" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "postgres-workshop-test-vcn"
  dns_label      = "pgworkshop"
  is_ipv6enabled = false
}

# Replace the VCN's automatic default rules with restricted rules.
# The private subnet attaches only the restricted security list below.
resource "oci_core_default_security_list" "restricted_default" {
  manage_default_resource_id = oci_core_vcn.workshop.default_security_list_id

  ingress_security_rules {
    protocol    = "6"
    source      = var.private_subnet_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false
    description = "PostgreSQL from the private subnet only"
    tcp_options {
      min = 5432
      max = 5432
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    stateless        = false
    description      = "HTTPS to supported regional OCI services only"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "oci_services" {
  compartment_id = var.compartment_ocid
  display_name   = "postgres-workshop-oci-services"
  vcn_id         = oci_core_vcn.workshop.id
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  display_name   = "postgres-workshop-private-routes"
  vcn_id         = oci_core_vcn.workshop.id
  # No default route, Internet Gateway, NAT Gateway, DRG, or peering.
  route_rules {
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oci_services.id
    description       = "Supported regional OCI services only"
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  display_name   = "postgres-workshop-private-security"
  vcn_id         = oci_core_vcn.workshop.id

  ingress_security_rules {
    protocol    = "6"
    source      = var.private_subnet_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false
    description = "PostgreSQL from Bastion private endpoint in this subnet"
    tcp_options {
      min = 5432
      max = 5432
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    stateless        = false
    description      = "HTTPS to supported regional OCI services"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = var.private_subnet_cidr
    destination_type = "CIDR_BLOCK"
    stateless        = false
    description      = "Bastion private endpoint to PostgreSQL in this subnet"
    tcp_options {
      min = 5432
      max = 5432
    }
  }
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.workshop.id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "postgres-workshop-private-subnet"
  dns_label                  = "pgprivate"
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  dhcp_options_id            = oci_core_vcn.workshop.default_dhcp_options_id
}

resource "oci_core_network_security_group" "postgres" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.workshop.id
  display_name   = "postgres-workshop-db-nsg"
}

resource "oci_core_network_security_group_security_rule" "postgres_ingress" {
  network_security_group_id = oci_core_network_security_group.postgres.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  description               = "PostgreSQL from Bastion private endpoint in this subnet"
  tcp_options {
    destination_port_range {
      min = 5432
      max = 5432
    }
  }
}

resource "oci_core_network_security_group_security_rule" "oci_services_egress" {
  network_security_group_id = oci_core_network_security_group.postgres.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = data.oci_core_services.all_oci_services.services[0].cidr_block
  destination_type          = "SERVICE_CIDR_BLOCK"
  stateless                 = false
  description               = "HTTPS to supported regional OCI services"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}
