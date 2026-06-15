output "spoke_to_hub_peering_name" {
  description = "Name of the spoke->hub peering resource."
  value       = google_compute_network_peering.spoke_to_hub.name
}

output "hub_to_spoke_peering_name" {
  description = "Name of the hub->spoke peering resource."
  value       = google_compute_network_peering.hub_to_spoke.name
}
