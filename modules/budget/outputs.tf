output "budget_names" {
  description = "Map of budget display name -> budget resource name."
  value       = { for k, v in google_billing_budget.budgets : k => v.name }
}
