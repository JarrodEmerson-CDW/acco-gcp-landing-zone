# =============================================================================
# ACCO Engineered Systems — GCP Landing Zone
# terraform.tfvars.example
#
# This file documents every configurable value. Copy it to terraform.tfvars
# (or use -var-file) and fill in real values. No structural code changes
# are required to add environments, BUs, CIDRs, groups, or policies.
#
# APPLY ORDER:
#   1. live/bootstrap
#   2. live/org
#   3. live/projects
#   4. live/networking
#   5. live/iam
# =============================================================================

# =============================================================================
# GLOBAL IDENTIFIERS
# =============================================================================

org_id             = "80203213781"         # numeric Google Cloud Org ID
billing_account_id = "018112-5645D3-F1B84F" # CDW-managed billing account
billing_project    = "prj-sh-cicd"          # used for API quota
project_suffix     = "3781"                 # appended to project IDs to ensure uniqueness



# =============================================================================
# live/org — folder hierarchy
# =============================================================================

top_level_folders = {
  "dv" = {
    code        = "dv"
    has_bu_subs = true
  }
  "np" = {
    code        = "np"
    has_bu_subs = true
  }
  "pd" = {
    code        = "pd"
    has_bu_subs = true
  }
  "sh" = {
    code        = "sh"
    has_bu_subs = false
  }
  "sb" = {
    code        = "sb"
    has_bu_subs = false
  }
}

# Sub-folders under non-BU top-level folders.
# Key format: "<parent display name>/<child display name>"
shared_subfolders = {
  "sh/networking"     = "sh-networking"
  "sh/infrastructure" = "sh-infrastructure"
}

# Business units repeated under dev / non-prod / prod
business_units = [
  "controls",
  "facilities",
  "construction",
  "engineering",
  "shop",
  "field",
  "operations",
  "administration",
]

# =============================================================================
# live/org — org policies
# =============================================================================

boolean_org_policies = {
  "constraints/compute.skipDefaultNetworkCreation" = { enforced = true }
  "constraints/storage.uniformBucketLevelAccess"   = { enforced = true }
}

list_org_policies = {
  # Deny all external IPs on VMs
  "constraints/compute.vmExternalIpAccess" = {
    deny_all     = true
    allow_all    = false
    allow_values = []
    deny_values  = []
  }
  # Domain-restricted sharing: only accoes.com identities
  #  "constraints/iam.allowedPolicyMemberDomains" = {
  #    allow_all    = false
  #    deny_all     = false
  #    allow_values = ["accoes.com"]
  #    deny_values  = []
  #  }
}

# Per-folder overrides — fill in folder IDs after live/org apply
# Example: allow a sandbox project to have external IPs
folder_policy_overrides = {
  # "sandbox/vmExternalIpAccess" = {
  #   folder_id   = "<sandbox_folder_id>"  # numeric ID of the sandbox folder
  #   constraint  = "constraints/compute.vmExternalIpAccess"
  #   policy_type = "list"
  #   allow_all   = true
  # }
}

# =============================================================================
# live/projects
# =============================================================================

project_name_template = "prj-{env}-{app}"

default_project_apis = [
  "cloudresourcemanager.googleapis.com",
  "iam.googleapis.com",
  "serviceusage.googleapis.com",
  "logging.googleapis.com",
  "monitoring.googleapis.com",
  "compute.googleapis.com",
]

