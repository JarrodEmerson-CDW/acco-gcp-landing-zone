variable "org_id" {
  description = "Google Cloud Organization ID where org policies are applied."
  type        = string
}

variable "boolean_policies" {
  description = <<-EOT
    Map of boolean org policies to apply at the org level.
    Key = constraint name (e.g. "constraints/compute.skipDefaultNetworkCreation").
    - enforced : true to enforce/deny, false to allow.
  EOT
  type = map(object({
    enforced = bool
  }))
  default = {}
}

variable "list_policies" {
  description = <<-EOT
    Map of list org policies to apply at the org level.
    Key = constraint name.
    - allow_all  : if true, policy allows all values (sets allow {all: true}).
    - deny_all   : if true, policy denies all values (sets deny {all: true}).
    - allow_values : list of allowed values (mutually exclusive with deny_all / allow_all).
    - deny_values  : list of denied values.
    At most one of allow_all, deny_all, allow_values, deny_values should be non-empty.
  EOT
  type = map(object({
    allow_all    = optional(bool, false)
    deny_all     = optional(bool, false)
    allow_values = optional(list(string), [])
    deny_values  = optional(list(string), [])
  }))
  default = {}
}

variable "folder_policy_overrides" {
  description = <<-EOT
    Per-folder policy overrides. Key = "<folder_id>/<constraint>".
    - folder_id  : numeric folder ID (just the number)
    - constraint : constraint name
    - enforced   : for boolean policies
    - allow_all / deny_all / allow_values / deny_values : for list policies
    - policy_type : "boolean" | "list"
  EOT
  type = map(object({
    folder_id   = string
    constraint  = string
    policy_type = string
    enforced    = optional(bool, null)
    allow_all   = optional(bool, false)
    deny_all    = optional(bool, false)
    allow_values = optional(list(string), [])
    deny_values  = optional(list(string), [])
  }))
  default = {}
}
