locals {
  common_labels = merge(var.labels, {
    managed_by  = "terraform"
    environment = "shared"
    component   = "bootstrap"
  })
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  project_id            = var.cicd_project_id
  state_bucket_name     = var.state_bucket_name
  state_bucket_location = var.state_bucket_location
  github_org            = var.github_org
  github_repos          = var.github_repos
  wif_pool_id           = var.wif_pool_id
  wif_provider_id       = var.wif_provider_id
  seed_service_accounts = var.seed_service_accounts
  labels                = local.common_labels
}
