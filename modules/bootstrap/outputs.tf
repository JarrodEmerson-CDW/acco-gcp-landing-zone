
output "wif_pool_name" {
  description = "Full resource name of the Workload Identity Pool."
  value       = google_iam_workload_identity_pool.github.name
}

output "wif_provider_name" {
  description = "Full resource name of the GitHub OIDC WIF Provider."
  value       = google_iam_workload_identity_pool_provider.github_oidc.name
}

output "cicd_sa_emails" {
  description = "Map of repo key -> CICD service account email."
  value       = { for k, v in local.wif_sa_map : k => "${v.sa_id}@${var.project_id}.iam.gserviceaccount.com" }
}

output "seed_sa_emails" {
  description = "Map of seed SA account_id -> email."
  value       = { for k, v in var.seed_service_accounts : k => "${k}@${var.project_id}.iam.gserviceaccount.com" }
}
