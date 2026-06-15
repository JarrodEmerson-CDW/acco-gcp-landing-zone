locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
    component  = "networking"
  })
}

# ─── Hub (interconnect) VPC ───────────────────────────────────────────────────
module "hub_vpc" {
  source = "../../modules/shared-vpc"

  host_project_id  = var.hub_project_id
  network_name     = var.hub_network_name
  subnets          = var.hub_subnets
  nat_config       = var.hub_nat_config
  firewall_rules   = var.hub_firewall_rules
  # Hub is not a Shared VPC host in the traditional sense — it's a pure routing hub;
  # service project attachment is done at spoke level.
  service_project_ids             = []
  delete_default_routes_on_create = true
  labels                          = local.common_labels
}

# ─── Spoke VPCs (dev / non-prod / prod) ──────────────────────────────────────
# for_each over the spoke_vpcs map — adding a new spoke is a tfvars change only.
module "spoke_vpcs" {
  source   = "../../modules/shared-vpc"
  for_each = var.spoke_vpcs

  host_project_id             = each.value.host_project_id
  network_name                = each.value.network_name
  subnets                     = each.value.subnets
  nat_config                  = each.value.nat_config
  firewall_rules              = each.value.firewall_rules
  service_project_ids         = each.value.service_project_ids
  delete_default_routes_on_create = true
  labels = merge(local.common_labels, { environment = each.key })
}

# ─── VPC Peering: each spoke <-> hub ─────────────────────────────────────────
# Non-transitive: spokes only peer with the hub, never with each other.
# Environments are isolated by design — cross-env traffic goes through the hub firewall.
module "vpc_peering" {
  source   = "../../modules/vpc-peering"
  for_each = var.spoke_vpcs

  local_project_id  = each.value.host_project_id
  local_network_name = each.value.network_name
  peer_project_id   = var.hub_project_id
  peer_network_name  = var.hub_network_name

  # Spokes do NOT export/import custom routes to prevent transitive routing
  export_custom_routes = false
  import_custom_routes = false

  depends_on = [
    module.hub_vpc,
    module.spoke_vpcs,
  ]
}

# ─── Cloud DNS Hub ────────────────────────────────────────────────────────────
module "dns" {
  source = "../../modules/dns"

  project_id       = var.dns_project_id
  private_zones    = var.private_dns_zones
  peering_zones    = var.peering_dns_zones
  forwarding_zones = var.forwarding_dns_zones
  labels           = local.common_labels

  depends_on = [
    module.hub_vpc,
    module.spoke_vpcs,
  ]
}
