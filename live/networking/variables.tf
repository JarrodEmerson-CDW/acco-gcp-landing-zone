variable "billing_project" {
  description = "Project used for API quota."
  type        = string
}

# ─── Spoke VPC configurations (dev, non-prod, prod) ──────────────────────────
variable "spoke_vpcs" {
  description = <<-EOT
    Map of spoke VPC environments to create as Shared VPC host projects.
    Key = logical environment name (e.g. "dev", "non-prod", "prod").
    - host_project_id    : Shared VPC host project ID
    - network_name       : VPC network name
    - cidr_block         : /16 block earmarked for this env (documentation only; subnets slice from it)
    - subnets            : map of subnets (see shared-vpc module schema)
    - nat_config         : map of Cloud NAT config per region
    - firewall_rules     : map of firewall rules
    - service_project_ids: list of service project IDs to attach
  EOT
  type = map(object({
    host_project_id     = string
    network_name        = string
    cidr_block          = string
    service_project_ids = optional(list(string), [])
    subnets = map(object({
      ip_cidr_range         = string
      region                = string
      private_google_access = optional(bool, true)
      enable_flow_logs      = optional(bool, false)
      flow_log_interval     = optional(string, "INTERVAL_5_SEC")
      flow_log_sampling     = optional(number, 0.5)
      secondary_ranges      = optional(list(object({ range_name = string, ip_cidr_range = string })), [])
      description           = optional(string, "")
    }))
    nat_config = optional(map(object({
      nat_ip_allocate_option              = optional(string, "AUTO_ONLY")
      source_subnetwork_ip_ranges_to_nat  = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
      min_ports_per_vm                    = optional(number, 64)
      enable_endpoint_independent_mapping = optional(bool, true)
      log_config_enable                   = optional(bool, false)
      log_config_filter                   = optional(string, "ERRORS_ONLY")
    })), {})
    firewall_rules = optional(map(object({
      description             = optional(string, "")
      direction               = string
      priority                = optional(number, 1000)
      ranges                  = optional(list(string), [])
      target_tags             = optional(list(string), [])
      source_tags             = optional(list(string), [])
      source_service_accounts = optional(list(string), [])
      allow = optional(list(object({
        protocol = string
        ports    = optional(list(string), [])
      })), [])
      deny = optional(list(object({
        protocol = string
        ports    = optional(list(string), [])
      })), [])
      log_config_enable = optional(bool, false)
    })), {})
  }))
}

# ─── Hub (interconnect) VPC ───────────────────────────────────────────────────
variable "hub_project_id" {
  description = "Project ID of the interconnect/hub project (prj-sh-interconnect)."
  type        = string
}

variable "hub_network_name" {
  description = "Name of the hub VPC network."
  type        = string
  default     = "vpc-interconnect"
}

variable "hub_subnets" {
  description = "Subnets for the hub/interconnect VPC. See shared-vpc module for schema."
  type = map(object({
    ip_cidr_range         = string
    region                = string
    private_google_access = optional(bool, true)
    enable_flow_logs      = optional(bool, false)
    flow_log_interval     = optional(string, "INTERVAL_5_SEC")
    flow_log_sampling     = optional(number, 0.5)
    secondary_ranges      = optional(list(object({ range_name = string, ip_cidr_range = string })), [])
    description           = optional(string, "")
  }))
  default = {}
}

variable "hub_nat_config" {
  description = "Cloud NAT config for the hub VPC."
  type = map(object({
    nat_ip_allocate_option              = optional(string, "AUTO_ONLY")
    source_subnetwork_ip_ranges_to_nat  = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
    min_ports_per_vm                    = optional(number, 64)
    enable_endpoint_independent_mapping = optional(bool, true)
    log_config_enable                   = optional(bool, false)
    log_config_filter                   = optional(string, "ERRORS_ONLY")
  }))
  default = {}
}

variable "hub_firewall_rules" {
  description = "Firewall rules for the hub VPC."
  type = map(object({
    description             = optional(string, "")
    direction               = string
    priority                = optional(number, 1000)
    ranges                  = optional(list(string), [])
    target_tags             = optional(list(string), [])
    source_tags             = optional(list(string), [])
    source_service_accounts = optional(list(string), [])
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    log_config_enable = optional(bool, false)
  }))
  default = {}
}

# ─── DNS ─────────────────────────────────────────────────────────────────────
variable "dns_project_id" {
  description = "Project ID where DNS hub zones are created (typically hub/interconnect project)."
  type        = string
}

variable "private_dns_zones" {
  description = "Private DNS zones in the hub. See dns module for schema."
  type = map(object({
    dns_name    = string
    description = optional(string, "")
    networks    = list(string)
  }))
  default = {}
}

variable "peering_dns_zones" {
  description = "DNS peering zones. See dns module for schema."
  type = map(object({
    dns_name     = string
    networks     = list(string)
    peer_network = string
  }))
  default = {}
}

variable "forwarding_dns_zones" {
  description = "DNS forwarding zones (on-prem / Azure). See dns module for schema."
  type = map(object({
    dns_name      = string
    networks      = list(string)
    target_dns_ip = list(string)
  }))
  default = {}
}

variable "labels" {
  description = "Common labels for networking resources."
  type        = map(string)
  default     = {}
}

variable "project_suffix" {
  description = "Suffix appended to project IDs to ensure uniqueness."
  type        = string
  default     = ""
}

