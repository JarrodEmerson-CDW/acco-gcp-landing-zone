variable "org_id" {
  description = "Google Cloud Organization ID (numeric)."
  type        = string
}

variable "top_level_folders" {
  description = <<-EOT
    Map of top-level folder definitions. Key = folder display name.
    - code        : short env code (dv, np, pd, sh, sb)
    - has_bu_subs : whether to create business-unit sub-folders inside this folder
  EOT
  type = map(object({
    code        = string
    has_bu_subs = bool
  }))
}

variable "shared_subfolders" {
  description = <<-EOT
    Map of sub-folder names to create under folders that are NOT business-unit driven
    (e.g. "networking" and "infrastructure" under shared-services, "cicd" under bootstrap).
    Key format: "<parent_display_name>/<child_display_name>"
  EOT
  type    = map(string) # key = "parent_name/child_name", value = display name
  default = {}
}

variable "business_units" {
  description = "List of business-unit names to create as sub-folders under each env folder that has has_bu_subs=true."
  type        = list(string)
}

variable "labels" {
  description = "Common labels to apply to all folder resources (folders do not support labels natively, preserved for documentation)."
  type        = map(string)
  default     = {}
}
