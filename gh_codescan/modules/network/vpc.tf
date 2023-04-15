variable "vpc_name" {}
variable "subnet_public_name" {}
variable "subnet_private_name" {}
variable "internet_gateway_name" {}
variable "elastic_ip_name" {}
variable "nat_gateway_name" {}
variable "route_table_public_name" {}
variable "route_table_private_name" {}
variable "security_group_name" {}

# ====================
#
# VPC
#
# ====================
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

# ====================
#
# Subnet
#
# ====================
resource "aws_subnet" "public_0" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = var.subnet_public_name
  }
}

resource "aws_subnet" "private_0" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = var.subnet_private_name
  }
}

# ====================
#
# Internet Gateway
#
# ====================
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.internet_gateway_name
  }
}

# ====================
#
# ElasticIP
#
# ====================
resource "aws_eip" "nat_gateway_0" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = var.elastic_ip_name
  }
}

# ====================
#
# NAT Gateway
#
# ====================
resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id     = aws_subnet.public_0.id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = var.nat_gateway_name
  }
}

# ====================
#
# Route Table
#
# ====================
# Public
resource "aws_route_table" "public_0" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.route_table_public_name
  }
}

resource "aws_route" "public_0" {
  gateway_id             = aws_internet_gateway.internet_gateway.id
  route_table_id         = aws_route_table.public_0.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_0.id
  route_table_id = aws_route_table.public_0.id
}

# Private
resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.route_table_private_name
  }
}

resource "aws_route" "private_0" {
  route_table_id         = aws_route_table.private_0.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway_0.id # NAT Gateway
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_0" {
  subnet_id      = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}


# ====================
#
# Security Group
#
# ====================
resource "aws_security_group" "slackbot_sg" {
  vpc_id = aws_vpc.main.id
  name   = "slackbot_sg"
  tags = {
    Name = var.security_group_name
  }
}

# アウトバウンドルール(全開放)
resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.slackbot_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

