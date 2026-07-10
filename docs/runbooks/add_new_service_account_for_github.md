# How to Add a New Service Account for GitHub Actions Deployment

If you have a separate GitHub repository that needs to deploy application-specific infrastructure to a GCP project, you must create a Service Account (SA) for it. 

The ACCO landing zone utilizes **Workload Identity Federation (WIF)**, meaning you never generate or download long-lived Service Account keys. Instead, you grant a specific GitHub repository the ability to impersonate the Service Account temporarily.

## Step 1: Find the CI/CD Project Number

Workload Identity Pools are hosted in your centralized CI/CD project (typically `prj-sh-cicd`). You need the **numeric Project Number** of this project to construct the WIF impersonation string.

To find it, run this command in your terminal (replacing `prj-sh-cicd-1234` with your actual CI/CD project ID):
```bash
gcloud projects describe prj-sh-cicd-1234 --format="value(projectNumber)"
```

## Step 2: Define the Service Account

Service accounts are managed in the `service_accounts` block within the root `terraform.tfvars` file.

1. Open `terraform.tfvars` at the root of the repository.
2. Locate the `service_accounts` map block.
3. Add a new block for the Service Account. 

```hcl
service_accounts = {
  # ... existing SAs ...

  "sa-app1-pipeline" = {
    # 1. Target Project (Where the SA is created and granted roles)
    project_id    = "prj-dv-controls-app1" # Replace with your target app project ID
    
    # 2. General Information
    display_name  = "App1 GitHub Actions SA"
    description   = "Used by the external App1 GitHub repo to deploy its own infrastructure"
    
    # 3. Project-Level Permissions
    # Grant this SA 'Owner' over the project so it can deploy anything inside it
    project_roles = ["roles/owner"]
    
    # 4. Impersonation Rights (Workload Identity Federation)
    iam_bindings  = {
      # Replace <CICD_PROJECT_NUMBER> with the number from Step 1
      # Replace <GITHUB_ORG>/<GITHUB_REPO> with the exact name of the GitHub repository
      "principalSet://iam.googleapis.com/projects/<CICD_PROJECT_NUMBER>/locations/global/workloadIdentityPools/github-pool/attribute.repository/accoes/controls-app1" = [
        "roles/iam.workloadIdentityUser"
      ]
    }
  }
}
```

## Step 3: Apply the Changes

Because Service Accounts and IAM bindings are identity resources, they are managed in the `iam` layer.

1. Navigate to the IAM directory:
```bash
cd live/iam
```
2. Initialize and apply:
```bash
terraform init
terraform apply
```

## Step 4: Configure GitHub Actions

Once Terraform finishes, the Service Account is ready to be used by GitHub Actions in the external repository.

In the external repository's `.github/workflows/deploy.yml`, you will use the `google-github-actions/auth` action. Provide it with the Workload Identity Provider name and the email address of the newly created Service Account.

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: 'read'
      id-token: 'write' # Required for Workload Identity

    steps:
    - uses: actions/checkout@v4

    - id: 'auth'
      name: 'Authenticate to Google Cloud'
      uses: 'google-github-actions/auth@v2'
      with:
        # e.g., projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider
        workload_identity_provider: 'projects/<CICD_PROJECT_NUMBER>/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
        service_account: 'sa-app1-pipeline@prj-dv-controls-app1.iam.gserviceaccount.com'

    # Proceed with gcloud or terraform steps...
```
