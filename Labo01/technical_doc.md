# CLD - LABO 00
## Réalisation
### Create subnet
```
aws ec2 create-subnet ^
    --availability-zone eu-west-3a \
    --cidr-block 10.0.3.0/28 \
    --vpc-id vpc-03d46c285a2af77ba \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=SUB-DEVOPSTEAM03}]"
```

### Create security group
```
aws ec2 create-security-group \
    --group-name SG-DEVOPSTEAM03 \
    --vpc-id vpc-03d46c285a2af77ba \
    --description SG-DEVOPSTEAM03 \
    --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=SG-DEVOPSTEAM03}]"
```

### Add ingress rule to security group
```
aws ec2 authorize-security-group-ingress \
    --group-id sg-0a39399601cc0d43c \
    --protocol tcp \
    --port 22 \
    --source-group sg-0ab7c74f2244ebf8c

aws ec2 authorize-security-group-ingress \
    --group-id sg-0a39399601cc0d43c \
    --protocol tcp \
    --port 8080 \
    --source-group sg-0ab7c74f2244ebf8c
```
### Add egress rule to security group
Nothing to do here, by default a security group allows all outbound traffic.

### Create EC2 instance
```
aws ec2 run-instances \
    --image-id ami-03f12ae727bb56d85 \
    --instance-type "t3.micro" \
    --subnet-id subnet-00e69b33ca1355d49 \
    --security-groups sg-0a39399601cc0d43c \
    --key-name CLD_KEY_DMZ_SSH_CLD_DEVOPSTEAM03 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=EC2-DEVOPSTEAM03}]'
```