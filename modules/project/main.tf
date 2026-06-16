locals {
  # Derive project ID from naming template if not explicitly provided
  _project_id = var.project_id != "" ? var.project_id : replace(
    replace(var.project_name_template, "{env}", var.env_code),
    "{app}", var.app
  )
}

resource "google_project" "this" {
  name                = local._project_id
  project_id          = local._project_id
  folder_id           = replace(var.folder_id, "folders/", "")
  billing_account     = var.billing_account_id
  auto_create_network = var.auto_create_network
  deletion_policy     = var.skip_delete ? "ABANDON" : "DELETE"

  labels = var.labels
}

# Enable requested APIs (sequential to avoid quota bursting issues)
resource "google_project_service" "apis" {
  for_each = toset(var.apis)

  project                    = google_project.this.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false

  depends_on = [google_project.this]
}
