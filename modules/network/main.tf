# VPC

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.32.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  tags = {
    Name     = "main-vpc"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

# Subnets

resource "aws_subnet" "public_subnets" {
  for_each                            = var.SUBNETS
  availability_zone                   = "${var.AWS_REGION}${each.key}"
  vpc_id                              = aws_vpc.main_vpc.id
  cidr_block                          = "10.32.${each.value[0]}.0/20"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name     = "public-subnet-${each.key}"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each                            = var.SUBNETS
  availability_zone                   = "${var.AWS_REGION}${each.key}"
  vpc_id                              = aws_vpc.main_vpc.id
  cidr_block                          = "10.32.${each.value[1]}.0/20"
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name     = "private-subnet-${each.key}"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name     = "internet-gateway"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

# Elastic IPs

resource "aws_eip" "nat_gateways_elastic_ips" {
  for_each             = aws_subnet.public_subnets
  vpc                  = true
  public_ipv4_pool     = "amazon"
  network_border_group = var.AWS_REGION
  tags = {
    Name     = "elastic-ip--nat-gateway-${each.key}"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

# NAT Gateways

resource "aws_nat_gateway" "nat_gateways" {
  for_each          = aws_subnet.public_subnets
  subnet_id         = each.value.id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_gateways_elastic_ips[each.key].id
  tags = {
    Name     = "nat-gateway-${each.key}"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

# Route tables and associations

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name     = "igw-route-table"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

resource "aws_route_table_association" "public_route_table_associations" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_tables" {
  for_each = aws_nat_gateway.nat_gateways
  vpc_id   = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
  tags = {
    Name     = "ngw-${each.key}-route-table"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

resource "aws_route_table_association" "private_route_table_associations" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_tables[each.key].id
}
