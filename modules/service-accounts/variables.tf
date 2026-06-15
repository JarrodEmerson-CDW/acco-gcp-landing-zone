variable "project_id" {
  description = "Project ID where service accounts are created."
  type        = string
}

variable "service_accounts" {
  description = <<-EOT
    Map of service accounts to create.
    Key = SA account_id (short name, not full email).
    - display_name    : human-readable name
    - description     : SA description
    - project_roles   : list of roles granted to the SA on its own project
    - iam_bindings    : map of "<member>" -> list of roles; grants external entities
                        the ability to use/impersonate this SA.
  EOT
  type = map(object({
    display_name  = string
    description   = optional(string, "")
    project_roles = optional(list(string), [])
    iam_bindings = optional(map(list(string)), {})
  }))
  default = {}
}

variable "labels" {
  description = "Labels to apply to service accounts (not supported natively; for documentation)."
  type        = map(string)
  default     = {}
}
