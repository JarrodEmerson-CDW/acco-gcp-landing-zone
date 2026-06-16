# This file is used to declare variables defined in the global terraform.tfvars
# but not used in this layer, silencing "Value for undeclared variable" warnings.

variable "top_level_folders" {
  type    = any
  default = null
}

variable "shared_subfolders" {
  type    = any
  default = null
}

variable "business_units" {
  type    = any
  default = null
}

variable "boolean_org_policies" {
  type    = any
  default = null
}

variable "list_org_policies" {
  type    = any
  default = null
}

variable "folder_policy_overrides" {
  type    = any
  default = null
}

variable "hub_project_id" {
  type    = any
  default = null
}

variable "hub_network_name" {
  type    = any
  default = null
}

variable "hub_subnets" {
  type    = any
  default = null
}

variable "hub_nat_config" {
  type    = any
  default = null
}

variable "hub_firewall_rules" {
  type    = any
  default = null
}

variable "spoke_vpcs" {
  type    = any
  default = null
}

variable "dns_project_id" {
  type    = any
  default = null
}

variable "private_dns_zones" {
  type    = any
  default = null
}

variable "peering_dns_zones" {
  type    = any
  default = null
}

variable "forwarding_dns_zones" {
  type    = any
  default = null
}

variable "iam_bindings" {
  type    = any
  default = null
}

variable "service_accounts" {
  type    = any
  default = null
}

variable "log_sinks" {
  type    = any
  default = null
}

variable "budgets" {
  type    = any
  default = null
}
