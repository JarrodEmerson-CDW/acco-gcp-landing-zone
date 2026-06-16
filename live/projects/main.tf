locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
  })
}

# ─── Project factory — one call per project entry ─────────────────────────────
# Each entry in var.projects drives a module instantiation via for_each.
# To add a new project: add an entry to var.projects in tfvars only.
module "projects" {
  source   = "../../modules/project"
  for_each = var.projects

  env_code              = each.value.env_code
  app                   = each.value.app
  project_name_template = var.project_name_template
  project_suffix        = var.project_suffix
  folder_id             = each.value.folder_id
  billing_account_id    = var.billing_account_id
  apis                  = distinct(concat(var.default_project_apis, each.value.additional_apis))
  skip_delete           = each.value.skip_delete

  labels = merge(local.common_labels, {
    environment = each.value.env_code
    application = each.value.app
  }, each.value.labels)
}
