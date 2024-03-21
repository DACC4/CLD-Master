# Custom AMI and Deploy the second Drupal instance

In this task you will update your AMI with the Drupal settings and deploy it in the second availability zone.

## Task 01 - Create AMI

### [Create AMI](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-image.html)

Note : stop the instance before

|Key|Value for GUI Only|
|:--|:--|
|Name|AMI_DRUPAL_DEVOPSTEAM[XX]_LABO02_RDS|
|Description|Same as name value|

```bash
[INPUT]
resource "aws_ami_from_instance" "drupal" {
  name               = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
  description        = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
  source_instance_id = aws_instance.drupal_a.id

  tags = {
    Name = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
  }
}

[OUTPUT]
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ami_from_instance.drupal will be created
  + resource "aws_ami_from_instance" "drupal" {
      + architecture         = (known after apply)
      + arn                  = (known after apply)
      + boot_mode            = (known after apply)
      + description          = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
      + ena_support          = (known after apply)
      + hypervisor           = (known after apply)
      + id                   = (known after apply)
      + image_location       = (known after apply)
      + image_owner_alias    = (known after apply)
      + image_type           = (known after apply)
      + imds_support         = (known after apply)
      + kernel_id            = (known after apply)
      + manage_ebs_snapshots = (known after apply)
      + name                 = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
      + owner_id             = (known after apply)
      + platform             = (known after apply)
      + platform_details     = (known after apply)
      + public               = (known after apply)
      + ramdisk_id           = (known after apply)
      + root_device_name     = (known after apply)
      + root_snapshot_id     = (known after apply)
      + source_instance_id   = "i-0d7d36d4575ff40d2"
      + sriov_net_support    = (known after apply)
      + tags                 = {
          + "Name" = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
        }
      + tags_all             = {
          + "ManagedBy" = "Terraform"
          + "Owner"     = "DEVOPS03"
          + "Name" = "AMI_DRUPAL_DEVOPSTEAM03_LABO02_RDS"
        }
      + tpm_support          = (known after apply)
      + usage_operation      = (known after apply)
      + virtualization_type  = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_ami_from_instance.drupal: Creating...
aws_ami_from_instance.drupal: Still creating... [10s elapsed]
aws_ami_from_instance.drupal: Still creating... [20s elapsed]
aws_ami_from_instance.drupal: Still creating... [30s elapsed]
aws_ami_from_instance.drupal: Still creating... [40s elapsed]
aws_ami_from_instance.drupal: Still creating... [50s elapsed]
aws_ami_from_instance.drupal: Still creating... [1m0s elapsed]
aws_ami_from_instance.drupal: Still creating... [1m10s elapsed]
aws_ami_from_instance.drupal: Still creating... [1m20s elapsed]
aws_ami_from_instance.drupal: Still creating... [1m30s elapsed]
aws_ami_from_instance.drupal: Still creating... [1m40s elapsed]
aws_ami_from_instance.drupal: Still creating... [1m50s elapsed]
aws_ami_from_instance.drupal: Still creating... [2m0s elapsed]
aws_ami_from_instance.drupal: Still creating... [2m10s elapsed]
aws_ami_from_instance.drupal: Still creating... [2m20s elapsed]
aws_ami_from_instance.drupal: Still creating... [2m30s elapsed]
aws_ami_from_instance.drupal: Still creating... [2m40s elapsed]
aws_ami_from_instance.drupal: Still creating... [2m50s elapsed]
aws_ami_from_instance.drupal: Still creating... [3m0s elapsed]
aws_ami_from_instance.drupal: Creation complete after 3m7s [id=ami-067fbd29c40befdc0]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Task 02 - Deploy Instances

* Restart Drupal Instance in Az1

* Deploy Drupal Instance based on AMI in Az2

|Key|Value for GUI Only|
|:--|:--|
|Name|EC2_PRIVATE_DRUPAL_DEVOPSTEAM[XX]_B|
|Description|Same as name value|

```bash
[INPUT]
resource "aws_instance" "drupal_b" {
  ami                    = data.aws_ami.drupal.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_b.id
  private_ip             = "10.0.3.140"
  vpc_security_group_ids = [aws_security_group.sg_drupal.id]
  key_name               = data.aws_key_pair.kp_drupal.key_name

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03_B"
  }
}

[OUTPUT]
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.drupal_b will be created
  + resource "aws_instance" "drupal_b" {
      + ami                                  = "ami-067fbd29c40befdc0"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "CLD_KEY_DRUPAL_DEVOPSTEAM03"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = "10.0.3.140"
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = "subnet-0c80bdfa1913b81d4"
      + tags                                 = {
          + "Name" = "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03_B"
        }
      + tags_all                             = {
          + "ManagedBy" = "Terraform"
          + "Name"      = "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03_B"
          + "Owner"     = "DEVOPS03"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = [
          + "sg-003f6a093f288504c",
        ]
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.drupal_b: Creating...
aws_instance.drupal_b: Still creating... [10s elapsed]
aws_instance.drupal_b: Creation complete after 13s [id=i-0ef0132d14189699f]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Task 03 - Test the connectivity

### Update your ssh connection string to test

* add tunnels for ssh and http pointing on the B Instance

```bash
//updated string connection
ssh devopsteam03@15.188.43.46 -i CLD_KEY_DMZ_DEVOPSTEAM03.pem -L 2222:10.0.3.140:22 -L 8880:10.0.3.140:8080
ssh -o StrictHostKeyChecking=no bitnami@localhost -p 2222 -i CLD_KEY_DRUPAL_DEVOPSTEAM03.pem  
```

## Check SQL Accesses

```sql
[INPUT]
//sql string connection from A
bitnami@ip-10-0-3-10:~$ mariadb -h dbi-devopsteam03.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u admin -p

[OUTPUT]
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 282
Server version: 10.11.7-MariaDB managed by https://aws.amazon.com/rds/

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
| innodb             |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.002 sec)
```

```sql
[INPUT]
//sql string connection from B
bitnami@ip-10-0-3-140:~$ mariadb -h dbi-devopsteam03.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u admin -p


[OUTPUT]
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 285
Server version: 10.11.7-MariaDB managed by https://aws.amazon.com/rds/

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
| innodb             |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.001 sec)
```

### Check HTTP Accesses

```bash
//connection string updated
ssh devopsteam03@15.188.43.46 -i CLD_KEY_DMZ_DEVOPSTEAM03.pem -L 2222:10.0.3.10:22 -L 8880:10.0.3.10:8080 -L 2222:10.0.3.140:22 -L 8881:10.0.3.140:8080
```

### Read and write test through the web app

* Login in both webapps (same login)

* Change the users' email address on a webapp... refresh the user's profile page on the second and validated that they are communicating with the same db (rds).

* Observations ?

```
They are the same on both, both are successfully using to the same RDS.
```

### Change the profil picture

* Observations ?

```
L'image ne s'affiche pas correctement sur la deuxième instance -> elle est stockée en local sur l'autre instance. Cette image n'est pas stockée dans la base de données.
```