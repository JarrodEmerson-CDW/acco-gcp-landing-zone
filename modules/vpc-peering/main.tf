locals {
  peer_network_self_link  = "https://www.googleapis.com/compute/v1/projects/${var.peer_project_id}/global/networks/${var.peer_network_name}"
  local_network_self_link = "https://www.googleapis.com/compute/v1/projects/${var.local_project_id}/global/networks/${var.local_network_name}"
}

# Spoke -> Hub peering
resource "google_compute_network_peering" "spoke_to_hub" {
  name                                = "${var.local_network_name}-to-${var.peer_network_name}"
  network                             = local.local_network_self_link
  peer_network                        = local.peer_network_self_link
  export_custom_routes                = var.export_custom_routes
  import_custom_routes                = var.import_custom_routes
  export_subnet_routes_with_public_ip = var.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.import_subnet_routes_with_public_ip
}

# Hub -> Spoke peering (reverse direction — both sides must be created)
resource "google_compute_network_peering" "hub_to_spoke" {
  name                                = "${var.peer_network_name}-to-${var.local_network_name}"
  network                             = local.peer_network_self_link
  peer_network                        = local.local_network_self_link
  export_custom_routes                = var.import_custom_routes
  import_custom_routes                = var.export_custom_routes
  export_subnet_routes_with_public_ip = var.import_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.export_subnet_routes_with_public_ip

  # Peerings must be created sequentially to avoid API conflicts
  depends_on = [google_compute_network_peering.spoke_to_hub]
}
