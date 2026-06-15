# ACCO Engineered Systems — Google Cloud Landing Zone

A **modular, variable-driven** Terraform codebase that deploys the ACCO Engineered Systems
Google Cloud landing zone. Every name, CIDR, policy, group, and environment is controlled
by variables — **no structural code changes are ever required** to reconfigure the design.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Directory Structure](#directory-structure)
3. [Prerequisites](#prerequisites)
4. [Bootstrap — First Apply Order](#bootstrap--first-apply-order)
5. [Backend Configuration](#backend-configuration)
6. [How to Extend — tfvars-only changes](#how-to-extend--tfvars-only-changes)
   - [Add an Environment](#add-an-environment)
   - [Add a Business Unit](#add-a-business-unit)
   - [Add an Application Project](#add-an-application-project)
   - [Add a User Group Binding](#add-a-user-group-binding)
   - [Change a CIDR Range](#change-a-cidr-range)
   - [Add an Org Policy](#add-an-org-policy)
   - [Add a Log Sink](#add-a-log-sink)
   - [Add a GitHub Repo to WIF](#add-a-github-repo-to-wif)
7. [IAM Design](#iam-design)
8. [Networking Design](#networking-design)
9. [CIDR Allocations](#cidr-allocations)
10. [Provider Versions](#provider-versions)

---

## Architecture Overview

```
Organization: accoes.com
│
├── dev/                     (code: dv)
│   ├── controls/
│   ├── facilities/
│   ├── construction/
│   ├── engineering/
│   ├── shop/
│   ├── field/
│   ├── operations/
│   ├── administration/
│   └── branch-plants/
├── non-prod/                (code: np)
│   └── <same BU subfolders>
├── prod/                    (code: pd)
│   └── <same BU subfolders>
├── shared-services/         (code: sh)
│   ├── networking/
│   │   ├── prj-dv-network   (Shared VPC host — dev)
│   │   ├── prj-np-network   (Shared VPC host — non-prod)
│   │   ├── prj-pd-network   (Shared VPC host — prod)
│   │   └── prj-sh-interconnect (hub VPC / Dedicated Interconnect)
│   └── infrastructure/
│       ├── prj-dv-logging
│       ├── prj-np-logging
│       ├── prj-pd-logging
│       └── prj-sh-operations
├── bootstrap/               (code: sh)
│   └── cicd/
│       └── prj-sh-cicd      (state bucket, WIF pool, seed SAs)
└── sandbox/                 (code: sb)
```

**Networking (hub-and-spoke):**
- Three Shared VPC host projects (dev, non-prod, prod) peer to the interconnect/hub VPC.
- Spokes do **not** peer with each other — environments are isolated.
- App projects attach to their environment's Shared VPC as service projects.
- Cloud NAT per region, Cloud DNS hub in the interconnect project.

**Identity:**
- Entra ID → Cloud Identity sync. Terraform binds groups, never creates users.
- Group naming: `gcp-<env>-<business-unit>-[<app>]-<admins|users>`

---

## Directory Structure

```
acco-gcp-landing-zone/
├── README.md
├── terraform.tfvars.example       ← Single example file for the full design
├── versions.tf                    ← Shared provider version constraints
│
├── modules/
│   ├── bootstrap/                 ← State bucket, WIF pool, seed SAs
│   ├── budget/                    ← Billing budgets with threshold alerts
│   ├── dns/                       ← Private, peering, and forwarding zones
│   ├── folders/                   ← Org folder hierarchy (for_each driven)
│   ├── iam-bindings/              ← Group→role bindings with optional conditions
│   ├── log-sink/                  ← Sink → PubSub → GCS + optional Splunk
│   ├── org-policies/              ← Org-level and folder-override policies
│   ├── project/                   ← Standardized project factory
│   ├── service-accounts/          ← Custom SAs + WIF bindings (no keys)
│   ├── shared-vpc/                ← Custom VPC, subnets, NAT, firewalls, Shared VPC
│   └── vpc-peering/               ← Bidirectional hub↔spoke peering
│
└── live/
    ├── bootstrap/                 ← Apply first (local state → migrate to GCS)
    ├── org/                       ← Folder hierarchy + org policies
    ├── projects/                  ← All GCP projects (for_each over map)
    ├── networking/                ← VPCs, peering, DNS, NAT
    └── iam/                       ← IAM bindings, SAs, log sinks, budgets
```

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Terraform ≥ 1.5 | Install from https://www.terraform.io/downloads |
| Google Cloud SDK | `gcloud auth application-default login` |
| Org Admin role | Required for folder creation and org policy management |
| Billing Account Admin | Required to link billing to projects |
| A pre-created project for bootstrap | `prj-sh-cicd` must exist before first apply; create via Console or `gcloud` |
| Cloud Identity / Workspace | Groups must exist in Cloud Identity before IAM bindings are applied |
| GitHub OIDC | WIF is configured for GitHub Actions; see `live/bootstrap` |

**Required APIs on the bootstrap project** (enable manually or via `gcloud`):
```bash
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com iamcredentials.googleapis.com \
  sts.googleapis.com storage.googleapis.com \
  --project=prj-sh-cicd
```

---

## Bootstrap — First Apply Order

> **Important:** The bootstrap layer uses **local state** initially because the GCS state
> bucket doesn't exist yet. After the first successful apply, migrate state to GCS.

### Step 1 — Bootstrap (local state)

```bash
cd live/bootstrap
cp ../../terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with real values
terraform init
terraform apply
# Note the output: state_bucket_name
```

### Step 2 — Migrate bootstrap state to GCS

Uncomment the `backend "gcs"` block in `live/bootstrap/versions.tf`, set the bucket name,
then run:

```bash
terraform init -migrate-state
```

### Step 3 — Org (folder hierarchy + org policies)

```bash
cd live/org
terraform init -backend-config="bucket=<state-bucket-name>"
terraform apply
# Note outputs: top_level_folder_ids, bu_subfolder_ids, static_subfolder_ids
```

Update `terraform.tfvars` with the real folder IDs from the outputs above.

### Step 4 — Projects

```bash
cd live/projects
terraform init -backend-config="bucket=<state-bucket-name>"
terraform apply
```

### Step 5 — Networking

```bash
cd live/networking
terraform init -backend-config="bucket=<state-bucket-name>"
terraform apply
```

### Step 6 — IAM

```bash
cd live/iam
terraform init -backend-config="bucket=<state-bucket-name>"
terraform apply
```

---

## Backend Configuration

Each `live/` root has a partial GCS backend:

```hcl
backend "gcs" {
  prefix = "terraform/<layer>"
}
```

Supply the bucket at `init` time:
```bash
terraform init -backend-config="bucket=bkt-acco-tf-state-sh"
```

Or create a `backend.tfbackend` file per layer:
```
bucket = "bkt-acco-tf-state-sh"
```

```bash
terraform init -backend-config=backend.tfbackend
```

---

## How to Extend — tfvars-only changes

### Add an Environment

Add an entry to `top_level_folders` in `live/org/terraform.tfvars`:

```hcl
top_level_folders = {
  # ... existing entries ...
  "staging" = {
    code        = "st"
    has_bu_subs = true
  }
}
```

Then add networking/logging projects for it in `live/projects/terraform.tfvars`:

```hcl
projects = {
  # ... existing entries ...
  "st-network" = {
    env_code  = "st"
    app       = "network"
    folder_id = "folders/<staging_networking_folder_id>"
  }
}
```

Add a spoke VPC in `live/networking/terraform.tfvars`:

```hcl
spoke_vpcs = {
  # ... existing entries ...
  "staging" = {
    host_project_id = "prj-st-network"
    network_name    = "vpc-staging"
    cidr_block      = "10.147.0.0/16"
    subnets = { ... }
    nat_config    = { ... }
    firewall_rules = { ... }
  }
}
```

**No code changes needed.**

---

### Add a Business Unit

Add the name to `business_units` in `live/org/terraform.tfvars`:

```hcl
business_units = [
  # ... existing list ...
  "fire-protection",
]
```

Sub-folders will be created under dev, non-prod, and prod automatically.

---

### Add an Application Project

Add an entry to `projects` in `live/projects/terraform.tfvars`:

```hcl
projects = {
  # ... existing entries ...
  "dv-controls-scheduling" = {
    env_code  = "dv"
    app       = "controls-scheduling"
    folder_id = "folders/<dv_controls_folder_id>"
    additional_apis = ["run.googleapis.com", "bigquery.googleapis.com"]
  }
}
```

To attach it to the Shared VPC, add its project ID to `service_project_ids` in the
relevant `spoke_vpcs` entry in `live/networking/terraform.tfvars`.

---

### Add a User Group Binding

Add an entry to `iam_bindings` in `live/iam/terraform.tfvars`:

```hcl
iam_bindings = {
  # ... existing entries ...
  "project/prj-dv-controls-scheduling/gcp-dv-controls-users/viewer" = {
    resource_type = "project"
    resource_id   = "prj-dv-controls-scheduling"
    member        = "group:gcp-dv-controls-users@accoes.com"
    role          = "roles/viewer"
  }
}
```

Group naming convention: `gcp-<env>-<business-unit>-[<app>]-<admins|users>`

---

### Change a CIDR Range

Subnets are defined in `spoke_vpcs.<env>.subnets.<subnet-name>.ip_cidr_range` in
`live/networking/terraform.tfvars`. Update the value:

```hcl
spoke_vpcs = {
  "dev" = {
    subnets = {
      "sn-dev-primary-usw2" = {
        ip_cidr_range = "10.143.10.0/24"  # changed from /24 slice
        ...
      }
    }
  }
}
```

> ⚠️ Changing a subnet CIDR destroys and recreates the subnet. Drain workloads first.

---

### Add an Org Policy

Add to `boolean_org_policies` or `list_org_policies` in `live/org/terraform.tfvars`:

```hcl
boolean_org_policies = {
  # ... existing entries ...
  "constraints/sql.restrictPublicIp" = { enforced = true }
}
```

For a per-folder exception, add to `folder_policy_overrides`.

---

### Add a Log Sink

Add an entry to `log_sinks` in `live/iam/terraform.tfvars`:

```hcl
log_sinks = {
  # ... existing entries ...
  "sb-sandbox-sink" = {
    sink_project_id  = "prj-sh-operations"
    sink_name        = "sink-sb-org"
    parent_type      = "folder"
    parent_id        = "folders/<sandbox_folder_id>"
    bucket_name      = "bkt-sb-logs-acco"
    pubsub_topic_name = "topic-sb-logs"
  }
}
```

---

### Add a GitHub Repo to WIF

Add an entry to `github_repos` in `live/bootstrap/terraform.tfvars`:

```hcl
github_repos = {
  # ... existing entries ...
  "controls-app" = {
    repo_name   = "AccoEngineeredSystems/controls-app"
    description = "Controls application pipeline"
    sa_roles    = ["roles/editor"]
  }
}
```

A new service account `sa-cicd-controls-app` is created and bound to the WIF pool
scoped to that specific repository.

---

## IAM Design

| Group | Scope | Role(s) |
|-------|-------|---------|
| `gcp-organization-admins` | Org | `roles/resourcemanager.organizationAdmin` |
| `gcp-billing-admins` | Org | `roles/billing.admin` |
| `gcp-sh-network-admins` | Org | `roles/compute.networkAdmin` |
| `gcp-sh-infrastructure-admins` | Org | `roles/viewer` |
| `gcp-dv-admins` | dev folder | `roles/resourcemanager.folderAdmin` |
| `gcp-np-admins` | non-prod folder | `roles/resourcemanager.folderAdmin` |
| `gcp-pd-admins` | prod folder | `roles/resourcemanager.folderAdmin` |
| `gcp-<env>-<bu>-admins` | BU folder | `roles/editor` (configurable) |
| `gcp-<env>-<bu>-<app>-users` | project | added per-app via `iam_bindings` |

- **No primitive roles** (Owner/Editor/Viewer at org level).
- **No SA keys** — Workload Identity Federation for all CI/CD.
- **Optional IAM conditions** supported on any binding via the `condition` block.
- **Per-environment group separation** enforced by design (groups are not shared across envs).

---

## Networking Design

```
prj-sh-interconnect (hub)
    vpc-interconnect
         │
    ┌────┴────┐────────────┐
    ▼         ▼            ▼
vpc-dev   vpc-non-prod  vpc-prod
(prj-dv-  (prj-np-      (prj-pd-
 network)  network)      network)
```

- **Hub-and-spoke** via VPC peering.
- **Non-transitive**: spokes cannot reach each other (no custom route export/import).
- **Shared VPC**: app project teams consume subnets; they do not create VPCs or firewalls.
- **Cloud NAT**: per-region, auto-allocated IPs.
- **Cloud DNS**: hub zone in `prj-sh-interconnect`, peering zones to spokes, optional
  forwarding zones for on-prem / Azure.
- **Private Google Access**: enabled on all subnets by default.
- **Meraki/VPN**: inside, outside, and management subnets defined in `hub_subnets` —
  comment out if not needed.

---

## CIDR Allocations

| Environment | Block |
|-------------|-------|
| sandbox | `10.142.0.0/16` |
| dev | `10.143.0.0/16` |
| non-prod | `10.144.0.0/16` |
| prod | `10.145.0.0/16` |
| interconnect | `10.146.0.0/16` |

Subnets are /24 slices of these /16 blocks, defined in `spoke_vpcs.<env>.subnets`.

---

## Provider Versions

```hcl
google      = "~> 5.40"
google-beta = "~> 5.40"
terraform   = ">= 1.5.0"
```

Pin to a specific patch version in production by updating `versions.tf` in each `live/` layer.