# Replace <folder_id_*> values with actual folder IDs from live/org outputs.
projects = {
  # ── Networking projects ───────────────────────────────────────────────────
  "dv-network" = {
    env_code  = "dv"
    app       = "network"
    folder_id = "folders/<sh_networking_folder_id>"
    additional_apis = [
      "dns.googleapis.com",
      "networkmanagement.googleapis.com",
    ]
  }
  "np-network" = {
    env_code  = "np"
    app       = "network"
    folder_id = "folders/<sh_networking_folder_id>"
    additional_apis = [
      "dns.googleapis.com",
      "networkmanagement.googleapis.com",
    ]
  }
  "prd-network" = {
    env_code  = "prd"
    app       = "network"
    folder_id = "folders/<sh_networking_folder_id>"
    additional_apis = [
      "dns.googleapis.com",
      "networkmanagement.googleapis.com",
    ]
    skip_delete = true
  }
  "sh-interconnect" = {
    env_code  = "sh"
    app       = "interconnect"
    folder_id = "folders/<sh_networking_folder_id>"
    additional_apis = [
      "dns.googleapis.com",
      "networkmanagement.googleapis.com",
    ]
  }

  # ── Logging / monitoring projects ─────────────────────────────────────────
  "dv-log-mon" = {
    env_code  = "dv"
    app       = "log-mon"
    folder_id = "folders/<sh_infrastructure_folder_id>"
    additional_apis = [
      "pubsub.googleapis.com",
      "storage.googleapis.com",
    ]
  }
  "np-log-mon" = {
    env_code  = "np"
    app       = "log-mon"
    folder_id = "folders/<sh_infrastructure_folder_id>"
    additional_apis = [
      "pubsub.googleapis.com",
      "storage.googleapis.com",
    ]
  }
  "prd-log-mon" = {
    env_code  = "prd"
    app       = "log-mon"
    folder_id = "folders/<sh_infrastructure_folder_id>"
    additional_apis = [
      "pubsub.googleapis.com",
      "storage.googleapis.com",
    ]
    skip_delete = true
  }
  "sh-operations" = {
    env_code  = "sh"
    app       = "operations"
    folder_id = "folders/<sh_infrastructure_folder_id>"
    additional_apis = [
      "monitoring.googleapis.com",
      "cloudtrace.googleapis.com",
    ]
  }

  # ── To add a new project: add an entry here. No code changes needed. ──────
  # "dv-controls-app1" = {
  #   env_code  = "dv"
  #   app       = "controls-app1"
  #   folder_id = "folders/<dv_controls_folder_id>"
  # }
}

# =============================================================================
# live/networking
# =============================================================================

# ── Hub (interconnect) VPC ────────────────────────────────────────────────────
hub_project_id   = "prj-sh-interconnect"
hub_network_name = "vpc-interconnect"

hub_subnets = {
  # Primary interconnect subnet — us-west1 (TDD: 10.146.0.0/27)
  "interconnect-subnet-us-west1" = {
    ip_cidr_range = "10.146.0.0/27"
    region        = "us-west1"
    description   = "Primary interconnect subnet us-west1"
  }
  # Secondary interconnect subnet — us-central1 (TDD: 10.146.0.32/27)
  "interconnect-subnet-us-central1" = {
    ip_cidr_range = "10.146.0.32/27"
    region        = "us-central1"
    description   = "Secondary interconnect subnet us-central1"
  }
}

hub_nat_config = {
  "us-west1" = {
    nat_ip_allocate_option = "AUTO_ONLY"
    log_config_enable      = false
  }
  "us-central1" = {
    nat_ip_allocate_option = "AUTO_ONLY"
    log_config_enable      = false
  }
}

hub_firewall_rules = {
  "fw-interconnect-allow-iap-ingress" = {
    direction   = "INGRESS"
    priority    = 1000
    ranges      = ["35.235.240.0/20"]
    allow       = [{ protocol = "tcp", ports = ["22", "3389"] }]
    description = "Allow IAP for SSH/RDP"
  }
}

# ── Spoke VPCs (dev, non-prod, prod) ─────────────────────────────────────────
# CIDR allocations per environment (10.14x.0.0/16):
#   sandbox      = 10.142.0.0/16
#   dev          = 10.143.0.0/16
#   non-prod     = 10.144.0.0/16
#   prod         = 10.145.0.0/16
#   interconnect = 10.146.0.0/16

