data "aws_key_pair" "kp_drupal" {
  key_name           = "CLD_KEY_DRUPAL_DEVOPSTEAM03"
  include_public_key = true
}

resource "aws_ami_from_instance" "drupal" {
  name               = "AMI_DEVOPSTEAM03_FIN_LABO02"
  description        = "AMI_DEVOPSTEAM03_FIN_LABO02"
  source_instance_id = ""

  lifecycle {
    ignore_changes = [source_instance_id]
  }
  tags = {
    Name = "AMI_DEVOPSTEAM03_FIN_LABO02"
  }
}