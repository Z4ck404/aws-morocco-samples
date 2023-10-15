data "aws_vpc" "accepter" {
  id       = var.accpeter_vpc_id
  provider = aws.accepter
}

data "aws_route_tables" "accepter" {
  vpc_id   = var.accpeter_vpc_id
  provider = aws.accepter
}

data "aws_vpc" "requester" {
  id       = var.accpeter_vpc_id
  provider = aws.requester
}

data "aws_route_tables" "requester" {
  vpc_id   = var.requester_vpc_id
  provider = aws.requester
}

locals {
  requester_route_tables_ids = data.aws_route_tables.requester.ids
  accepter_route_tables_ids  = data.aws_route_tables.accepter.ids
}

data "aws_availability_zones" "available" {
  provider = aws.peer
}