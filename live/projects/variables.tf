variable "billing_account_id" {
  description = "Billing account ID."
  type        = string
}

variable "billing_project" {
  description = "Project ID used for quota/billing when making API calls."
  type        = string
}

variable "project_name_template" {
  description = "Naming template for projects. Tokens: {env} {app}."
  type        = string
  default     = "prj-{env}-{app}"
}

variable "default_project_apis" {
  description = "APIs enabled on every project by default."
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "compute.googleapis.com",
  ]
}

variable "projects" {
  description = <<-EOT
    Map of projects to create.
    Key = logical project key (used for output referencing).
    - env_code       : environment short code (dv, np, pd, sh, sb)
    - app            : application/workload short name
    - folder_id      : parent folder resource ID (folders/<N>)
    - additional_apis: extra APIs to enable beyond default_project_apis
    - labels         : project-specific labels merged with common labels
    - skip_delete    : prevent Terraform from destroying the project
  EOT
  type = map(object({
    env_code        = string
    app             = string
    folder_id       = string
    additional_apis = optional(list(string), [])
    labels          = optional(map(string), {})
    skip_delete     = optional(bool, false)
  }))
}

variable "labels" {
  description = "Common labels applied to all projects."
  type        = map(string)
  default     = {}
}

variable "project_suffix" {
  description = "Suffix appended to the project ID to ensure uniqueness."
  type        = string
  default     = ""
}

