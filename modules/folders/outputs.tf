output "top_level_folder_ids" {
  description = "Map of top-level folder display_name -> folder resource ID (folders/<id>)."
  value       = { for k, v in google_folder.top_level : k => v.name }
}

output "top_level_folder_numbers" {
  description = "Map of top-level folder display_name -> numeric folder ID."
  value       = { for k, v in google_folder.top_level : k => v.folder_id }
}

output "bu_subfolder_ids" {
  description = "Map of '<env>/<business_unit>' -> folder resource ID."
  value       = { for k, v in google_folder.business_unit : k => v.name }
}

output "static_subfolder_ids" {
  description = "Map of '<parent>/<child>' -> folder resource ID."
  value       = { for k, v in google_folder.static_sub : k => v.name }
}
