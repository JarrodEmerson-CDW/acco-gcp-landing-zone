locals {
  # Flatten project role assignments: SA account_id + role -> one resource per pair
  project_role_pairs = flatten([
    for sa_key, sa_cfg in var.service_accounts : [
      for role in sa_cfg.project_roles : {
        key    = "${sa_key}/${role}"
        sa_key = sa_key
        role   = role
      }
    ]
  ])

  # Flatten SA IAM bindings: who can use/impersonate each SA
  sa_iam_pairs = flatten([
    for sa_key, sa_cfg in var.service_accounts : [
      for member, roles in sa_cfg.iam_bindings : [
        for role in roles : {
          key    = "${sa_key}/${member}/${role}"
          sa_key = sa_key
          member = member
          role   = role
        }
      ]
    ]
  ])
}

# ─── Create service accounts ──────────────────────────────────────────────────
resource "google_service_account" "sa" {
  for_each = var.service_accounts

  project      = var.project_id
  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
}

# ─── Grant project-level roles to each SA ─────────────────────────────────────
resource "google_project_iam_member" "sa_project_roles" {
  for_each = {
    for pair in local.project_role_pairs : pair.key => pair
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.sa_key].email}"

  depends_on = [google_service_account.sa]
}

# ─── Grant IAM bindings on the SA resource (for impersonation / WIF) ─────────
resource "google_service_account_iam_member" "sa_iam" {
  for_each = {
    for pair in local.sa_iam_pairs : pair.key => pair
  }

  service_account_id = google_service_account.sa[each.value.sa_key].name
  role               = each.value.role
  member             = each.value.member

  depends_on = [google_service_account.sa]
}
