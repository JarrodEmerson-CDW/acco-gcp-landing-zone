locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
    component  = "org"
  })
}

# ─── Folder hierarchy ─────────────────────────────────────────────────────────
module "folders" {
  source = "../../modules/folders"

  org_id            = var.org_id
  top_level_folders = var.top_level_folders
  shared_subfolders = var.shared_subfolders
  business_units    = var.business_units
  labels            = local.common_labels
}

# ─── Organization policies ────────────────────────────────────────────────────
module "org_policies" {
  source = "../../modules/org-policies"

  org_id                  = var.org_id
  boolean_policies        = var.boolean_org_policies
  list_policies           = var.list_org_policies
  folder_policy_overrides = var.folder_policy_overrides

  depends_on = [module.folders]
}
