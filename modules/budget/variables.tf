variable "billing_account_id" {
  description = "Billing account ID to create budgets against."
  type        = string
}

variable "budgets" {
  description = <<-EOT
    Map of billing budgets to create.
    Key = budget display name.
    - amount_usd         : fixed budget amount in USD
    - project_ids        : list of project IDs to scope the budget (empty = entire billing account)
    - alert_thresholds   : list of threshold fractions (e.g. [0.5, 0.75, 0.9, 1.0])
    - include_credits    : whether to include credits in cost basis
    - notification_channels : list of notification channel resource IDs (for alerting)
    - pubsub_topic       : optional PubSub topic for programmatic alerting
  EOT
  type = map(object({
    amount_usd           = number
    project_ids          = optional(list(string), [])
    alert_thresholds     = optional(list(number), [0.5, 0.75, 0.9, 1.0])
    include_credits      = optional(bool, false)
    notification_channels = optional(list(string), [])
    pubsub_topic         = optional(string, "")
  }))
  default = {}
}
