
provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

data "aws_internet_gateway" "default" {
  internet_gateway_id = var.igw_id
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = var.vpc_id
  availability_zone = var.availability_zone
  cidr_block        = var.public_cidr_block
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch = false

  tags = {
     Name = "Public Subnet"
  }

}

resource "aws_subnet" "private_subnet" {
  vpc_id            = var.vpc_id
  availability_zone = var.availability_zone
  cidr_block        = var.private_cidr_block
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch = false

  tags = {
     Name = "Private Subnet"
  }

}

resource "aws_eip" "nat_gateway_eip" {
  vpc      = true
  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT Gateway for CloudWright Lambdas"
  }
}

resource "aws_route_table" "public_subnet" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Public Subnet"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }

}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_route_table" "private_lambda" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Private Lambda"
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

}

resource "aws_route_table_association" "private_lambda_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_lambda.id
}

resource "aws_security_group" "allow_cw_egress" {
  name        = "allow_cw_egress"
  description = "Allow CloudWright Lambdas to access public internet"
  vpc_id      = var.vpc_id
  revoke_rules_on_delete = true

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
