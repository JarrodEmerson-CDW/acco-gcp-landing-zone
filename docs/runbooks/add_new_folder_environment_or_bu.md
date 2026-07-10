# How to Add a New Folder (Environment or Business Unit)

The ACCO landing zone is designed to be fully configuration-driven. You never need to write `.tf` code to create new folders. All folder structures are generated dynamically based on the configuration in `terraform.tfvars`.

## 1. Adding a New Top-Level Environment Folder

If you need to create a new top-level environment (e.g., `staging`), follow these steps:

1. Open `terraform.tfvars` in the root of the repository.
2. Locate the `top_level_folders` block.
3. Add a new entry for the environment. Give it a short `code` and specify whether it should automatically generate Business Unit (BU) subfolders (`has_bu_subs = true`).

```hcl
top_level_folders = {
  # ... existing entries ...
  "staging" = {
    code        = "st"
    has_bu_subs = true
  }
}
```

4. Apply the changes in the Org layer:
```bash
cd live/org
terraform init
terraform apply
```

> **Note:** If you add an environment, you will likely also want to create networking and logging projects for it, followed by a new spoke VPC. Refer to the "Add a New Project" and "Manage Subnets" guides.

## 2. Adding a New Business Unit (BU) Folder

Business Unit folders are repeated automatically under all environments where `has_bu_subs = true` (e.g., `dv`, `np`, `pd`).

1. Open `terraform.tfvars` in the root of the repository.
2. Locate the `business_units` list block.
3. Append the name of the new business unit to the list:

```hcl
business_units = [
  "controls",
  "facilities",
  "construction",
  "engineering",
  "shop",
  "field",
  "operations",
  "administration",
  "branch-plants",
  "new-business-unit", # <--- Add the new BU here
]
```

4. Apply the changes in the Org layer:
```bash
cd live/org
terraform init
terraform apply
```

This will automatically create `dv/new-business-unit`, `np/new-business-unit`, and `pd/new-business-unit` folders.

## 3. After Creating Folders

When you create new folders, Terraform will output their specific Folder IDs (e.g., `folders/123456789`). You must collect these IDs if you intend to:
* Assign IAM permissions on these folders (see the IAM binding guide).
* Deploy specific application projects into these folders.
