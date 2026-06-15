output "private_zone_ids" {
  description = "Map of private zone name -> zone resource ID."
  value       = { for k, v in google_dns_managed_zone.private : k => v.id }
}

output "peering_zone_ids" {
  description = "Map of peering zone name -> zone resource ID."
  value       = { for k, v in google_dns_managed_zone.peering : k => v.id }
}

output "forwarding_zone_ids" {
  description = "Map of forwarding zone name -> zone resource ID."
  value       = { for k, v in google_dns_managed_zone.forwarding : k => v.id }
}
