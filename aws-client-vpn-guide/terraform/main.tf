### Define variables

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0e2466eb18a9fc333"
}

### Configure the AWS Provider

provider "aws" {
  region  = var.aws_region
}

### data sources

data "aws_acm_certificate" "server" {
  domain = "server.vpn.awsmorocco"
}

data "aws_acm_certificate" "client" {
  domain = "vpn.zakaria.elbazi"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet" "target_network" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.aws_region}a"
}

### Client VPN Endpoint resource

resource "aws_ec2_client_vpn_endpoint" "aws-morocco-client-vpn" {

  description            = "awsmorocco-clientvpn-endpoint"
  server_certificate_arn = data.aws_acm_certificate.server.arn
  client_cidr_block      = "172.20.0.0/16"
  split_tunnel           = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.client.arn
  }

  vpc_id = var.vpc_id

  connection_log_options {
    enabled = false
  }

}

### Client VPN Network Association resource

resource "aws_ec2_client_vpn_network_association" "network-association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.aws-morocco-client-vpn.id
  subnet_id              = data.aws_subnet.target_network.id
}

### Client VPN Route resource

resource "aws_ec2_client_vpn_route" "aws-morocco-client-vpn-route" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.aws-morocco-client-vpn.id
  destination_cidr_block = data.aws_vpc.selected.cidr_block_associations[0].cidr_block
  target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.network-association.subnet_id
}

### Client VPN authorization rule resource

resource "aws_ec2_client_vpn_authorization_rule" "auth-rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.aws-morocco-client-vpn.id
  target_network_cidr    = data.aws_vpc.selected.cidr_block_associations[0].cidr_block
  authorize_all_groups   = true
}