output "org_binding_ids" {
  description = "Map of binding key -> IAM member string for org bindings."
  value       = { for k, v in google_organization_iam_member.org : k => v.etag }
}

output "folder_binding_ids" {
  description = "Map of binding key -> etag for folder bindings."
  value       = { for k, v in google_folder_iam_member.folder : k => v.etag }
}

output "project_binding_ids" {
  description = "Map of binding key -> etag for project bindings."
  value       = { for k, v in google_project_iam_member.project : k => v.etag }
}
