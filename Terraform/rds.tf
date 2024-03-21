resource "aws_db_subnet_group" "drupal_sub_grp_rds" {
  name        = "dbsubgrp-devopsteam03"
  description = "DBSUBGRP-DEVOPSTEAM03"
  subnet_ids  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_db_instance" "drupal_rds" {
  engine         = "mariadb"
  engine_version = "10.11.7"

  identifier = "dbi-devopsteam03"
  username   = "admin"
  password   = var.drupal_rds_password

  instance_class        = "db.t3.micro"
  storage_type          = "gp3"
  allocated_storage     = "20"
  max_allocated_storage = 0

  db_subnet_group_name   = aws_db_subnet_group.drupal_sub_grp_rds.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  availability_zone      = "eu-west-3a"

  monitoring_interval     = 0
  backup_retention_period = 0
}