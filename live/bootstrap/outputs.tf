
output "wif_pool_name" {
  description = "Full WIF pool resource name."
  value       = module.bootstrap.wif_pool_name
}

output "wif_provider_name" {
  description = "Full WIF provider resource name — add to GitHub Actions workflows."
  value       = module.bootstrap.wif_provider_name
}

output "cicd_sa_emails" {
  description = "Map of repo -> CICD SA email — add to GitHub Actions workflows."
  value       = module.bootstrap.cicd_sa_emails
}
