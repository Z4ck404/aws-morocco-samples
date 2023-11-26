#######################################################
##  setup VPCs: service_provider_vpc in us-east-1 
##  and service_provider_outpost vpc in us-west-2
##  and service_consumer_vpc also in us-west-2
#######################################################

module "vpc_service_provider" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "awsmorocco_service_provider_vpc"
  cidr   = "10.10.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.10.1.0/24"]
  public_subnets  = ["10.10.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc_service_provider_outpost" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "awsmorocco_service_provider_outpost"
  cidr   = "10.11.0.0/16"

  azs             = ["eu-west-1a"]
  private_subnets = ["10.11.1.0/24"]
  public_subnets  = ["10.11.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc_service_consumer" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "awsmorocco_service_consumer"
  cidr   = "10.2.0.0/16"

  azs                = ["eu-west-1a"]
  private_subnets    = ["10.12.1.0/24"]
  public_subnets     = ["10.12.2.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

#######################################################
##  PrivateLink Setup
#######################################################

data "aws_caller_identity" "current" {}

resource "aws_lb" "nlb" {
  name               = "service-provider-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc_service_provider.private_subnets

  enable_deletion_protection = false

  provider = aws.service_provider_outpost
}

resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.nlb.arn]

  provider = aws.service_provider_outpost
}

resource "aws_vpc_endpoint_service_allowed_principal" "this" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.this.id
  principal_arn           = data.aws_caller_identity.current.arn

  provider = aws.service_provider_outpost
}

resource "aws_vpc_endpoint" "this" {
  service_name      = aws_vpc_endpoint_service.this.service_name
  subnet_ids        = module.vpc_service_consumer.private_subnets
  vpc_endpoint_type = "Interface"
  vpc_id            = module.vpc_service_consumer.vpc_id

  provider = aws.consumer

  depends_on = [module.vpc_service_consumer]
}

#######################################################
##  Peering Configuration between service_provider_vpc 
##  and service_provider_outpost vpc
#######################################################

resource "aws_vpc_peering_connection" "this" {
  vpc_id      = module.vpc_service_provider_outpost.vpc_id
  peer_vpc_id = module.vpc_service_provider.vpc_id
  peer_region = "us-east-1"
  auto_accept = false

  provider = aws.service_provider_outpost
}

resource "aws_vpc_peering_connection_accepter" "this" {
  provider                  = aws.service_provider
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true
}

resource "aws_vpc_peering_connection_options" "this" {
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  provider = aws.service_provider
}

locals {
  requester_route_tables_ids = concat(module.vpc_service_provider_outpost.public_route_table_ids, module.vpc_service_provider_outpost.private_route_table_ids)
  accepter_route_tables_ids  = concat(module.vpc_service_provider.public_route_table_ids, module.vpc_service_provider.private_route_table_ids)
}

resource "aws_route" "requester" {
  count                     = length(local.requester_route_tables_ids)
  route_table_id            = local.requester_route_tables_ids[count.index]
  destination_cidr_block    = module.vpc_service_provider.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  provider = aws.service_provider_outpost
}

resource "aws_route" "accepter" {
  count                     = length(local.accepter_route_tables_ids)
  route_table_id            = local.accepter_route_tables_ids[count.index]
  destination_cidr_block    = module.vpc_service_provider_outpost.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  provider = aws.service_provider
}
