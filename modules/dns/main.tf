# ─── Private zones ───────────────────────────────────────────────────────────
resource "google_dns_managed_zone" "private" {
  for_each = var.private_zones

  project     = var.project_id
  name        = each.key
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = each.value.networks
      content {
        network_url = networks.value
      }
    }
  }

  labels = var.labels
}

# ─── Peering zones (delegate resolution to a peer VPC's zone) ────────────────
resource "google_dns_managed_zone" "peering" {
  for_each = var.peering_zones

  project     = var.project_id
  name        = each.key
  dns_name    = each.value.dns_name
  description = "DNS peering zone for ${each.value.dns_name}"
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = each.value.networks
      content {
        network_url = networks.value
      }
    }
  }

  peering_config {
    target_network {
      network_url = each.value.peer_network
    }
  }

  labels = var.labels
}

# ─── Forwarding zones (on-prem / Azure / external resolvers) ─────────────────
resource "google_dns_managed_zone" "forwarding" {
  for_each = var.forwarding_zones

  project     = var.project_id
  name        = each.key
  dns_name    = each.value.dns_name
  description = "DNS forwarding zone for ${each.value.dns_name}"
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = each.value.networks
      content {
        network_url = networks.value
      }
    }
  }

  forwarding_config {
    dynamic "target_name_servers" {
      for_each = each.value.target_dns_ip
      content {
        ipv4_address    = target_name_servers.value
        forwarding_path = "default"
      }
    }
  }

  labels = var.labels
}
