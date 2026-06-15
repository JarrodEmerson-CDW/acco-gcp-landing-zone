variable "project_id" {
  description = "Project ID of the CICD/bootstrap project (prj-sh-cicd)."
  type        = string
}

variable "state_bucket_name" {
  description = "Name of the GCS bucket to store Terraform remote state."
  type        = string
}

variable "state_bucket_location" {
  description = "GCS location for the Terraform state bucket."
  type        = string
  default     = "US"
}

variable "state_bucket_versioning" {
  description = "Enable object versioning on the state bucket."
  type        = bool
  default     = true
}

variable "github_org" {
  description = "GitHub organization name for Workload Identity Federation (e.g. 'AccoEngineeredSystems')."
  type        = string
}

variable "github_repos" {
  description = <<-EOT
    Map of GitHub repositories that get a dedicated WIF-bound service account.
    Key = short repo name used as SA account_id suffix.
    - repo_name    : full GitHub repo name (org/repo)
    - sa_roles     : list of roles granted to the SA at org/project level
    - description  : SA description
  EOT
  type = map(object({
    repo_name   = string
    sa_roles    = optional(list(string), [])
    description = optional(string, "")
  }))
}

variable "wif_pool_id" {
  description = "Workload Identity Pool ID (must be 4-32 chars, alphanumeric + hyphens)."
  type        = string
  default     = "github-wif-pool"
}

variable "wif_provider_id" {
  description = "Workload Identity Provider ID within the pool."
  type        = string
  default     = "github-oidc-provider"
}

variable "seed_service_accounts" {
  description = <<-EOT
    Additional seed service accounts beyond WIF accounts (e.g. for Terraform org-level SA).
    Key = account_id. Values same as service-accounts module input.
  EOT
  type = map(object({
    display_name  = string
    description   = optional(string, "")
    project_roles = optional(list(string), [])
  }))
  default = {}
}

variable "labels" {
  description = "Labels to apply to bootstrap resources."
  type        = map(string)
  default     = {}
}
