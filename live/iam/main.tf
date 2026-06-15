locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
  })

  # Group service accounts by project_id for module calls
  sa_by_project = {
    for k, v in var.service_accounts : k => v
  }
}

# ─── IAM Bindings (group -> role at org / folder / project) ──────────────────
# Add new bindings by adding entries to var.iam_bindings in tfvars.
module "iam_bindings" {
  source   = "../../modules/iam-bindings"
  bindings = var.iam_bindings
}

# ─── Service Accounts ─────────────────────────────────────────────────────────
# Each SA is created in its designated project.
# Groups service accounts by project to call the module once per project.
locals {
  # Unique project IDs across all SAs
  sa_project_ids = distinct([for k, v in var.service_accounts : v.project_id])

  # Group SAs by project_id
  sas_by_project = {
    for pid in local.sa_project_ids : pid => {
      for k, v in var.service_accounts : k => v if v.project_id == pid
    }
  }
}

module "service_accounts" {
  source   = "../../modules/service-accounts"
  for_each = local.sas_by_project

  project_id = each.key
  service_accounts = {
    for sa_key, sa_cfg in each.value : sa_key => {
      display_name  = sa_cfg.display_name
      description   = sa_cfg.description
      project_roles = sa_cfg.project_roles
      iam_bindings  = sa_cfg.iam_bindings
    }
  }
  labels = local.common_labels
}

# ─── Log Sinks ────────────────────────────────────────────────────────────────
module "log_sinks" {
  source   = "../../modules/log-sink"
  for_each = var.log_sinks

  sink_project_id          = each.value.sink_project_id
  sink_name                = each.value.sink_name
  parent_type              = each.value.parent_type
  parent_id                = each.value.parent_id
  filter                   = each.value.filter
  include_children         = each.value.include_children
  bucket_name              = each.value.bucket_name
  bucket_location          = each.value.bucket_location
  retention_days           = each.value.retention_days
  audit_retention_days     = each.value.audit_retention_days
  nearline_age_days        = each.value.nearline_age_days
  archive_age_days         = each.value.archive_age_days
  pubsub_topic_name        = each.value.pubsub_topic_name
  splunk_subscription_name = each.value.splunk_subscription_name
  splunk_push_endpoint     = each.value.splunk_push_endpoint
  labels                   = merge(local.common_labels, each.value.labels)
}

# ─── Billing Budgets ──────────────────────────────────────────────────────────
module "budgets" {
  source = "../../modules/budget"

  billing_account_id = var.billing_account_id
  budgets            = var.budgets
}
