locals {
  folder_boolean_overrides = {
    for k, v in var.folder_policy_overrides : k => v if v.policy_type == "boolean"
  }
  folder_list_overrides = {
    for k, v in var.folder_policy_overrides : k => v if v.policy_type == "list"
  }
}

# ─── Org-level boolean policies ──────────────────────────────────────────────
resource "google_org_policy_policy" "boolean" {
  for_each = var.boolean_policies

  name   = "organizations/${var.org_id}/policies/${replace(each.key, "constraints/", "")}"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = each.value.enforced ? "TRUE" : "FALSE"
    }
  }
}

# ─── Org-level list policies ──────────────────────────────────────────────────
resource "google_org_policy_policy" "list" {
  for_each = var.list_policies

  name   = "organizations/${var.org_id}/policies/${replace(each.key, "constraints/", "")}"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      # allow_all and deny_all are mutually exclusive
      dynamic "values" {
        for_each = length(each.value.allow_values) > 0 || length(each.value.deny_values) > 0 ? [1] : []
        content {
          allowed_values = length(each.value.allow_values) > 0 ? each.value.allow_values : null
          denied_values  = length(each.value.deny_values) > 0 ? each.value.deny_values : null
        }
      }
      allow_all = each.value.allow_all ? "TRUE" : null
      deny_all  = each.value.deny_all ? "TRUE" : null
    }
  }
}

# ─── Folder-level boolean policy overrides ────────────────────────────────────
resource "google_org_policy_policy" "folder_boolean_override" {
  for_each = local.folder_boolean_overrides

  name   = "folders/${each.value.folder_id}/policies/${replace(each.value.constraint, "constraints/", "")}"
  parent = "folders/${each.value.folder_id}"

  spec {
    rules {
      enforce = each.value.enforced ? "TRUE" : "FALSE"
    }
  }
}

# ─── Folder-level list policy overrides ───────────────────────────────────────
resource "google_org_policy_policy" "folder_list_override" {
  for_each = local.folder_list_overrides

  name   = "folders/${each.value.folder_id}/policies/${replace(each.value.constraint, "constraints/", "")}"
  parent = "folders/${each.value.folder_id}"

  spec {
    rules {
      dynamic "values" {
        for_each = length(each.value.allow_values) > 0 || length(each.value.deny_values) > 0 ? [1] : []
        content {
          allowed_values = length(each.value.allow_values) > 0 ? each.value.allow_values : null
          denied_values  = length(each.value.deny_values) > 0 ? each.value.deny_values : null
        }
      }
      allow_all = each.value.allow_all ? "TRUE" : null
      deny_all  = each.value.deny_all ? "TRUE" : null
    }
  }
}
