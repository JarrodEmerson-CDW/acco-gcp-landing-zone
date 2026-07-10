# How to Manage Log Sinks

Log sinks in Google Cloud route your Cloud Logging data to a destination such as a Cloud Storage bucket, Pub/Sub topic (for Splunk ingestion), or BigQuery. The ACCO landing zone manages these sinks centrally to ensure security and compliance logs are consistently captured.

## Adding a New Log Sink

Log sinks are defined in `terraform.tfvars` and deployed through the `live/iam` layer.

1. Open `terraform.tfvars` at the root of the repository.
2. Locate the `log_sinks` map block.
3. Add a new block for your log sink. You must define where the sink lives (e.g., at the Organization, Folder, or Project level) and where the logs should be routed.

```hcl
log_sinks = {
  # ... existing sinks ...

  "my-new-audit-sink" = {
    # 1. Destination Configuration
    # The project that owns the destination Storage Bucket and/or PubSub topic
    sink_project_id  = "prj-sh-operations-0982" 
    
    # 2. Sink Naming
    sink_name        = "sink-audit-events"
    
    # 3. Source Configuration (Where is the sink capturing logs from?)
    # Valid types: "organization", "folder", or "project"
    parent_type      = "folder"
    parent_id        = "folders/<target_folder_id>"
    
    # 4. Storage Destinations (Create the bucket/topic if defined)
    bucket_name       = "bkt-audit-logs-acco"
    pubsub_topic_name = "topic-audit-export"
  }
}
```

## Applying the Sink

Because log sinks involve permissions and logging resources, they are managed in the IAM layer.

1. Navigate to the IAM directory:
```bash
cd live/iam
```
2. Initialize and apply:
```bash
terraform init
terraform apply
```

> **What happens under the hood:** 
> When you create a log sink using this module, Terraform automatically creates a unique Google-managed Service Account for the sink (the "writer identity"). It then automatically grants that identity the `roles/storage.objectCreator` role on the destination bucket and the `roles/pubsub.publisher` role on the topic so the logs can flow successfully without manual IAM intervention.
