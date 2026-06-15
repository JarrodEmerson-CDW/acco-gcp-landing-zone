locals {
  # Unique regions where at least one subnet is defined
  subnet_regions = toset([for s in var.subnets : s.region])
}

# ─── VPC Network ─────────────────────────────────────────────────────────────
resource "google_compute_network" "vpc" {
  project                         = var.host_project_id
  name                            = var.network_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

# ─── Subnets ──────────────────────────────────────────────────────────────────
resource "google_compute_subnetwork" "subnets" {
  for_each = var.subnets

  project                  = var.host_project_id
  name                     = each.key
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = each.value.ip_cidr_range
  region                   = each.value.region
  private_ip_google_access = each.value.private_google_access
  description              = each.value.description

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = each.value.flow_log_interval
      flow_sampling        = each.value.flow_log_sampling
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }

  depends_on = [google_compute_network.vpc]
}

# ─── Cloud Router (one per region that has NAT configured) ───────────────────
resource "google_compute_router" "routers" {
  for_each = var.nat_config

  project = var.host_project_id
  name    = "${var.network_name}-router-${each.key}"
  network = google_compute_network.vpc.id
  region  = each.key
}

# ─── Cloud NAT ───────────────────────────────────────────────────────────────
resource "google_compute_router_nat" "nats" {
  for_each = var.nat_config

  project                            = var.host_project_id
  name                               = "${var.network_name}-nat-${each.key}"
  router                             = google_compute_router.routers[each.key].name
  region                             = each.key
  nat_ip_allocate_option             = each.value.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat
  min_ports_per_vm                   = each.value.min_ports_per_vm
  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping

  log_config {
    enable = each.value.log_config_enable
    filter = each.value.log_config_filter
  }

  depends_on = [google_compute_router.routers]
}

# ─── Firewall rules ───────────────────────────────────────────────────────────
resource "google_compute_firewall" "rules" {
  for_each = var.firewall_rules

  project     = var.host_project_id
  name        = each.key
  network     = google_compute_network.vpc.id
  description = each.value.description
  direction   = each.value.direction
  priority    = each.value.priority

  source_ranges          = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges     = each.value.direction == "EGRESS" ? each.value.ranges : null
  target_tags            = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  source_tags            = each.value.direction == "INGRESS" && length(each.value.source_tags) > 0 ? each.value.source_tags : null
  source_service_accounts = length(each.value.source_service_accounts) > 0 ? each.value.source_service_accounts : null

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config_enable ? [1] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

# ─── Enable Shared VPC on host project ───────────────────────────────────────
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

# ─── Attach service projects ──────────────────────────────────────────────────
resource "google_compute_shared_vpc_service_project" "service_projects" {
  for_each = toset(var.service_project_ids)

  host_project    = var.host_project_id
  service_project = each.value

  depends_on = [google_compute_shared_vpc_host_project.host]
}
