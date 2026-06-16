variable "billing_account_id" {
  description = "Billing account ID."
  type        = string
}

variable "billing_project" {
  description = "Project ID used for quota/billing when making API calls."
  type        = string
}

variable "iam_bindings" {
  description = <<-EOT
    All IAM bindings (org, folder, project level).
    Key = unique binding label. See iam-bindings module for full schema.
    Add USER group bindings here — empty by default, no code changes required.
  EOT
  type = map(object({
    resource_type = string
    resource_id   = string
    member        = string
    role          = string
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}

variable "service_accounts" {
  description = "Service accounts to create in the CICD project. See service-accounts module."
  type = map(object({
    project_id    = string
    display_name  = string
    description   = optional(string, "")
    project_roles = optional(list(string), [])
    iam_bindings  = optional(map(list(string)), {})
  }))
  default = {}
}

variable "log_sinks" {
  description = <<-EOT
    Map of log sinks to create. Key = sink logical name.
    All fields pass through to the log-sink module.
  EOT
  type = map(object({
    sink_project_id          = string
    sink_name                = string
    parent_type              = optional(string, "organization")
    parent_id                = string
    filter                   = optional(string, "")
    include_children         = optional(bool, true)
    bucket_name              = string
    bucket_location          = optional(string, "US")
    retention_days           = optional(number, 30)
    audit_retention_days     = optional(number, 400)
    nearline_age_days        = optional(number, 30)
    archive_age_days         = optional(number, 90)
    pubsub_topic_name        = optional(string, "")
    splunk_subscription_name = optional(string, "")
    splunk_push_endpoint     = optional(string, "")
    labels                   = optional(map(string), {})
  }))
  default = {}
}

variable "budgets" {
  description = "Billing budgets. See budget module for schema."
  type = map(object({
    amount_usd             = optional(number, 0)
    use_last_period_amount = optional(bool, false)
    project_ids            = optional(list(string), [])
    alert_thresholds       = optional(list(number), [0.5, 0.75, 0.9, 1.0])
    include_credits        = optional(bool, false)
    notification_channels  = optional(list(string), [])
    pubsub_topic           = optional(string, "")
  }))
  default = {}
}

variable "labels" {
  description = "Common labels."
  type        = map(string)
  default     = {}
}

variable "project_suffix" {
  description = "Suffix appended to project IDs to ensure uniqueness."
  type        = string
  default     = ""
}

