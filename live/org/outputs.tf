output "top_level_folder_ids" {
  description = "Map of top-level folder display name -> resource ID (folders/<N>)."
  value       = module.folders.top_level_folder_ids
}

output "top_level_folder_numbers" {
  description = "Map of top-level folder display name -> numeric folder ID."
  value       = module.folders.top_level_folder_numbers
}

output "bu_subfolder_ids" {
  description = "Map of '<env>/<business_unit>' -> folder resource ID."
  value       = module.folders.bu_subfolder_ids
}

output "static_subfolder_ids" {
  description = "Map of '<parent>/<child>' -> folder resource ID."
  value       = module.folders.static_subfolder_ids
}

output "org_policy_names" {
  description = "List of org policy resource names applied."
  value       = module.org_policies.org_policy_names
}
