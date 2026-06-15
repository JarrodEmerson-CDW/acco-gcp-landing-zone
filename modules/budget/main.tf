locals {
  # Flatten threshold alerts: one resource per budget * threshold combination
  threshold_pairs = flatten([
    for budget_name, budget_cfg in var.budgets : [
      for threshold in budget_cfg.alert_thresholds : {
        key         = "${budget_name}/${tostring(threshold)}"
        budget_name = budget_name
        threshold   = threshold
      }
    ]
  ])
}

resource "google_billing_budget" "budgets" {
  for_each = var.budgets

  billing_account = var.billing_account_id
  display_name    = each.key

  budget_filter {
    projects               = length(each.value.project_ids) > 0 ? [for p in each.value.project_ids : "projects/${p}"] : null
    credit_types_treatment = each.value.include_credits ? "INCLUDE_ALL_CREDITS" : "EXCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(floor(each.value.amount_usd))
    }
  }

  # Create one alert_threshold_rule per threshold value
  dynamic "threshold_rules" {
    for_each = each.value.alert_thresholds
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }

  # Percentage of previous month (forecasted spend) threshold
  dynamic "threshold_rules" {
    for_each = each.value.alert_thresholds
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "FORECASTED_SPEND"
    }
  }

  all_updates_rule {
    pubsub_topic                     = each.value.pubsub_topic != "" ? each.value.pubsub_topic : null
    monitoring_notification_channels = each.value.notification_channels
    disable_default_iam_recipients   = false
  }
}
