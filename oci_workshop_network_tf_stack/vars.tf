# Copyright © 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

variable "region" {
  type    = string
  default = "us-chicago-1"
}

variable "compartment_ocid" {
  type        = string
  description = "Test network compartment OCID; this can differ from the attendee database compartment. Requires network management permissions."
}

variable "config_file_profile" {
  type        = string
  description = "Local Terraform CLI OCI config profile, e.g. ospatraining006. Leave unset in Resource Manager to use its managed authentication."
  default     = null
}

variable "vcn_cidr" {
  type    = string
  default = "10.10.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vcn_cidr))
    error_message = "Provide an IPv4 VCN CIDR."
  }
}

variable "private_subnet_cidr" {
  type        = string
  description = "IPv4 private subnet CIDR within vcn_cidr. Used by PostgreSQL and the separate Bastion's private endpoint."
  default     = "10.10.1.0/24"
  validation {
    condition     = can(cidrnetmask(var.private_subnet_cidr))
    error_message = "Provide an IPv4 subnet CIDR within the VCN."
  }
}
