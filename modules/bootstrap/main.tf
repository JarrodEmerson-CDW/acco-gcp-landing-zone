locals {
  # Flatten WIF SA -> repo attribute conditions
  wif_sa_pairs = flatten([
    for repo_key, repo_cfg in var.github_repos : {
      key       = repo_key
      repo_name = repo_cfg.repo_name
      sa_id     = "sa-cicd-${repo_key}"
      sa_desc   = repo_cfg.description
      sa_roles  = repo_cfg.sa_roles
    }
  ])

  wif_sa_map = { for pair in local.wif_sa_pairs : pair.key => pair }

  # Seed SA list
  all_seed_sas = merge(
    { for pair in local.wif_sa_pairs : pair.sa_id => {
        display_name  = "CICD SA – ${pair.repo_name}"
        description   = pair.sa_desc
        project_roles = pair.sa_roles
      }
    },
    var.seed_service_accounts
  )
}


# ─── Workload Identity Pool ───────────────────────────────────────────────────
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub Actions WIF Pool"
  description               = "Workload Identity Pool for GitHub Actions OIDC authentication"
  disabled                  = false
}

# ─── Workload Identity OIDC Provider (GitHub) ────────────────────────────────
resource "google_iam_workload_identity_pool_provider" "github_oidc" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub OIDC"
  description                        = "OIDC provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Restrict to the ACCO GitHub org
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_iam_workload_identity_pool.github]
}



# ─── Bind WIF pool to each CICD SA (per-repo attribute condition) ─────────────
resource "google_service_account_iam_member" "wif_bindings" {
  for_each = local.wif_sa_map

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.sa_id}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  # Allow any ref in the specific repo to impersonate this SA
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value.repo_name}"

  depends_on = [
    google_iam_workload_identity_pool_provider.github_oidc
  ]
}

# ─── Grant project-level roles to CICD SAs ───────────────────────────────────
locals {
  cicd_role_pairs = flatten([
    for sa_key, sa_cfg in local.wif_sa_map : [
      for role in sa_cfg.sa_roles : {
        key    = "${sa_key}/${role}"
        sa_key = sa_key
        role   = role
      }
    ]
  ])
}

resource "google_project_iam_member" "cicd_sa_roles" {
  for_each = { for pair in local.cicd_role_pairs : pair.key => pair }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:sa-cicd-${each.value.sa_key}@${var.project_id}.iam.gserviceaccount.com"
}
