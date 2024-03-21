### Deploy the elastic load balancer

In this task you will create a load balancer in AWS that will receive
the HTTP requests from clients and forward them to the Drupal
instances.

![Schema](./img/CLD_AWS_INFA.PNG)

## Task 01 Prerequisites for the ELB

* Create a dedicated security group

|Key|Value|
|:--|:--|
|Name|SG-DEVOPSTEAM[XX]-LB|
|Inbound Rules|Application Load Balancer|
|Outbound Rules|Refer to the infra schema|

```bash
[INPUT]
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

## And edited Drupal SG inbound rule for 8080
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = [aws_security_group.sg_alb.id]
  }


[OUTPUT]
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_security_group.sg_alb will be created
  + resource "aws_security_group" "sg_alb" {
      + arn                    = (known after apply)
      + description            = "SG-DEVOPSTEAM03-LB"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 8080
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = [
                  + "sg-072f4e9295e67feb5",
                ]
              + self             = false
              + to_port          = 8080
            },
        ]
      + name                   = "SG-DEVOPSTEAM03-LB"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "SG-DEVOPSTEAM03-LB"
        }
      + tags_all               = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "SG-DEVOPSTEAM03-LB"
          + "Owner"     = "DEVOPS03"
        }
      + vpc_id                 = "vpc-03d46c285a2af77ba"
    }

  # aws_security_group.sg_drupal will be updated in-place
  ~ resource "aws_security_group" "sg_drupal" {
        id                     = "sg-003f6a093f288504c"
      ~ ingress                = [
          - {
              - cidr_blocks      = []
              - description      = ""
              - from_port        = 8080
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = [
                  - "sg-072f4e9295e67feb5",
                ]
              - self             = false
              - to_port          = 8080
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 8080
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 8080
            },
        ]
        name                   = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
        tags                   = {
            "Name" = "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
        }
        # (7 unchanged attributes hidden)
    }

Plan: 1 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_security_group.sg_alb: Creating...
aws_security_group.sg_alb: Creation complete after 2s [id=sg-0219a396bbd9a3e55]
aws_security_group.sg_drupal: Modifying... [id=sg-003f6a093f288504c]
aws_security_group.sg_drupal: Modifications complete after 0s [id=sg-003f6a093f288504c]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
```

* Create the Target Group

|Key|Value|
|:--|:--|
|Target type|Instances|
|Name|TG-DEVOPSTEAM[XX]|
|Protocol and port|Refer to the infra schema|
|Ip Address type|IPv4|
|VPC|Refer to the infra schema|
|Protocol version|HTTP1|
|Health check protocol|HTTP|
|Health check path|/|
|Port|Traffic port|
|Healthy threshold|2 consecutive health check successes|
|Unhealthy threshold|2 consecutive health check failures|
|Timeout|5 seconds|
|Interval|10 seconds|
|Success codes|200|

```bash
[INPUT]
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

[OUTPUT]
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_alb_target_group.tg_drupal will be created
  + resource "aws_alb_target_group" "tg_drupal" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = (known after apply)
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = "ipv4"
      + lambda_multi_value_headers_enabled = false
      + load_balancer_arns                 = (known after apply)
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_anomaly_mitigation  = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "TG-DEVOPSTEAM03"
      + name_prefix                        = (known after apply)
      + port                               = 8080
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = {
          + "ManagedBy" = "Terraform"
          + "Owner"     = "DEVOPS03"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-03d46c285a2af77ba"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 2
          + interval            = 10
          + matcher             = "200"
          + path                = "/"
          + port                = "8080"
          + protocol            = "HTTP"
          + timeout             = 5
          + unhealthy_threshold = 2
        }
    }

  # aws_alb_target_group_attachment.tg_drupal_att_a will be created
  + resource "aws_alb_target_group_attachment" "tg_drupal_att_a" {
      + id               = (known after apply)
      + target_group_arn = (known after apply)
      + target_id        = "i-0d7d36d4575ff40d2"
    }

  # aws_alb_target_group_attachment.tg_drupal_att_b will be created
  + resource "aws_alb_target_group_attachment" "tg_drupal_att_b" {
      + id               = (known after apply)
      + target_group_arn = (known after apply)
      + target_id        = "i-0ef0132d14189699f"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_alb_target_group.tg_drupal: Creating...
aws_alb_target_group.tg_drupal: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM03/1078f5fc722156ef]
aws_alb_target_group_attachment.tg_drupal_att_a: Creating...
aws_alb_target_group_attachment.tg_drupal_att_b: Creating...
aws_alb_target_group_attachment.tg_drupal_att_a: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM03/1078f5fc722156ef-20240321153139227900000001]
aws_alb_target_group_attachment.tg_drupal_att_b: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM03/1078f5fc722156ef-20240321153139308200000002]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```


## Task 02 Deploy the Load Balancer

