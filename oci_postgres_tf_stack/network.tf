# Copyright © 2025, 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# LiveLabs provisions and manages networking outside this attendee stack.
# The DB System uses psql_subnet_ocid and optional psql_nsg_ocids directly.
# Their compartment does not need to match the DB System's compartment.
# LiveLabs must configure OCI-service-only egress and PostgreSQL TCP 5432
# access from the separately managed Bastion private endpoint.
# Bastion creation and session creation are outside this Terraform stack.
