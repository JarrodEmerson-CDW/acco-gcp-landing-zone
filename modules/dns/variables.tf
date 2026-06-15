variable "project_id" {
  description = "Project ID where Cloud DNS resources are created (typically the interconnect/hub project)."
  type        = string
}

variable "private_zones" {
  description = <<-EOT
    Map of private DNS zones to create in this project.
    Key = zone name (used as resource name).
    - dns_name     : DNS suffix (must end with a dot), e.g. "accoes.internal."
    - description  : zone description
    - networks     : list of VPC self-links that can resolve this zone
  EOT
  type = map(object({
    dns_name    = string
    description = optional(string, "")
    networks    = list(string)
  }))
  default = {}
}

variable "peering_zones" {
  description = <<-EOT
    Map of DNS peering zones: delegate resolution to a peer VPC/zone.
    Key = zone name.
    - dns_name        : DNS suffix (ends with dot)
    - networks        : list of VPC self-links that will use this zone
    - peer_network    : VPC self-link of the network that hosts the authoritative zone
  EOT
  type = map(object({
    dns_name     = string
    networks     = list(string)
    peer_network = string
  }))
  default = {}
}

variable "forwarding_zones" {
  description = <<-EOT
    Map of DNS forwarding zones (for on-prem / Azure resolution).
    Key = zone name.
    - dns_name      : DNS suffix (ends with dot)
    - networks      : list of VPC self-links that will use this zone
    - target_dns_ip : list of upstream DNS server IP addresses
  EOT
  type = map(object({
    dns_name      = string
    networks      = list(string)
    target_dns_ip = list(string)
  }))
  default = {}
}

variable "labels" {
  description = "Labels to apply to DNS resources."
  type        = map(string)
  default     = {}
}