[Source](https://aws.amazon.com/elasticloadbalancing/)

* Create the Load Balancer

|Key|Value|
|:--|:--|
|Type|Application Load Balancer|
|Name|ELB-DEVOPSTEAM99|
|Scheme|Internal|
|Ip Address type|IPv4|
|VPC|Refer to the infra schema|
|Security group|Refer to the infra schema|
|Listeners Protocol and port|Refer to the infra schema|
|Target group|Your own target group created in task 01|

Provide the following answers (leave any
field not mentioned at its default value):

```bash
[INPUT]
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

[OUTPUT]
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_alb.alb_drupal will be created
  + resource "aws_alb" "alb_drupal" {
      + arn                                                          = (known after apply)
      + arn_suffix                                                   = (known after apply)
      + desync_mitigation_mode                                       = "defensive"
      + dns_name                                                     = (known after apply)
      + drop_invalid_header_fields                                   = false
      + enable_deletion_protection                                   = false
      + enable_http2                                                 = true
      + enable_tls_version_and_cipher_suite_headers                  = false
      + enable_waf_fail_open                                         = false
      + enable_xff_client_port                                       = false
      + enforce_security_group_inbound_rules_on_private_link_traffic = (known after apply)
      + id                                                           = (known after apply)
      + idle_timeout                                                 = 60
      + internal                                                     = true
      + ip_address_type                                              = "ipv4"
      + load_balancer_type                                           = "application"
      + name                                                         = "ELB-DEVOPSTEAM03"
      + name_prefix                                                  = (known after apply)
      + preserve_host_header                                         = false
      + security_groups                                              = [
          + "sg-0219a396bbd9a3e55",
        ]
      + subnets                                                      = [
          + "subnet-0af8a06cb3c5899be",
          + "subnet-0c80bdfa1913b81d4",
        ]
      + tags_all                                                     = {
          + "ManagedBy" = "Terraform"
          + "Owner"     = "DEVOPS03"
        }
      + vpc_id                                                       = (known after apply)
      + xff_header_processing_mode                                   = "append"
      + zone_id                                                      = (known after apply)
    }

  # aws_alb_listener.listener_internal will be created
  + resource "aws_alb_listener" "listener_internal" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 8080
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)
      + tags_all          = {
          + "ManagedBy" = "Terraform"
          + "Owner"     = "DEVOPS03"
        }

      + default_action {
          + order            = (known after apply)
          + target_group_arn = "arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM03/1078f5fc722156ef"
          + type             = "forward"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_alb.alb_drupal: Creating...
aws_alb.alb_drupal: Still creating... [10s elapsed]
aws_alb.alb_drupal: Still creating... [20s elapsed]
aws_alb.alb_drupal: Still creating... [30s elapsed]
aws_alb.alb_drupal: Still creating... [40s elapsed]
aws_alb.alb_drupal: Still creating... [50s elapsed]
aws_alb.alb_drupal: Still creating... [1m0s elapsed]
aws_alb.alb_drupal: Still creating... [1m10s elapsed]
aws_alb.alb_drupal: Still creating... [1m20s elapsed]
aws_alb.alb_drupal: Still creating... [1m30s elapsed]
aws_alb.alb_drupal: Still creating... [1m40s elapsed]
aws_alb.alb_drupal: Still creating... [1m50s elapsed]
aws_alb.alb_drupal: Still creating... [2m0s elapsed]
aws_alb.alb_drupal: Still creating... [2m10s elapsed]
aws_alb.alb_drupal: Still creating... [2m20s elapsed]
aws_alb.alb_drupal: Still creating... [2m30s elapsed]
aws_alb.alb_drupal: Still creating... [2m40s elapsed]
aws_alb.alb_drupal: Creation complete after 2m42s [id=arn:aws:elasticloadbalancing:eu-west-3:709024702237:loadbalancer/app/ELB-DEVOPSTEAM03/59401174962b2a47]
aws_alb_listener.listener_internal: Creating...
aws_alb_listener.listener_internal: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-west-3:709024702237:listener/app/ELB-DEVOPSTEAM03/59401174962b2a47/13f27b21a69ff25f]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

* Get the ELB FQDN (DNS NAME - A Record)

```bash
[INPUT]
aws elbv2 describe-load-balancers --load-balancer-arns "arn:aws:elasticloadbalancing:eu-west-3:709024702237:loadbalancer/app/ELB-DEVOPSTEAM03/59401174962b2a47"  --query 'LoadBalancers[*].[DNSName]' --output table --profile DEVOPS03 --region eu-west-3

[OUTPUT]
---------------------------------------------------------------------
|                       DescribeLoadBalancers                       |
+-------------------------------------------------------------------+
|  internal-ELB-DEVOPSTEAM03-523815094.eu-west-3.elb.amazonaws.com  |
+-------------------------------------------------------------------+
```

* Get the ELB deployment status

Note : In the EC2 console select the Target Group. In the
       lower half of the panel, click on the **Targets** tab. Watch the
       status of the instance go from **unused** to **initial**.

* Ask the DMZ administrator to register your ELB with the reverse proxy via the private teams channel

* Update your string connection to test your ELB and test it

```bash
//connection string updated
```

* Test your application through your ssh tunneling

```bash
[INPUT]
curl localhost:[local port forwarded]

[OUTPUT]

```

#### Questions - Analysis

* On your local machine resolve the DNS name of the load balancer into
  an IP address using the `nslookup` command (works on Linux, macOS and Windows). Write
  the DNS name and the resolved IP Address(es) into the report.

```
//TODO
```

* From your Drupal instance, identify the ip from which requests are sent by the Load Balancer.

Help : execute `tcpdump port 8080`

```
//TODO
```

* In the Apache access log identify the health check accesses from the
  load balancer and copy some samples into the report.

```
//TODO
```
