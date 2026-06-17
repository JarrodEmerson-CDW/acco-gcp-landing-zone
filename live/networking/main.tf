locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
    component  = "networking"
  })

  # Automatically attach the hub VPC to all private DNS zones
  private_dns_zones = {
    for k, v in var.private_dns_zones : k => merge(v, {
      networks = distinct(concat([module.hub_vpc.network_self_link], v.networks))
    })
  }

  # Programmatically peer all spokes to the hub VPC for DNS resolution
  peering_dns_zones = merge(
    {
      for env, spoke in var.spoke_vpcs : "peer-${env}-to-hub" => {
        dns_name     = "accoes.internal."
        networks     = [module.spoke_vpcs[env].network_self_link]
        peer_network = module.hub_vpc.network_self_link
      }
    },
    var.peering_dns_zones
  )

  # Automatically attach the hub VPC to forwarding DNS zones
  forwarding_dns_zones = {
    for k, v in var.forwarding_dns_zones : k => merge(v, {
      networks = distinct(concat([module.hub_vpc.network_self_link], v.networks))
    })
  }
}

# ─── Hub (interconnect) VPC ───────────────────────────────────────────────────
module "hub_vpc" {
  source = "../../modules/shared-vpc"

  host_project_id = var.project_suffix != "" ? "${var.hub_project_id}-${var.project_suffix}" : var.hub_project_id
  network_name    = var.hub_network_name
  subnets         = var.hub_subnets
  nat_config      = var.hub_nat_config
  firewall_rules  = var.hub_firewall_rules
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

  host_project_id                 = var.project_suffix != "" ? "${each.value.host_project_id}-${var.project_suffix}" : each.value.host_project_id
  network_name                    = each.value.network_name
  subnets                         = each.value.subnets
  nat_config                      = each.value.nat_config
  firewall_rules                  = each.value.firewall_rules
  service_project_ids             = each.value.service_project_ids
  delete_default_routes_on_create = true
  labels                          = merge(local.common_labels, { environment = each.key })
}

# ─── VPC Peering: each spoke <-> hub ─────────────────────────────────────────
# Non-transitive: spokes only peer with the hub, never with each other.
# Environments are isolated by design — cross-env traffic goes through the hub firewall.
module "vpc_peering" {
  source   = "../../modules/vpc-peering"
  for_each = var.spoke_vpcs

  local_project_id   = var.project_suffix != "" ? "${each.value.host_project_id}-${var.project_suffix}" : each.value.host_project_id
  local_network_name = each.value.network_name
  peer_project_id    = var.project_suffix != "" ? "${var.hub_project_id}-${var.project_suffix}" : var.hub_project_id
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

  project_id       = var.project_suffix != "" ? "${var.dns_project_id}-${var.project_suffix}" : var.dns_project_id
  private_zones    = local.private_dns_zones
  peering_zones    = local.peering_dns_zones
  forwarding_zones = local.forwarding_dns_zones
  labels           = local.common_labels

  depends_on = [
    module.hub_vpc,
    module.spoke_vpcs,
  ]
}
