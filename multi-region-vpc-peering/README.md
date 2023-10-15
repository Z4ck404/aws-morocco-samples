# AWS VPC Peering Configuration

-> Medium blog for detailed instructions : [AWS multi-region VPC peering using Terraform](https://awsmorocco.com/aws-multi-region-vpc-peering-using-terraform-a0b8aabf084b)

This Terraform configuration sets up VPC peering between two AWS Virtual Private Clouds (VPCs), requester and accepter. It also configures route tables for communication between the VPCs.

## Variables

### Accepter VPC

- `accpeter_vpc_id`: The ID of the accepter VPC.
- `accepter_region`: The region of the accepter VPC.

### Requester VPC

- `requester_vpc_id`: The ID of the requester VPC.
- `requester_region`: The region of the requester VPC.

## Providers

### Requester

- AWS provider with an alias "peer" for the requester VPC.

### Accepter

- AWS provider with an alias "accepter" for the accepter VPC.

## Data Sources

- `aws_vpc` for accepter VPC.
- `aws_route_tables` for accepter VPC.
- `aws_vpc` for requester VPC.
- `aws_route_tables` for requester VPC.

## Peering Configuration

- Sets up a VPC peering connection between the requester and accepter VPCs.
- Allows remote VPC DNS resolution in the accepter VPC.

## Route Tables

- Creates routes in the requester and accepter route tables to enable communication between the VPCs.

## Usage

To use this configuration, make sure you provide the required variables and then apply the Terraform configuration.

```hcl
terraform init
terraform apply
```