spoke_vpcs = {
  "dev" = {
    host_project_id = "prj-dv-network"
    network_name    = "vpc-dev"
    cidr_block      = "10.143.0.0/16"
    service_project_ids = [
      # Add dev service project IDs here after projects are created
      # "prj-dv-controls-app1",
    ]
    subnets = {
      "dev-vpc-subnet-primary-us-west1" = {
        ip_cidr_range = "10.143.1.0/24"
        region        = "us-west1"
        description   = "Dev primary subnet us-west1"
      }
      "dev-vpc-subnet-secondary-us-central1" = {
        ip_cidr_range = "10.143.2.0/24"
        region        = "us-central1"
        description   = "Dev secondary subnet us-central1"
      }
    }
    nat_config = {
      "us-west1"    = { nat_ip_allocate_option = "AUTO_ONLY" }
      "us-central1" = { nat_ip_allocate_option = "AUTO_ONLY" }
    }
    firewall_rules = {
      "fw-dev-allow-iap-ingress" = {
        direction   = "INGRESS"
        priority    = 1000
        ranges      = ["35.235.240.0/20"]
        allow       = [{ protocol = "tcp", ports = ["22", "3389"] }]
        description = "Allow IAP for SSH/RDP"
      }
      "fw-dev-allow-internal-ingress" = {
        direction   = "INGRESS"
        priority    = 1000
        ranges      = ["10.143.0.0/16"]
        allow       = [{ protocol = "all" }]
        description = "Allow internal dev traffic"
      }
      "fw-dev-allow-ingress-from-interconnect" = {
        direction   = "INGRESS"
        priority    = 900
        ranges      = ["10.146.0.0/16"]
        allow       = [{ protocol = "all" }]
        description = "Allow ingress from interconnect (on-prem via hub)"
      }
    }
  }

  "non-prod" = {
    host_project_id     = "prj-np-network"
    network_name        = "vpc-non-prod"
    cidr_block          = "10.144.0.0/16"
    service_project_ids = []
    subnets = {
      "np-vpc-subnet-primary-us-west1" = {
        ip_cidr_range = "10.144.1.0/24"
        region        = "us-west1"
        description   = "Non-prod primary subnet us-west1"
      }
      "np-vpc-subnet-secondary-us-central1" = {
        ip_cidr_range = "10.144.2.0/24"
        region        = "us-central1"
        description   = "Non-prod secondary subnet us-central1"
      }
    }
    nat_config = {
      "us-west1"    = { nat_ip_allocate_option = "AUTO_ONLY" }
      "us-central1" = { nat_ip_allocate_option = "AUTO_ONLY" }
    }
    firewall_rules = {
      "fw-np-allow-iap-ingress" = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["35.235.240.0/20"]
        allow     = [{ protocol = "tcp", ports = ["22", "3389"] }]
      }
      "fw-np-allow-internal-ingress" = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["10.144.0.0/16"]
        allow     = [{ protocol = "all" }]
      }
      "fw-np-allow-ingress-from-interconnect" = {
        direction   = "INGRESS"
        priority    = 900
        ranges      = ["10.146.0.0/16"]
        allow       = [{ protocol = "all" }]
        description = "Allow ingress from interconnect (on-prem via hub)"
      }
    }
  }

  "prod" = {
    host_project_id     = "prj-prd-network"
    network_name        = "vpc-prod"
    cidr_block          = "10.145.0.0/16"
    service_project_ids = []
    subnets = {
      "prd-vpc-subnet-primary-us-west1" = {
        ip_cidr_range = "10.145.1.0/24"
        region        = "us-west1"
        description   = "Prod primary subnet us-west1"
      }
      "prd-vpc-subnet-secondary-us-central1" = {
        ip_cidr_range = "10.145.2.0/24"
        region        = "us-central1"
        description   = "Prod secondary subnet us-central1"
      }
    }
    nat_config = {
      "us-west1"    = { nat_ip_allocate_option = "AUTO_ONLY" }
      "us-central1" = { nat_ip_allocate_option = "AUTO_ONLY" }
    }
    firewall_rules = {
      "fw-prd-allow-iap-ingress" = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["35.235.240.0/20"]
        allow     = [{ protocol = "tcp", ports = ["22", "3389"] }]
      }
      "fw-prd-allow-internal-ingress" = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["10.145.0.0/16"]
        allow     = [{ protocol = "all" }]
      }
      "fw-prd-allow-ingress-from-interconnect" = {
        direction   = "INGRESS"
        priority    = 900
        ranges      = ["10.146.0.0/16"]
        allow       = [{ protocol = "all" }]
        description = "Allow ingress from interconnect (on-prem via hub)"
      }
    }
  }
}

# ── DNS ───────────────────────────────────────────────────────────────────────
dns_project_id = "prj-sh-interconnect"

private_dns_zones = {
  "private-hub-core" = {
    dns_name    = "accoes.internal."
    description = "ACCO internal private DNS zone (hub)"
    networks    = [] # Hub VPC is automatically attached programmatically
  }
}

peering_dns_zones = {} # Auto-generated for dev, non-prod, and prod spokes programmatically

forwarding_dns_zones = {
  # On-prem / Azure forwarding zones (Hub VPC is automatically attached)
  # "onprem-corp" = {
  #   dns_name      = "corp.accoes.com."
  #   networks      = []
  #   target_dns_ip = ["192.168.1.53", "192.168.1.54"]
  # }
}

