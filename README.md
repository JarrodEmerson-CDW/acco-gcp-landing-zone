# ACCO Engineered Systems — Google Cloud Landing Zone

A **modular, variable-driven** Terraform codebase that deploys the ACCO Engineered Systems
Google Cloud landing zone. Every name, CIDR, policy, group, and environment is controlled
by variables — **no structural code changes are ever required** to reconfigure the design.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Directory Structure](#directory-structure)
3. [Prerequisites](#prerequisites)
4. [Deployment Order](#deployment-order)
5. [Backend Configuration](#backend-configuration)
6. [How to Extend — tfvars-only changes](#how-to-extend--tfvars-only-changes)
   - [Add an Environment](#add-an-environment)
   - [Add a Business Unit](#add-a-business-unit)
   - [Add an Application Project](#add-an-application-project)
   - [Add a User Group Binding](#add-a-user-group-binding)
   - [Change a CIDR Range](#change-a-cidr-range)
   - [Add an Org Policy](#add-an-org-policy)
   - [Add a Log Sink](#add-a-log-sink)
7. [IAM Design](#iam-design)
8. [Networking Design](#networking-design)
9. [CIDR Allocations](#cidr-allocations)
10. [Provider Versions](#provider-versions)

---

## Architecture Overview

```text
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
└── sandbox/                 (code: sb)
