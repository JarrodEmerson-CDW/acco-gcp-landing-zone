variable "sink_project_id" {
  description = "Project ID that hosts the log sink (logging project)."
  type        = string
}

variable "sink_name" {
  description = "Name of the logging sink resource."
  type        = string
}

variable "parent_type" {
  description = "Resource type that owns the sink: 'organization' | 'folder' | 'project' | 'billing_account'."
  type        = string
  default     = "organization"
}

variable "parent_id" {
  description = "ID of the parent resource (org ID, folder ID, project ID, or billing account ID)."
  type        = string
}

variable "filter" {
  description = "Logging filter expression. Empty string captures all logs."
  type        = string
  default     = ""
}

variable "include_children" {
  description = "If true (only valid for org/folder sinks), include logs from child resources."
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Name of the GCS bucket to create as the sink destination."
  type        = string
}

variable "bucket_location" {
  description = "GCS bucket location."
  type        = string
  default     = "US"
}

variable "retention_days" {
  description = "Standard log retention period in days."
  type        = number
  default     = 30
}

variable "audit_retention_days" {
  description = "Retention period for admin/audit logs."
  type        = number
  default     = 400
}

variable "nearline_age_days" {
  description = "Age in days at which objects transition to nearline storage."
  type        = number
  default     = 30
}

variable "archive_age_days" {
  description = "Age in days at which objects transition to archive storage."
  type        = number
  default     = 90
}

variable "pubsub_topic_name" {
  description = "Name of the PubSub topic that the sink writes to (intermediate fan-out)."
  type        = string
  default     = ""
}

variable "splunk_subscription_name" {
  description = "If non-empty, creates a PubSub push subscription targeting the Splunk HEC endpoint."
  type        = string
  default     = ""
}

variable "splunk_push_endpoint" {
  description = "Splunk HEC HTTPS endpoint URL for PubSub push subscription."
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to log sink resources."
  type        = map(string)
  default     = {}
}
