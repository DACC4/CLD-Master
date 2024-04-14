# Task 001 - Configure Auto Scaling

![Schema](./img/CLD_AWS_INFA.PNG)

* Follow the instructions in the tutorial [Getting started with Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/GettingStartedTutorial.html) to create a launch template.

* [CLI Documentation](https://docs.aws.amazon.com/cli/latest/reference/autoscaling/)

## Pre-requisites

* Networks (RTE-TABLE/SECURITY GROUP) set as at the end of the Labo2.
* 1 AMI of your Drupal instance
* 0 existing ec2 (even is in a stopped state)
* 1 RDS Database instance - started
* 1 Elastic Load Balancer - started

## Create a new launch template. 

|Key|Value|
|:--|:--|
|Name|LT-DEVOPSTEAM[XX]|
|Version|v1.0.0|
|Tag|Name->same as template's name|
|AMI|Your Drupal AMI|
|Instance type|t3.micro (as usual)|
|Subnet|Your subnet A|
|Security groups|Your Drupal Security Group|
|IP Address assignation|Do not assign|
|Storage|Only 10 Go Storage (based on your AMI)|
|Advanced Details/EC2 Detailed Cloud Watch|enable|
|Purchase option/Request Spot instance|disable|

```
[INPUT]
resource "aws_launch_configuration" "drupal" {
  name                = "LT-DEVOPSTEAM03"
  image_id                    = aws_ami_from_instance.drupal.id
  instance_type               = "t3.micro"
  enable_monitoring           = true
  associate_public_ip_address = false
  security_groups = [aws_security_group.sg_drupal.id]
  key_name                    = data.aws_key_pair.kp_drupal.key_name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  lifecycle {
    create_before_destroy = true
  }
}

[OUTPUT]
Terraform will perform the following actions:

  # aws_launch_configuration.drupal will be created
  + resource "aws_launch_configuration" "drupal" {
      + arn                         = (known after apply)
      + associate_public_ip_address = false
      + ebs_optimized               = (known after apply)
      + enable_monitoring           = true
      + id                          = (known after apply)
      + image_id                    = "ami-0a2145d726c1e92b8"
      + instance_type               = "t3.micro"
      + key_name                    = "CLD_KEY_DRUPAL_DEVOPSTEAM03"
      + name                        = "LT-DEVOPSTEAM03"
      + name_prefix                 = (known after apply)
      + security_groups             = [
          + "sg-003f6a093f288504c",
        ]

      + root_block_device {
          + delete_on_termination = true
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + throughput            = (known after apply)
          + volume_size           = 10
          + volume_type           = "gp3"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_launch_configuration.drupal: Creating...
aws_launch_configuration.drupal: Creation complete after 1s [id=LT-DEVOPSTEAM03]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Create an autoscaling group

* Choose launch template or configuration

|Specifications|Key|Value|
|:--|:--|:--|
|Launch Configuration|Name|ASGRP_DEVOPSTEAM[XX]|
||Launch configuration|Your launch configuration|
|Instance launch option|VPC|Refer to infra schema|
||AZ and subnet|AZs and subnets a + b|
|Advanced options|Attach to an existing LB|Your ELB|
||Target group|Your target group|
|Health check|Load balancing health check|Turn on|
||health check grace period|10 seconds|
|Additional settings|Group metrics collection within Cloud Watch|Enable|
||Health check grace period|10 seconds|
|Group size and scaling option|Desired capacity|1|
||Min desired capacity|1|
||Max desired capacity|4|
||Policies|Target tracking scaling policy|
||Target tracking scaling policy Name|TTP_DEVOPSTEAM[XX]|
||Metric type|Average CPU utilization|
||Target value|50|
||Instance warmup|30 seconds|
||Instance maintenance policy|None|
||Instance scale-in protection|None|
||Notification|None|
|Add tag to instance|Name|AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM[XX]|

```
[INPUT]
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
  name = "TTP_DEVOPSTEAM03"
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

[OUTPUT]
Terraform will perform the following actions:

  # aws_autoscaling_attachment.drupal will be created
  + resource "aws_autoscaling_attachment" "drupal" {
      + autoscaling_group_name = "ASGRP_DEVOPSTEAM03"
      + id                     = (known after apply)
      + lb_target_group_arn    = "arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM03/e2bbbd6c13e54c81"
    }

  # aws_autoscaling_group.drupal will be created
  + resource "aws_autoscaling_group" "drupal" {
      + arn                              = (known after apply)
      + availability_zones               = (known after apply)
      + default_cooldown                 = (known after apply)
      + default_instance_warmup          = 30
      + desired_capacity                 = 1
      + enabled_metrics                  = [
          + "GroupAndWarmPoolDesiredCapacity",
          + "GroupAndWarmPoolTotalCapacity",
          + "GroupDesiredCapacity",
          + "GroupInServiceCapacity",
          + "GroupInServiceInstances",
          + "GroupMaxSize",
          + "GroupMinSize",
          + "GroupPendingCapacity",
          + "GroupPendingInstances",
          + "GroupStandbyCapacity",
          + "GroupStandbyInstances",
          + "GroupTerminatingCapacity",
          + "GroupTerminatingInstances",
          + "GroupTotalCapacity",
          + "GroupTotalInstances",
          + "WarmPoolDesiredCapacity",
          + "WarmPoolMinSize",
          + "WarmPoolPendingCapacity",
          + "WarmPoolTerminatingCapacity",
          + "WarmPoolTotalCapacity",
          + "WarmPoolWarmedCapacity",
        ]
      + force_delete                     = false
      + force_delete_warm_pool           = false
      + health_check_grace_period        = 10
      + health_check_type                = "ELB"
      + id                               = (known after apply)
      + ignore_failed_scaling_activities = false
      + launch_configuration             = "LT-DEVOPSTEAM03"
      + load_balancers                   = (known after apply)
      + max_size                         = 4
      + metrics_granularity              = "1Minute"
      + min_size                         = 1
      + name                             = "ASGRP_DEVOPSTEAM03"
      + name_prefix                      = (known after apply)
      + predicted_capacity               = (known after apply)
      + protect_from_scale_in            = false
      + service_linked_role_arn          = (known after apply)
      + target_group_arns                = (known after apply)
      + vpc_zone_identifier              = [
          + "subnet-0af8a06cb3c5899be",
          + "subnet-0c80bdfa1913b81d4",
        ]
      + wait_for_capacity_timeout        = "10m"
      + warm_pool_size                   = (known after apply)

      + tag {
          + key                 = "Name"
          + propagate_at_launch = true
          + value               = "AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM03"
        }
    }

  # aws_autoscaling_policy.drupal will be created
  + resource "aws_autoscaling_policy" "drupal" {
      + arn                     = (known after apply)
      + autoscaling_group_name  = "ASGRP_DEVOPSTEAM03"
      + enabled                 = true
      + id                      = (known after apply)
      + metric_aggregation_type = (known after apply)
      + name                    = "TTP_DEVOPSTEAM03"
      + policy_type             = "TargetTrackingScaling"

      + target_tracking_configuration {
          + disable_scale_in = false
          + target_value     = 50

          + predefined_metric_specification {
              + predefined_metric_type = "ASGAverageCPUUtilization"
            }
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_autoscaling_group.drupal: Creating...
aws_autoscaling_group.drupal: Still creating... [10s elapsed]
aws_autoscaling_group.drupal: Creation complete after 14s [id=ASGRP_DEVOPSTEAM03]
aws_autoscaling_attachment.drupal: Creating...
aws_autoscaling_policy.drupal: Creating...
aws_autoscaling_attachment.drupal: Creation complete after 1s [id=ASGRP_DEVOPSTEAM03-20240411151435700400000001]
aws_autoscaling_policy.drupal: Creation complete after 1s [id=TTP_DEVOPSTEAM03]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

* Result expected

The first instance is launched automatically.

Test ssh and web access.

```
[INPUT]
ssh devopsteam03@15.188.43.46 -i CLD_KEY_DMZ_DEVOPSTEAM03.pem -L 2222:10.0.3.9:22 -L 8080:internal-ELB-DEVOPSTEAM03-577789440.eu-west-3.elb.amazonaws.com:8080

ssh -o StrictHostKeyChecking=no bitnami@localhost -p 2222 -i CLD_KEY_DRUPAL_DEVOPSTEAM03.pem

[OUTPUT]
Linux ip-10-0-3-9 5.10.0-28-cloud-amd64 #1 SMP Debian 5.10.209-2 (2024-01-31) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
       ___ _ _                   _
      | _ |_) |_ _ _  __ _ _ __ (_)
      | _ \ |  _| ' \/ _` | '  \| |
      |___/_|\__|_|_|\__,_|_|_|_|_|
  
  *** Welcome to the Bitnami package for Drupal 10.2.3-1        ***
  *** Documentation:  https://docs.bitnami.com/aws/apps/drupal/ ***
  ***                 https://docs.bitnami.com/aws/             ***
  *** Bitnami Forums: https://github.com/bitnami/vms/           ***
Last login: Thu Mar 28 13:31:04 2024 from 10.0.0.5
bitnami@ip-10-0-3-9:~$
```
```
//screen shot, web access (login)
```
![LOGGED IN](./img/CLD_DRUPAL_LOGGED_IN.png)

