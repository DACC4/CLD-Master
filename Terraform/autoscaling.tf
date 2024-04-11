resource "aws_launch_configuration" "drupal" {
  name                        = "LT-DEVOPSTEAM03"
  image_id                    = aws_ami_from_instance.drupal.id
  instance_type               = "t3.micro"
  enable_monitoring           = true
  associate_public_ip_address = false
  security_groups             = [aws_security_group.sg_drupal.id]
  key_name                    = data.aws_key_pair.kp_drupal.key_name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "drupal" {
  name                      = "ASGRP_DEVOPSTEAM03"
  launch_configuration      = aws_launch_configuration.drupal.name
  min_size                  = 1
  desired_capacity          = 1
  max_size                  = 4
  health_check_grace_period = 10
  health_check_type         = "ELB"
  default_instance_warmup   = 30
  vpc_zone_identifier       = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  enabled_metrics                  = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity",
  ]


  tag {
    key                 = "Name"
    value               = "AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM03"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "drupal" {
  name                   = "TTP_DEVOPSTEAM03"
  autoscaling_group_name = aws_autoscaling_group.drupal.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

resource "aws_autoscaling_attachment" "drupal" {
  autoscaling_group_name = aws_autoscaling_group.drupal.name
  lb_target_group_arn    = aws_alb_target_group.tg_drupal.arn
}