data "aws_key_pair" "kp_drupal" {
  key_name           = "CLD_KEY_DRUPAL_DEVOPSTEAM03"
  include_public_key = true
}

resource "aws_instance" "drupal" {
  ami = "ami-0fdefd1ed473b69ab"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg_drupal.id]
  key_name = data.aws_key_pair.kp_drupal.key_name

  tags = {
    Name = "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03"
  }

}