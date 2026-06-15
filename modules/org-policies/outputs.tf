output "org_policy_names" {
  description = "List of org-level policy resource names applied."
  value = concat(
    [for v in google_org_policy_policy.boolean : v.name],
    [for v in google_org_policy_policy.list : v.name]
  )
}

output "folder_override_names" {
  description = "List of folder-level policy override resource names."
  value = concat(
    [for v in google_org_policy_policy.folder_boolean_override : v.name],
    [for v in google_org_policy_policy.folder_list_override : v.name]
  )
}
