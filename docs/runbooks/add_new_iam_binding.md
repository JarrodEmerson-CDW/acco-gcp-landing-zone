# How to Add a New IAM Group Permission

The ACCO landing zone uses a centralized, non-authoritative approach to IAM assignments. This means you can add specific group bindings without fear of overwriting bindings that Google Cloud may require or bindings created by other systems.

## Step 1: Define the Binding in `terraform.tfvars`

All IAM bindings are managed in a single map variable `iam_bindings` within the root `terraform.tfvars`.

1. Open `terraform.tfvars` in the root of the repository.
2. Locate the `iam_bindings` block.
3. Add a new block for your binding. The key is just an arbitrary string to uniquely identify the binding in Terraform state. A good convention is `"<resource_type>/<resource_name>/<group_name>/<role_shortname>"`.

### Examples by Resource Type

**1. Organization-level Binding**
```hcl
iam_bindings = {
  # ... existing bindings ...
  "org/security-admins/scc-admin" = {
    resource_type = "organization"
    resource_id   = "{org_id}" # Replace with actual 12-digit org ID if not using placeholders
    member        = "group:gcp-security-admins@accoes.com"
    role          = "roles/securitycenter.admin"
  }
}
```

**2. Folder-level Binding**
```hcl
iam_bindings = {
  # ... existing bindings ...
  "folder/dv-controls/gcp-dv-controls-admins/owner" = {
    resource_type = "folder"
    resource_id   = "folders/{dv_controls_folder_id}" # Must include "folders/" prefix!
    member        = "group:gcp-dv-controls-admins@accoes.com"
    role          = "roles/owner"
  }
}
```

**3. Project-level Binding**
```hcl
iam_bindings = {
  # ... existing bindings ...
  "project/prj-dv-controls-app1/gcp-dv-controls-app1-users/viewer" = {
    resource_type = "project"
    resource_id   = "{project_id}" # The raw project string (e.g. prj-dv-controls-app1-0982)
    member        = "group:gcp-dv-controls-app1-users@accoes.com"
    role          = "roles/viewer"
  }
}
```

## Step 2: Apply the Changes

Once your changes are saved, apply them from the `live/iam` layer.

```bash
cd live/iam
terraform init
terraform apply
```

> **Requirements:** The group specified in the `member` field (e.g., `group:gcp-security-admins@accoes.com`) must exist in your Entra ID / Google Workspace directory *before* you run `terraform apply`. Terraform will error out if it cannot resolve the principal.
