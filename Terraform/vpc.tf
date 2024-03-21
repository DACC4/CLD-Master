data "aws_vpc" "vpc" {
  id = "vpc-03d46c285a2af77ba"
}

data "aws_network_interface" "dmz_nat_net" {
  id = "eni-002339a1b15500f68"
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = var.cidr_block_a
  availability_zone = "eu-west-3a"
  tags = {
    Name = "SUB-PRIVATE-DEVOPSTEAM03a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = var.cidr_block_b
  availability_zone = "eu-west-3b"
  tags = {
    Name = "SUB-PRIVATE-DEVOPSTEAM03b"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_network_interface.dmz_nat_net.id
  }

  tags = {
    Name = "RTBLE-PRIVATE-DRUPAL-DEVOPSTEAM03"
  }
}

resource "aws_route_table_association" "route_table_assoc_a" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet_a.id
}

resource "aws_route_table_association" "route_table_assoc_b" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet_b.id
}