# =============================================================================
# live/iam — IAM bindings, log sinks, budgets
# =============================================================================

# ── IAM Bindings ──────────────────────────────────────────────────────────────
# Naming convention for groups: gcp-<env>-<business-unit>-[<app>]-<admins|users>
# Platform groups: gcp-organization-admins, gcp-billing-admins,
#                  gcp-sh-network-admins, gcp-sh-infrastructure-admins
# Per-env:         gcp-<env>-admins
#
# USER bindings are empty by default — add them here without code changes.

iam_bindings = {
  # ── Org-level admin groups ──────────────────────────────────────────────────
  "org/org-admins/org-admin-role" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-organization-admins@accoes.com"
    role          = "roles/resourcemanager.organizationAdmin"
  }
  "org/billing-admins/billing-admin-role" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-billing-admins@accoes.com"
    role          = "roles/billing.admin"
  }
  "org/network-admins/compute-network-admin" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-sh-network-admins@accoes.com"
    role          = "roles/compute.networkAdmin"
  }
  "org/infra-admins/org-viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-sh-infrastructure-admins@accoes.com"
    role          = "roles/viewer"
  }

  # ── Per-env admin groups ───────────────────────────────────────────────────
  # Replace <folder_id_dev> etc. with actual folder IDs from live/org outputs.
  "folder/dev/gcp-dv-admins/folder-admin" = {
    resource_type = "folder"
    resource_id   = "folders/<dev_folder_id>"
    member        = "group:gcp-dv-admins@accoes.com"
    role          = "roles/resourcemanager.folderAdmin"
  }
  "folder/np/gcp-np-admins/folder-admin" = {
    resource_type = "folder"
    resource_id   = "folders/<non_prod_folder_id>"
    member        = "group:gcp-np-admins@accoes.com"
    role          = "roles/resourcemanager.folderAdmin"
  }
  "folder/prd/gcp-prd-admins/folder-admin" = {
    resource_type = "folder"
    resource_id   = "folders/<prod_folder_id>"
    member        = "group:gcp-prd-admins@accoes.com"
    role          = "roles/resourcemanager.folderAdmin"
  }

  # ── Business-unit admin groups (example: controls in dev) ──────────────────
  "folder/dv-controls/gcp-dv-controls-admins/editor" = {
    resource_type = "folder"
    resource_id   = "folders/<bu_folder_id>"
    member        = "group:gcp-dv-controls-admins@accoes.com"
    role          = "roles/editor"
  }

  # ── Security Admins ────────────────────────────────────────────────────────
  "org/security-admins/viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-security-admins@accoes.com"
    role          = "roles/viewer"
  }
  "org/security-admins/scc-admin" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-security-admins@accoes.com"
    role          = "roles/securitycenter.admin"
  }
  "org/security-admins/iam-security-admin" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-security-admins@accoes.com"
    role          = "roles/iam.securityAdmin"
  }

  # ── Gemini / AI Users ──────────────────────────────────────────────────────
  "org/gemini-users/discovery-viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-gemini-user@accoes.com"
    role          = "roles/discoveryengine.viewer"
  }
  "org/gemini-users/aiplatform-user" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-gemini-user@accoes.com"
    role          = "roles/aiplatform.user"
  }

  # ── Gemini / AI Admins ─────────────────────────────────────────────────────
  "org/gemini-admins/discovery-admin" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-gemini-admins@accoes.com"
    role          = "roles/discoveryengine.admin"
  }
  "org/gemini-admins/aiplatform-admin" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-gemini-admins@accoes.com"
    role          = "roles/aiplatform.admin"
  }

  # ── Service Desk Admins ────────────────────────────────────────────────────
  "org/service-desk-admins/viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-service-desk-admins@accoes.com"
    role          = "roles/viewer"
  }
  "org/service-desk-admins/log-viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-service-desk-admins@accoes.com"
    role          = "roles/logging.viewer"
  }
  "org/service-desk-admins/mon-viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-service-desk-admins@accoes.com"
    role          = "roles/monitoring.viewer"
  }
  "org/service-desk-admins/support-admin" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-service-desk-admins@accoes.com"
    role          = "roles/cloudsupport.admin"
  }

  # ── Service Desk Users ─────────────────────────────────────────────────────
  "org/service-desk-users/viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-service-desk-users@accoes.com"
    role          = "roles/viewer"
  }
  "org/service-desk-users/log-viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-service-desk-users@accoes.com"
    role          = "roles/logging.viewer"
  }
  "org/service-desk-users/mon-viewer" = {
    resource_type = "organization"
    resource_id   = "<org_id>"
    member        = "group:gcp-service-desk-users@accoes.com"
    role          = "roles/monitoring.viewer"
  }

  # ── USER group bindings (empty by default — add per app) ───────────────────
  # "project/prj-dv-controls-app1/gcp-dv-controls-users/viewer" = {
  #   resource_type = "project"
  #   resource_id   = "prj-dv-controls-app1"
  #   member        = "group:gcp-dv-controls-users@accoes.com"
  #   role          = "roles/viewer"
  # }

  # ── Example time-bound condition (break-glass access) ─────────────────────
  # "org/breakglass/temp-admin" = {
  #   resource_type = "organization"
  #   resource_id   = "123456789012"
  #   member        = "group:gcp-breakglass@accoes.com"
  #   role          = "roles/resourcemanager.organizationAdmin"
  #   condition = {
  #     title      = "expires_2025_12_31"
  #     expression = "request.time < timestamp('2025-12-31T00:00:00Z')"
  #   }
  # }
}

