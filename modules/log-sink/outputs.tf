output "sink_writer_identity" {
  description = "IAM identity of the log sink writer (needed for destination IAM grants)."
  value       = local.sink_writer_identity
}

output "gcs_bucket_name" {
  description = "Name of the GCS log archive bucket."
  value       = google_storage_bucket.logs.name
}

output "pubsub_topic_id" {
  description = "PubSub topic ID (empty if no PubSub configured)."
  value       = local.has_pubsub ? google_pubsub_topic.sink_topic[0].id : ""
}
