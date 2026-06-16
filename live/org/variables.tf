variable "org_id" {
  description = "Google Cloud Organization ID (numeric string)."
  type        = string
}

variable "billing_project" {
  description = "Project ID used for billing when making org-level API calls."
  type        = string
}

variable "top_level_folders" {
  description = <<-EOT
    Top-level folder definitions.
    Key = folder display name.
    - code        : short env code
    - has_bu_subs : whether business-unit sub-folders are created inside
  EOT
  type = map(object({
    code        = string
    has_bu_subs = bool
  }))
}

variable "shared_subfolders" {
  description = "Static sub-folders (networking, infrastructure, cicd). Key = 'parent/child'."
  type        = map(string)
  default     = {}
}

variable "business_units" {
  description = "List of business-unit names to create under env folders."
  type        = list(string)
}

variable "boolean_org_policies" {
  description = "Boolean org-level policies. Key = constraint name."
  type = map(object({
    enforced = bool
  }))
  default = {}
}

variable "list_org_policies" {
  description = "List org-level policies. Key = constraint name."
  type = map(object({
    allow_all    = optional(bool, false)
    deny_all     = optional(bool, false)
    allow_values = optional(list(string), [])
    deny_values  = optional(list(string), [])
  }))
  default = {}
}

variable "folder_policy_overrides" {
  description = "Per-folder policy overrides. See org-policies module for schema."
  type = map(object({
    folder_id    = string
    constraint   = string
    policy_type  = string
    enforced     = optional(bool, null)
    allow_all    = optional(bool, false)
    deny_all     = optional(bool, false)
    allow_values = optional(list(string), [])
    deny_values  = optional(list(string), [])
  }))
  default = {}
}

variable "labels" {
  description = "Common resource labels."
  type        = map(string)
  default     = {}
}
