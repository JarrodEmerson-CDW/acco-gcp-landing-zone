output "state_bucket_name" {
  description = "Name of the Terraform remote state GCS bucket."
  value       = google_storage_bucket.tf_state.name
}

output "state_bucket_url" {
  description = "GCS URL of the Terraform state bucket."
  value       = google_storage_bucket.tf_state.url
}

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
  value       = { for k, v in google_service_account.cicd_sas : k => v.email }
}

output "seed_sa_emails" {
  description = "Map of seed SA account_id -> email."
  value       = { for k, v in google_service_account.seed_sas : k => v.email }
}
