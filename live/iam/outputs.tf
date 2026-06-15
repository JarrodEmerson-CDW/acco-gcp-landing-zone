output "log_sink_writer_identities" {
  description = "Map of sink key -> writer identity (for granting additional destination access)."
  value       = { for k, v in module.log_sinks : k => v.sink_writer_identity }
}

output "log_sink_bucket_names" {
  description = "Map of sink key -> GCS log bucket name."
  value       = { for k, v in module.log_sinks : k => v.gcs_bucket_name }
}

output "budget_names" {
  description = "Map of budget display name -> resource name."
  value       = module.budgets.budget_names
}
