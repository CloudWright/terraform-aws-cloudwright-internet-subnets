
provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${data.aws_vpc.selected.id}"]
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = var.availability_zone
  cidr_block        = var.public_cidr_block

  tags = {
     Name = "Public Subnet"
  }

}

resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = var.availability_zone
  cidr_block        = var.private_cidr_block

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
  vpc_id = data.aws_vpc.selected.id

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
  vpc_id = data.aws_vpc.selected.id

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
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
