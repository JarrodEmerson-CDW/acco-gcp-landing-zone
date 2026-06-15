locals {
  org_bindings     = { for k, v in var.bindings : k => v if v.resource_type == "organization" }
  folder_bindings  = { for k, v in var.bindings : k => v if v.resource_type == "folder" }
  project_bindings = { for k, v in var.bindings : k => v if v.resource_type == "project" }
}

# ─── Organization-level bindings ─────────────────────────────────────────────
resource "google_organization_iam_member" "org" {
  for_each = local.org_bindings

  org_id = each.value.resource_id
  member = each.value.member
  role   = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# ─── Folder-level bindings ────────────────────────────────────────────────────
resource "google_folder_iam_member" "folder" {
  for_each = local.folder_bindings

  folder = each.value.resource_id
  member = each.value.member
  role   = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# ─── Project-level bindings ───────────────────────────────────────────────────
resource "google_project_iam_member" "project" {
  for_each = local.project_bindings

  project = each.value.resource_id
  member  = each.value.member
  role    = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