# ── Service Accounts ──────────────────────────────────────────────────────────
service_accounts = {
  # Example: monitoring SA in the operations project
  # "sa-monitoring" = {
  #   project_id    = "prj-sh-operations"
  #   display_name  = "Monitoring SA"
  #   description   = "Writes metrics and traces"
  #   project_roles = ["roles/monitoring.metricWriter", "roles/cloudtrace.agent"]
  #   iam_bindings  = {}
  # }
}

# ── Log Sinks ─────────────────────────────────────────────────────────────────
log_sinks = {
  "dev-org-sink" = {
    sink_project_id      = "prj-dv-log-mon"
    sink_name            = "sink-dv-org"
    parent_type          = "folder"
    parent_id            = "folders/<dev_folder_id>"
    filter               = ""
    include_children     = true
    bucket_name          = "bkt-dv-logs-acco-0982"
    bucket_location      = "US"
    retention_days       = 30
    audit_retention_days = 400
    nearline_age_days    = 30
    archive_age_days     = 90
    pubsub_topic_name    = "topic-dv-logs"
    # Uncomment for Splunk integration:
    # splunk_subscription_name = "sub-dv-logs-splunk"
    # splunk_push_endpoint     = "https://splunk.accoes.com:8088/services/collector"
    labels = { environment = "dv" }
  }

  "np-org-sink" = {
    sink_project_id      = "prj-np-log-mon"
    sink_name            = "sink-np-org"
    parent_type          = "folder"
    parent_id            = "folders/<non_prod_folder_id>"
    filter               = ""
    include_children     = true
    bucket_name          = "bkt-np-logs-acco-0982"
    bucket_location      = "US"
    retention_days       = 30
    audit_retention_days = 400
    nearline_age_days    = 30
    archive_age_days     = 90
    pubsub_topic_name    = "topic-np-logs"
    labels               = { environment = "np" }
  }

  "prd-org-sink" = {
    sink_project_id      = "prj-prd-log-mon"
    sink_name            = "sink-prd-org"
    parent_type          = "folder"
    parent_id            = "folders/<prod_folder_id>"
    filter               = ""
    include_children     = true
    bucket_name          = "bkt-prd-logs-acco-0982"
    bucket_location      = "US"
    retention_days       = 90
    audit_retention_days = 400
    nearline_age_days    = 30
    archive_age_days     = 90
    pubsub_topic_name    = "topic-prd-logs"
    labels               = { environment = "prd" }
  }
}

# ── Budgets ────────────────────────────────────────────────────────────────────
budgets = {
  # Fixed-dollar alert: fires when spend reaches 50%, 90%, or 100% of $500
  "dollar-billing-alert" = {
    amount_usd             = 500
    use_last_period_amount = false
    project_ids            = [] # empty = entire billing account
    alert_thresholds       = [0.5, 0.9, 1.0]
    include_credits        = false
    notification_channels  = []
  }
  # Percentage-of-last-month alert: fires when spend reaches 50%, 90%, or 100% of last month's spend
  "percentage-billing-alert" = {
    use_last_period_amount = true
    project_ids            = [] # empty = entire billing account
    alert_thresholds       = [0.5, 0.9, 1.0]
    include_credits        = false
    notification_channels  = []
  }
}
