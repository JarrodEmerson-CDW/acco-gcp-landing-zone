# Terraform Deployment Workflow & Troubleshooting

If you are new to Terraform, it's important to understand that this landing zone is broken up into **multiple isolated layers** (located in the `live/` directory). This modularity reduces blast radius, speeds up deployment times, and organizes resources logically.

## The Deployment Order

Resources have dependencies. For example, you cannot create a network in a project if the project doesn't exist yet, and you cannot create a project if its parent folder hasn't been created. 

Because of this, if you are applying changes across multiple layers, you must apply them in this specific order:

1. **`live/org`**
   * What it does: Creates Folders and applies Organization Policies.
   * *Apply this first if you added a new environment, Business Unit, or modified a policy.*
2. **`live/projects`**
   * What it does: Creates the GCP Projects and enables APIs.
   * *Apply this second if you added a new project.*
3. **`live/networking`**
   * What it does: Creates VPCs, Subnets, Peering, DNS, and Firewalls.
   * *Apply this third if you added subnets, attached a project to a Shared VPC, or updated a CIDR range.*
4. **`live/iam`**
   * What it does: Grants user permissions, binds groups to roles, creates log sinks, and sets budgets.
   * *Apply this fourth if you modified user access, added a new group binding, or set up a new log export.*

## How to Deploy a Layer

To deploy changes to a layer, open your terminal and navigate to the directory:

```bash
cd live/<layer_name> # e.g., cd live/projects
```

**1. Initialize Terraform**
You must run this command the first time you enter a directory, or if provider versions/modules have changed. It downloads necessary plugins and connects to the remote state bucket.
```bash
terraform init
```

**2. Review the Plan**
Always review what Terraform is about to do *before* applying. This command shows you the exact additions, modifications, and deletions.
```bash
terraform plan
```
*Look for:* Ensure there are no unexpected `destroy` actions, particularly on resources like VPC networks, subnets, or databases.

**3. Apply the Changes**
If the plan looks correct, execute the apply.
```bash
terraform apply
```
*(You will be prompted to type `yes` to confirm).*

## Common Troubleshooting

* **Error: `Error applying IAM policy... principal not found`**
  * **Cause:** You tried to grant a role to an Entra ID / Workspace group that doesn't exist yet.
  * **Fix:** Create the group in your identity provider, wait a few minutes for it to sync to GCP, and run `terraform apply` again.
* **Error: `Error creating network... project not found`**
  * **Cause:** You are trying to apply the networking layer before applying the projects layer.
  * **Fix:** Run `terraform apply` in `live/projects` first, then return to `live/networking`.
* **State Lock Errors**
  * **Cause:** Terraform crashed or someone else is currently running an apply in the same layer.
  * **Fix:** Wait for the other user to finish. If the state is permanently stuck due to a crash, you may need a senior administrator to manually force-unlock the state using `terraform force-unlock <lock_id>`.
