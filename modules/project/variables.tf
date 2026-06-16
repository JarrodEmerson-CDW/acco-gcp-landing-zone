variable "project_id" {
  description = "Explicit project ID. If empty, it is derived from the naming template."
  type        = string
  default     = ""
}

variable "project_name_template" {
  description = <<-EOT
    Go-template-style naming pattern for projects.
    Tokens replaced: {env} {app}
    Example: "prj-{env}-{app}"
  EOT
  type        = string
  default     = "prj-{env}-{app}"
}

variable "env_code" {
  description = "Short environment code (dv, np, pd, sh, sb)."
  type        = string
}

variable "app" {
  description = "Application / workload short name used in the project ID."
  type        = string
}

variable "folder_id" {
  description = "Folder resource ID (folders/<number>) that parents this project."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID to associate with the project."
  type        = string
}

variable "apis" {
  description = "List of Google API service names to enable on the project."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to the project."
  type        = map(string)
  default     = {}
}

variable "auto_create_network" {
  description = "Whether to auto-create the default network. Should be false for all projects."
  type        = bool
  default     = false
}

variable "skip_delete" {
  description = "If true, Terraform will not destroy the project on terraform destroy."
  type        = bool
  default     = false
}

variable "project_suffix" {
  description = "Suffix appended to the project ID to ensure uniqueness."
  type        = string
  default     = ""
}

