variable "org_id" {
  description = "Google Cloud Organization ID."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID."
  type        = string
}

variable "cicd_project_id" {
  description = "Pre-created project ID for the CICD/bootstrap project (prj-sh-cicd). Must exist before bootstrap apply."
  type        = string
}

variable "cicd_folder_id" {
  description = "Folder ID (folders/<N>) under which the bootstrap project lives."
  type        = string
}


variable "github_org" {
  description = "GitHub organization name."
  type        = string
}

variable "github_repos" {
  description = "GitHub repos granted WIF access. See bootstrap module for schema."
  type = map(object({
    repo_name   = string
    sa_roles    = optional(list(string), [])
    description = optional(string, "")
  }))
}

variable "wif_pool_id" {
  description = "WIF pool ID."
  type        = string
  default     = "github-wif-pool"
}

variable "wif_provider_id" {
  description = "WIF OIDC provider ID."
  type        = string
  default     = "github-oidc-provider"
}

variable "seed_service_accounts" {
  description = "Seed service accounts (beyond WIF CICD SAs)."
  type = map(object({
    display_name  = string
    description   = optional(string, "")
    project_roles = optional(list(string), [])
  }))
  default = {}
}

variable "labels" {
  description = "Common labels."
  type        = map(string)
  default     = {}
}
