# Set up AWS Virtual Private Cloud and networking
data "aws_availability_zones" "available" {}

resource "aws_vpc" "VPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name = "Fargate demo VPC"
  } 
}

resource "aws_subnet" "public" {
  count             = var.az_count
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_network_acl" "network_acl" {
  vpc_id     = aws_vpc.VPC.id
  subnet_ids = aws_subnet.public.*.id

  ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "Fargate demo IGW"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "default-route-table"
  }
}

resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW.id
}

resource "aws_route_table_association" "IGW_public_association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "fargate_demo" {
  name        = "fargate-demo-sg"
  description = "Security group for Fargate demo vpc"
  vpc_id      = aws_vpc.VPC.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}