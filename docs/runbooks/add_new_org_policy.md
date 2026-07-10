# How to Add an Organization Policy or Exception

The ACCO landing zone manages Google Cloud Organization Policies centrally. Because the landing zone uses a centralized deployment model, you apply policies across the organization and can selectively override them for specific folders.

## 1. Adding a New Org-Wide Policy

To apply an organization policy across the entire GCP organization:

1. Open `terraform.tfvars` in the root of the repository.
2. Locate the `boolean_org_policies` or `list_org_policies` section. 
   * Use **boolean** policies for true/false constraints (e.g., skip default network creation).
   * Use **list** policies for constraints that take a list of allowed/denied values (e.g., allowed resource locations).

**Example: Adding a Boolean Policy**
```hcl
boolean_org_policies = {
  # ... existing policies ...
  "constraints/sql.restrictPublicIp" = { enforced = true }
  "constraints/iam.disableServiceAccountKeyCreation" = { enforced = true }
}
```

**Example: Adding a List Policy**
```hcl
list_org_policies = {
  # ... existing policies ...
  "constraints/gcp.resourceLocations" = {
    status = true # true means enforce the list below
    values = ["in:us-locations"]
  }
}
```

3. Apply the changes in the Org layer:
```bash
cd live/org
terraform init
terraform apply
```

## 2. Creating a Policy Exception (Override) for a Specific Folder

Sometimes a specific Business Unit or Environment requires an exception to an organization-wide policy.

1. In `terraform.tfvars`, locate the `folder_policy_overrides` map block.
2. Add a new block for the folder ID where the exception should apply.
3. Define the specific policy constraint you wish to override and set `enforced = false` (for boolean policies) or modify the list values.

```hcl
folder_policy_overrides = {
  # Apply exceptions to the dv-controls folder
  "folders/<dv_controls_folder_id>" = {
    boolean_policies = {
      # Allow Service Account Key creation in this folder only
      "constraints/iam.disableServiceAccountKeyCreation" = { enforced = false }
    }
    list_policies = {}
  }
}
```

4. Apply the changes in the Org layer:
```bash
cd live/org
terraform init
terraform apply
```

> **Tip for Beginners:** Policies propagate downwards. If you apply a policy at the Organization level, it hits all folders and projects. An exception must be explicitly declared on a folder or project to override the upstream inheritance.
