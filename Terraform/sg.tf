data "aws_security_group" "sg_dmz_ssh_rproxy" {
  id = "sg-072f4e9295e67feb5"
}

data "aws_security_group" "sg_dmz_nat" {
  id = "sg-0c71f4ea753e23037"
}

resource "aws_security_group" "sg_drupal" {
  name = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
  description = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    security_groups = [data.aws_security_group.sg_dmz_ssh_rproxy.id]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    security_groups = [data.aws_security_group.sg_dmz_ssh_rproxy.id]
  }

  tags = {
    Name = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
  }
}

resource "aws_vpc_security_group_ingress_rule" "authorize_drupal_sg" {
  security_group_id = data.aws_security_group.sg_dmz_nat.id
  ip_protocol = -1
  referenced_security_group_id = aws_security_group.sg_drupal.id
}

