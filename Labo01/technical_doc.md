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
    --source-group sg-0c71f4ea753e23037
```
```
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-03e40658b4bc63dd0",
            "GroupId": "sg-003f6a093f288504c",
            "GroupOwnerId": "709024702237",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "ReferencedGroupInfo": {
                "GroupId": "sg-0c71f4ea753e23037",
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
    --source-group sg-0c71f4ea753e23037
```
```
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0a99eb260bbc4fce5",
            "GroupId": "sg-003f6a093f288504c",
            "GroupOwnerId": "709024702237",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 8080,
            "ToPort": 8080,
            "ReferencedGroupInfo": {
                "GroupId": "sg-0c71f4ea753e23037",
                "UserId": "709024702237"
            }
        }
    ]
}
```
### Add egress rule to security group
Nothing to do here, by default a security group allows all outbound traffic.

<!-- ### Create EC2 instance
```
aws ec2 run-instances \
    --image-id ami-03f12ae727bb56d85 \
    --instance-type "t3.micro" \
    --subnet-id subnet-00e69b33ca1355d49 \
    --security-groups sg-0a39399601cc0d43c \
    --key-name CLD_KEY_DMZ_SSH_CLD_DEVOPSTEAM03 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=EC2-DEVOPSTEAM03}]'
``` -->