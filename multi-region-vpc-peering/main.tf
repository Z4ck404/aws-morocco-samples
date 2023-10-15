#### peering configuration #### 

resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accpeter_vpc_id
  peer_region = var.accepter_region
  auto_accept = false
  provider    = aws.peer
}

resource "aws_vpc_peering_connection_accepter" "this" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true
}

resource "aws_vpc_peering_connection_options" "this" {
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  provider = aws.accepter

}


####  route tables ####

resource "aws_route" "requester" {
  count                     = length(local.requester_route_tables_ids)
  route_table_id            = local.requester_route_tables_ids[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  provider                  = aws.peer
}

resource "aws_route" "accepter" {
  count                     = length(local.accepter_route_tables_ids)
  route_table_id            = local.accepter_route_tables_ids[count.index]
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  provider                  = aws.accepter
}