output "service_account_emails" {
  description = "Map of SA account_id -> full email address."
  value       = { for k, v in google_service_account.sa : k => v.email }
}

output "service_account_names" {
  description = "Map of SA account_id -> resource name (projects/.../serviceAccounts/...)."
  value       = { for k, v in google_service_account.sa : k => v.name }
}
