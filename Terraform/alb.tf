resource "aws_alb_target_group" "tg_drupal" {
  name = "TG-DEVOPSTEAM03"

  port = 8080
  protocol = "HTTP"
  ip_address_type = "ipv4"

  vpc_id = data.aws_vpc.vpc.id

  health_check {
    protocol = "HTTP"
    path = "/"
    port = 8080
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    interval = 10
    matcher = 200
  }
}

resource "aws_alb_target_group_attachment" "tg_drupal_att_a" {
  target_group_arn = aws_alb_target_group.tg_drupal.arn
  target_id = aws_instance.drupal_a.id
}

resource "aws_alb_target_group_attachment" "tg_drupal_att_b" {
  target_group_arn = aws_alb_target_group.tg_drupal.arn
  target_id = aws_instance.drupal_b.id
}

resource "aws_alb" "alb_drupal" {
  name = "ELB-DEVOPSTEAM03"
  load_balancer_type = "application"
  internal = true
  ip_address_type = "ipv4"
  subnets = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  security_groups = [aws_security_group.sg_alb.id]
}

resource "aws_alb_listener" "listener_internal" {
  load_balancer_arn = aws_alb.alb_drupal.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg_drupal.arn
  }
}