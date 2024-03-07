# CLD - LABO 01
## Task 1
### Create subnet
```
aws ec2 create-subnet \
    --availability-zone eu-west-3a \
    --cidr-block 10.0.3.0/28 \
    --vpc-id vpc-03d46c285a2af77ba \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=SUB-PRIVATE-DEVOPSTEAM03}]"
```

```
{
    "Subnet": {
        "AvailabilityZone": "eu-west-3a",
        "AvailabilityZoneId": "euw3-az1",
        "AvailableIpAddressCount": 11,
        "CidrBlock": "10.0.3.0/28",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "available",
        "SubnetId": "subnet-05ea2ea67df9b8ddf",
        "VpcId": "vpc-03d46c285a2af77ba",
        "OwnerId": "709024702237",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "Name",
                "Value": "SUB-PRIVATE-DEVOPSTEAM03"
            }
        ],
        "SubnetArn": "arn:aws:ec2:eu-west-3:709024702237:subnet/subnet-05ea2ea67df9b8ddf",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        }
    }
}
```

### Create route table
```
aws ec2 create-route-table \
    --vpc-id vpc-03d46c285a2af77ba \
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=RTBLE-PRIVATE-DRUPAL-DEVOPSTEAM03}]"
```

```
{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-0c30f47b974537ee3",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [
            {
                "Key": "Name",
                "Value": "RTBLE-PRIVATE-DRUPAL-DEVOPSTEAM03"
            }
        ],
        "VpcId": "vpc-03d46c285a2af77ba",
        "OwnerId": "709024702237"
    },
    "ClientToken": "a6139631-616e-4a4e-9d8e-95ec3ac7b380"
}
```

### Create routes
```
aws ec2 create-route \
    --route-table-id rtb-0c30f47b974537ee3 \
    --destination-cidr-block 0.0.0.0/0 \
    --instance-id i-085f07b949466919e
```
```
{
    "Return": true
}
```

### Associate route table to subnet
```
aws ec2 associate-route-table \
    --route-table-id rtb-0c30f47b974537ee3 \
    --subnet-id subnet-05ea2ea67df9b8ddf
```
```
{
    "AssociationId": "rtbassoc-06d8b3c2ce05a4ef8",
    "AssociationState": {
        "State": "associated"
    }
}
```

### Create security group
```
aws ec2 create-security-group \
    --group-name SG-PRIVATE-DRUPAL-DEVOPSTEAM03 \
    --vpc-id vpc-03d46c285a2af77ba \
    --description SG-PRIVATE-DRUPAL-DEVOPSTEAM03 \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=SG-PRIVATE-DRUPAL-DEVOPSTEAM03}]"
```
```
{
    "GroupId": "sg-003f6a093f288504c",
    "Tags": [
        {
            "Key": "Name",
            "Value": "SG-PRIVATE-DRUPAL-DEVOPSTEAM03"
        }
    ]
}
```

### Add ingress rule to security group
```
aws ec2 authorize-security-group-ingress \
    --group-id sg-003f6a093f288504c \
    --protocol tcp \
    --port 22 \
    --source-group sg-072f4e9295e67feb5
```
```
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0be755e2ed6d2b9d6	",
            "GroupId": "sg-003f6a093f288504c",
            "GroupOwnerId": "709024702237",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "ReferencedGroupInfo": {
                "GroupId": "sg-072f4e9295e67feb5",
                "UserId": "709024702237"
            }
        }
    ]
}
```

```
aws ec2 authorize-security-group-ingress \
    --group-id sg-003f6a093f288504c \
    --protocol tcp \
    --port 8080 \
    --source-group sg-072f4e9295e67feb5
```
```
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-03506d62433bbe735",
            "GroupId": "sg-003f6a093f288504c",
            "GroupOwnerId": "709024702237",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 8080,
            "ToPort": 8080,
            "ReferencedGroupInfo": {
                "GroupId": "sg-072f4e9295e67feb5",
                "UserId": "709024702237"
            }
        }
    ]
}
```
### Add egress rule to security group
Nothing to do here, by default a security group allows all outbound traffic.

