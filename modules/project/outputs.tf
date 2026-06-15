output "project_id" {
  description = "The GCP project ID."
  value       = google_project.this.project_id
}

output "project_number" {
  description = "The GCP project number."
  value       = google_project.this.number
}

output "project_name" {
  description = "The GCP project name (same as project ID in this factory)."
  value       = google_project.this.name
}

output "enabled_apis" {
  description = "Set of APIs enabled on the project."
  value       = [for svc in google_project_service.apis : svc.service]
}
