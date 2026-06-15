output "network_id" {
  description = "Self-link of the VPC network."
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "Name of the VPC network."
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "Self-link URI of the VPC network."
  value       = google_compute_network.vpc.self_link
}

output "subnet_ids" {
  description = "Map of subnet name -> subnet self-link."
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.self_link }
}

output "subnet_self_links" {
  description = "Map of subnet name -> full self-link including project and region."
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.self_link }
}

output "router_names" {
  description = "Map of region -> Cloud Router name."
  value       = { for k, v in google_compute_router.routers : k => v.name }
}
