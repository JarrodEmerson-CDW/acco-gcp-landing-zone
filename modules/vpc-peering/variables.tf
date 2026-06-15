variable "local_project_id" {
  description = "Project ID of the VPC that initiates the peering (spoke)."
  type        = string
}

variable "local_network_name" {
  description = "Name of the local (spoke) VPC network."
  type        = string
}

variable "peer_project_id" {
  description = "Project ID of the peer (hub/interconnect) VPC."
  type        = string
}

variable "peer_network_name" {
  description = "Name of the peer (hub/interconnect) VPC network."
  type        = string
}

variable "export_custom_routes" {
  description = "Whether to export custom routes from this network to the peer."
  type        = bool
  default     = false
}

variable "import_custom_routes" {
  description = "Whether to import custom routes from the peer network."
  type        = bool
  default     = false
}

variable "export_subnet_routes_with_public_ip" {
  description = "Whether to export subnet routes with public IPs."
  type        = bool
  default     = false
}

variable "import_subnet_routes_with_public_ip" {
  description = "Whether to import subnet routes with public IPs."
  type        = bool
  default     = false
}
