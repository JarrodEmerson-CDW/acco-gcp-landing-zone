output "project_ids" {
  description = "Map of project key -> GCP project ID."
  value       = { for k, v in module.projects : k => v.project_id }
}

output "project_numbers" {
  description = "Map of project key -> GCP project number."
  value       = { for k, v in module.projects : k => v.project_number }
}
