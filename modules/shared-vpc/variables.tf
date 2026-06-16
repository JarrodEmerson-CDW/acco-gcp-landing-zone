variable "host_project_id" {
  description = "Project ID of the Shared VPC host project."
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network to create."
  type        = string
}

variable "routing_mode" {
  description = "Network routing mode: REGIONAL or GLOBAL."
  type        = string
  default     = "GLOBAL"
}

variable "subnets" {
  description = <<-EOT
    Map of subnets to create. Key = subnet short name.
    Attributes:
      - ip_cidr_range           : primary CIDR
      - region                  : GCP region
      - private_google_access   : enable PGA (default true)
      - enable_flow_logs        : toggle VPC flow logs (default false)
      - flow_log_interval       : aggregation interval (default INTERVAL_5_SEC)
      - flow_log_sampling       : sampling rate 0.0-1.0 (default 0.5)
      - secondary_ranges         : list of { range_name, ip_cidr_range }
      - description             : optional description
  EOT
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

variable "nat_config" {
  description = <<-EOT
    Per-region NAT configuration. If empty, no Cloud NAT is created.
    Key = region. Values control NAT behaviour.
  EOT
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

variable "firewall_rules" {
  description = <<-EOT
    Custom firewall rules to create. Key = rule name.
    Minimally specify direction, priority, and allow/deny blocks.
  EOT
  type = map(object({
    description             = optional(string, "")
    direction               = string # INGRESS | EGRESS
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

variable "service_project_ids" {
  description = "List of service project IDs to attach to this Shared VPC host project."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to network resources."
  type        = map(string)
  default     = {}
}

variable "delete_default_routes_on_create" {
  description = "Whether to delete the default internet gateway route on VPC creation."
  type        = bool
  default     = true
}
