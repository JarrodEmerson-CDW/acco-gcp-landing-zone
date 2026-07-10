# How to Add a New Application Project

Projects in the ACCO landing zone are defined entirely via configuration. No raw Terraform resources need to be written to spin up a new standardized project.

## Step 1: Define the Project in `terraform.tfvars`

1. Open `terraform.tfvars` at the root of the repository.
2. Locate the `projects` map block.
3. Add a new block for your project. The key of the block will be used to construct the final project ID (it will automatically get the `project_suffix` appended, e.g., `-0982`).

```hcl
projects = {
  # ... existing projects ...

  "dv-controls-app1" = {
    env_code  = "dv"
    app       = "controls-app1"
    folder_id = "folders/<dv_controls_folder_id>" # Replace with the actual numeric folder ID
    
    # Optional: Automatically enable specific APIs upon creation
    additional_apis = [
      "run.googleapis.com", 
      "bigquery.googleapis.com"
    ]
  }
}
```

## Step 2: (Optional) Attach the Project to a Shared VPC

If the new project needs to consume subnets from its environment's Shared VPC (e.g., the `dv` Shared VPC), you must register it as a service project.

1. In `terraform.tfvars`, locate the `spoke_vpcs` map block.
2. Find the environment that matches the project (e.g., `"dev"`).
3. Add your new project ID (including the suffix) to the `service_project_ids` list.

```hcl
spoke_vpcs = {
  "dev" = {
    host_project_id = "prj-dv-network-0982"
    network_name    = "vpc-dev"
    cidr_block      = "10.143.0.0/16"
    
    # Add your project here so it can consume dev subnets
    service_project_ids = [
      "prj-dv-controls-app1-0982"
    ]
    # ... subnets config ...
  }
}
```

## Step 3: Apply the Changes

To provision the project and (if applicable) attach it to the Shared VPC, run Terraform in the respective layers.

1. **Deploy the project:**
```bash
cd live/projects
terraform init
terraform apply
```

2. **Attach it to the Shared VPC (if applicable):**
```bash
cd live/networking
terraform init
terraform apply
```
