# How to Manage Subnets (Create & Modify)

Subnets in the ACCO landing zone belong to their respective environment's Shared VPC (`dev`, `non-prod`, `prod`). These networks use hub-and-spoke peering. 

## 1. Creating a New Subnet

To add a new subnet to a Shared VPC:

1. Open `terraform.tfvars` at the root of the repository.
2. Locate the `spoke_vpcs` map block.
3. Find the environment where you want to add the subnet (e.g., `"dev"`).
4. Inside the `subnets` map, add a new block for the subnet.

```hcl
spoke_vpcs = {
  "dev" = {
    # ... existing network config ...
    subnets = {
      # ... existing subnets ...
      
      "dv-vpc-subnet-database-us-west1" = {
        ip_cidr_range = "10.143.2.0/24"
        region        = "us-west1"
        description   = "Dev database subnet us-west1"
      }
    }
  }
}
```

5. Apply the changes in the Networking layer:
```bash
cd live/networking
terraform init
terraform apply
```

> **Note:** By default, Private Google Access is enabled on all subnets created by this module. The new subnet will automatically inherit routing and connectivity to the hub via the existing VPC peering configuration.

## 2. Modifying a Subnet CIDR Range

If you need to resize or change an existing CIDR range:

1. Locate the subnet in `terraform.tfvars` inside the `spoke_vpcs` block.
2. Modify the `ip_cidr_range`.

```hcl
      "dv-vpc-subnet-database-us-west1" = {
        ip_cidr_range = "10.143.2.0/23" # <--- updated range
        region        = "us-west1"
      }
```

3. Apply the changes in the Networking layer:
```bash
cd live/networking
terraform init
terraform apply
```

> **⚠️ WARNING:** Changing the CIDR range of an *existing* subnet is a **destructive action**. Google Cloud requires Terraform to destroy the old subnet and recreate it. Any workloads attached to the subnet will lose connectivity or must be drained/migrated prior to the operation. If you simply need more IPs, consider adding a secondary IP range instead of modifying the primary CIDR, or recreate the subnet safely during a maintenance window.