### Create EC2 instance
```
aws ec2 run-instances \
    --image-id ami-00b3a1b7cfab20134 \
    --instance-type "t3.micro" \
    --subnet-id subnet-05ea2ea67df9b8ddf \
    --security-group-ids sg-003f6a093f288504c \
    --key-name CLD_KEY_DRUPAL_DEVOPSTEAM03 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=EC2_PRIVATE_DRUPAL_DEVOPSTEAM03}]'
```
```
{
    "Groups": [],
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-00b3a1b7cfab20134",
            "InstanceId": "i-070d7a93f7203cd41",
            "InstanceType": "t3.micro",
            "KeyName": "CLD_KEY_DRUPAL_DEVOPSTEAM03",
            "LaunchTime": "2024-03-07T15:12:43+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "eu-west-3a",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-10-0-3-9.eu-west-3.compute.internal",
            "PrivateIpAddress": "10.0.3.9",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
            "StateTransitionReason": "",
            "SubnetId": "subnet-05ea2ea67df9b8ddf",
            "VpcId": "vpc-03d46c285a2af77ba",
            "Architecture": "x86_64",
            "BlockDeviceMappings": [],
            "ClientToken": "1dfe1c82-ca4a-4ebd-b610-fc14f781face",
            "EbsOptimized": false,
            "EnaSupport": true,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2024-03-07T15:12:43+00:00",
                        "AttachmentId": "eni-attach-0a02602784354b7ed",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attaching",
                        "NetworkCardIndex": 0
                    },
                    "Description": "",
                    "Groups": [
                        {
                            "GroupName": "SG-PRIVATE-DRUPAL-DEVOPSTEAM03",
                            "GroupId": "sg-003f6a093f288504c"
                        }
                        ],
                    "Ipv6Addresses": [],
                    "MacAddress": "06:6f:ef:43:f1:8b",
                    "NetworkInterfaceId": "eni-009f5d8be6d7eff9e",
                    "OwnerId": "709024702237",
                    "PrivateIpAddress": "10.0.3.9",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateIpAddress": "10.0.3.9"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Status": "in-use",
                    "SubnetId": "subnet-05ea2ea67df9b8ddf",
                    "VpcId": "vpc-03d46c285a2af77ba",
                    "InterfaceType": "interface"
                }
            ],
            "RootDeviceName": "/dev/xvda",
            "RootDeviceType": "ebs",
            "SecurityGroups": [
                {
                    "GroupName": "SG-PRIVATE-DRUPAL-DEVOPSTEAM03",
                    "GroupId": "sg-003f6a093f288504c"
                }
            ],
            "SourceDestCheck": true,
            "StateReason": {
                "Code": "pending",
                "Message": "pending"
            },
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "EC2_PRIVATE_DRUPAL_DEVOPSTEAM03"
                }
            ],
            "VirtualizationType": "hvm",
            "CpuOptions": {
                "CoreCount": 1,
                "ThreadsPerCore": 2
            },
            "CapacityReservationSpecification": {
                "CapacityReservationPreference": "open"
            },
            "MetadataOptions": {
                "State": "pending",
                "HttpTokens": "optional",
                "HttpPutResponseHopLimit": 1,
                "HttpEndpoint": "enabled",
                "HttpProtocolIpv6": "disabled",
                "InstanceMetadataTags": "disabled"
            },
            "EnclaveOptions": {
                "Enabled": false
            },
            "PrivateDnsNameOptions": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            },
            "MaintenanceOptions": {
                "AutoRecovery": "default"
            },
            "CurrentInstanceBootMode": "legacy-bios"
        }
    ],
    "OwnerId": "709024702237",
    "ReservationId": "r-0ada1f94f7a0992fe"
}
```