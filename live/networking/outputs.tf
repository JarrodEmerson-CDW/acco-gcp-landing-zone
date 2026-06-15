output "hub_network_self_link" {
  description = "Self-link of the hub/interconnect VPC."
  value       = module.hub_vpc.network_self_link
}

output "hub_subnet_self_links" {
  description = "Map of hub subnet name -> self-link."
  value       = module.hub_vpc.subnet_self_links
}

output "spoke_network_self_links" {
  description = "Map of env -> VPC self-link for each spoke."
  value       = { for k, v in module.spoke_vpcs : k => v.network_self_link }
}

output "spoke_subnet_self_links" {
  description = "Map of env -> { subnet_name -> self_link }."
  value       = { for k, v in module.spoke_vpcs : k => v.subnet_self_links }
}

output "peering_names" {
  description = "Map of env -> spoke-to-hub peering name."
  value       = { for k, v in module.vpc_peering : k => v.spoke_to_hub_peering_name }
}

output "dns_private_zone_ids" {
  description = "Map of private DNS zone name -> resource ID."
  value       = module.dns.private_zone_ids
}
