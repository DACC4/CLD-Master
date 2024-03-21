data "aws_security_group" "sg_dmz_ssh_rproxy" {
  id = "sg-072f4e9295e67feb5"
}

data "aws_security_group" "sg_dmz_nat" {
  id = "sg-0c71f4ea753e23037"
}

resource "aws_security_group" "sg_drupal" {
  name        = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
  description = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = [data.aws_security_group.sg_dmz_ssh_rproxy.id]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = [aws_security_group.sg_alb.id]
  }

  tags = {
    Name = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
  }
}

resource "aws_vpc_security_group_ingress_rule" "authorize_drupal_sg" {
  security_group_id            = data.aws_security_group.sg_dmz_nat.id
  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.sg_drupal.id
}

resource "aws_security_group" "sg_rds" {
  name        = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03-RDS"
  description = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03-RDS"

  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = [aws_security_group.sg_drupal.id]
  }

  tags = {
    Name = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03-RDS"
  }
}

resource "aws_security_group" "sg_alb" {
  name = "SG-DEVOPSTEAM03-LB"
  description = "SG-DEVOPSTEAM03-LB"

  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    security_groups = [data.aws_security_group.sg_dmz_ssh_rproxy.id]
  }

  tags = {
    Name = "SG-DEVOPSTEAM03-LB"
  }
}