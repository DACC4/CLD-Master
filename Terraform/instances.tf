data "aws_key_pair" "kp_drupal" {
  key_name           = "CLD_KEY_DRUPAL_DEVOPSTEAM03"
  include_public_key = true
}

data "aws_ami" "drupal" {
  filter {
    name = "image-id"
    values = ["ami-067fbd29c40befdc0"]
  }
}

resource "aws_instance" "drupal_a" {
  ami                    = data.aws_ami.drupal.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_a.id
  private_ip             = "10.0.3.10"
  vpc_security_group_ids = [aws_security_group.sg_drupal.id]
  key_name               = data.aws_key_pair.kp_drupal.key_name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03_A"
  }
}

resource "aws_instance" "drupal_b" {
  ami                    = data.aws_ami.drupal.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_b.id
  private_ip             = "10.0.3.140"
  vpc_security_group_ids = [aws_security_group.sg_drupal.id]
  key_name               = data.aws_key_pair.kp_drupal.key_name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03_B"
  }
}

resource "aws_ec2_instance_state" "drupal_a" {
  instance_id = aws_instance.drupal_a.id
  state       = "running"
}

resource "aws_ec2_instance_state" "drupal_b" {
  instance_id = aws_instance.drupal_b.id
  state       = "running"
}

resource "aws_ami_from_instance" "drupal" {
  name               = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
  description        = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
  source_instance_id = aws_instance.drupal_a.id

  tags = {
    Name = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
  }
}