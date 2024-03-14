data "aws_key_pair" "kp_drupal" {
  key_name           = "CLD_KEY_DRUPAL_DEVOPSTEAM03"
  include_public_key = true
}

resource "aws_instance" "drupal_a" {
  ami = "ami-0fdefd1ed473b69ab"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet_a.id
  private_ip = "10.0.3.10"
  vpc_security_group_ids = [aws_security_group.sg_drupal.id]
  key_name = data.aws_key_pair.kp_drupal.key_name

  tags = {
    Name = "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03_A"
  }
}