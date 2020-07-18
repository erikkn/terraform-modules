locals {
  requester_vpc_id         = data.aws_vpc.requester.id
  accepter_vpc_id          = data.aws_vpc.accepter.id
  requester_vpc_cidr_block = [for v in data.aws_vpc.requester.cidr_block_associations : v.cidr_block]
  accepter_vpc_cidr_block  = [for v in data.aws_vpc.accepter.cidr_block_associations : v.cidr_block]
  requester_rtb_ids        = flatten([for v in data.aws_route_tables.requester : v.ids])
  accepter_rtb_ids         = flatten([for v in data.aws_route_tables.accepter : v.ids])

  requester_config_tmp     = flatten([for k in local.accepter_vpc_cidr_block : [for v in local.requester_rtb_ids : { vpc_cidr = k, rtb_id = v }]])
  requester_routing_config = { for v in local.requester_config_tmp : "${v.vpc_cidr}:${v.rtb_id}" => v }

  accepter_config_tmp     = flatten([for k in local.requester_vpc_cidr_block : [for v in local.accepter_rtb_ids : { vpc_cidr = k, rtb_id = v }]])
  accepter_routing_config = { for v in local.accepter_config_tmp : "${v.vpc_cidr}:${v.rtb_id}" => v }

  tags = {
    Name        = "${data.aws_vpc.requester.tags["Name"]}-${data.aws_vpc.accepter.tags["Name"]}"
    Owner       = data.aws_vpc.requester.tags["Owner"]
    Environment = data.aws_vpc.requester.tags["Environment"]
  }
}

// Data source section

data "aws_vpc" "requester" {
  state = "available"

  filter {
    name   = "tag:Name"
    values = [var.vpc_names.requester_vpc]
  }
}

data "aws_vpc" "accepter" {
  state = "available"

  filter {
    name   = "tag:Name"
    values = [var.vpc_names.accepter_vpc]
  }
}

// Assuming that the RTBs share the same name as the subnets (best practice).
data "aws_route_tables" "requester" {
  for_each = toset([for v in var.subnet_names.requester_subnets : v])

  vpc_id = local.requester_vpc_id

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

// Assuming that the RTBs share the same name as the subnets (best practice).
data "aws_route_tables" "accepter" {
  for_each = toset([for v in var.subnet_names.accepter_subnets : v])

  vpc_id = local.accepter_vpc_id

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

// Resource section

resource "aws_vpc_peering_connection" "this" {
  vpc_id      = local.requester_vpc_id
  peer_vpc_id = local.accepter_vpc_id
  auto_accept = true

  tags = local.tags
}

// Route from the requester to the accepter
resource "aws_route" "requester_to_accepter" {
  for_each = local.requester_routing_config

  route_table_id            = each.value.rtb_id
  destination_cidr_block    = each.value.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

// Route from the accepter to the requester
resource "aws_route" "accepter_to_requester" {
  for_each = local.accepter_routing_config

  route_table_id            = each.value.rtb_id
  destination_cidr_block    = each.value.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
