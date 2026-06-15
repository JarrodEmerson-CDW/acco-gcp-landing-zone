locals {
  has_pubsub      = var.pubsub_topic_name != ""
  has_splunk      = var.splunk_subscription_name != "" && var.splunk_push_endpoint != ""

  # Sink destination: PubSub when configured, else GCS directly
  sink_destination = local.has_pubsub ? (
    "pubsub.googleapis.com/projects/${var.sink_project_id}/topics/${var.pubsub_topic_name}"
  ) : (
    "storage.googleapis.com/${var.bucket_name}"
  )
}

# ─── PubSub Topic (when used as sink intermediary) ────────────────────────────
resource "google_pubsub_topic" "sink_topic" {
  count = local.has_pubsub ? 1 : 0

  project = var.sink_project_id
  name    = var.pubsub_topic_name
  labels  = var.labels
}

# ─── Optional Splunk push subscription ───────────────────────────────────────
resource "google_pubsub_subscription" "splunk" {
  count = local.has_splunk ? 1 : 0

  project = var.sink_project_id
  name    = var.splunk_subscription_name
  topic   = google_pubsub_topic.sink_topic[0].name

  push_config {
    push_endpoint = var.splunk_push_endpoint
  }

  # Retain messages for 7 days to handle Splunk outages
  message_retention_duration = "604800s"
  retain_acked_messages      = false

  depends_on = [google_pubsub_topic.sink_topic]
}

# ─── GCS Bucket (log archive) ─────────────────────────────────────────────────
resource "google_storage_bucket" "logs" {
  project                     = var.sink_project_id
  name                        = var.bucket_name
  location                    = var.bucket_location
  uniform_bucket_level_access = true # enforced by org policy; also set explicitly

  labels = var.labels

  lifecycle_rule {
    condition {
      age = var.nearline_age_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.archive_age_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.retention_days
    }
    action {
      type = "Delete"
    }
  }

  retention_policy {
    retention_period = var.audit_retention_days * 86400
    is_locked        = false
  }
}

# ─── Log Sink ─────────────────────────────────────────────────────────────────
resource "google_logging_organization_sink" "org_sink" {
  count = var.parent_type == "organization" ? 1 : 0

  name             = var.sink_name
  org_id           = var.parent_id
  destination      = local.sink_destination
  filter           = var.filter
  include_children = var.include_children
}

resource "google_logging_folder_sink" "folder_sink" {
  count = var.parent_type == "folder" ? 1 : 0

  name             = var.sink_name
  folder           = var.parent_id
  destination      = local.sink_destination
  filter           = var.filter
  include_children = var.include_children
}

resource "google_logging_project_sink" "project_sink" {
  count = var.parent_type == "project" ? 1 : 0

  name                   = var.sink_name
  project                = var.parent_id
  destination            = local.sink_destination
  filter                 = var.filter
  unique_writer_identity = true
}

locals {
  # Extract the sink writer identity regardless of sink type
  sink_writer_identity = try(
    google_logging_organization_sink.org_sink[0].writer_identity,
    try(
      google_logging_folder_sink.folder_sink[0].writer_identity,
      try(google_logging_project_sink.project_sink[0].writer_identity, "")
    )
  )
}

# ─── Grant sink writer access to the GCS bucket ───────────────────────────────
resource "google_storage_bucket_iam_member" "sink_writer_gcs" {
  count = local.sink_destination == "storage.googleapis.com/${var.bucket_name}" && local.sink_writer_identity != "" ? 1 : 0

  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = local.sink_writer_identity
}

# ─── Grant sink writer access to PubSub topic ─────────────────────────────────
resource "google_pubsub_topic_iam_member" "sink_writer_pubsub" {
  count = local.has_pubsub && local.sink_writer_identity != "" ? 1 : 0

  project = var.sink_project_id
  topic   = google_pubsub_topic.sink_topic[0].name
  role    = "roles/pubsub.publisher"
  member  = local.sink_writer_identity

  depends_on = [google_pubsub_topic.sink_topic]
}

# ─── If PubSub is used, subscribe GCS to the topic as well (GCS pull) ─────────
resource "google_pubsub_subscription" "gcs_subscription" {
  count = local.has_pubsub ? 1 : 0

  project = var.sink_project_id
  name    = "${var.pubsub_topic_name}-gcs-sub"
  topic   = google_pubsub_topic.sink_topic[0].name

  # Retain unacked messages for 7 days
  message_retention_duration = "604800s"
  retain_acked_messages      = false
  ack_deadline_seconds       = 600

  depends_on = [google_pubsub_topic.sink_topic]
}
