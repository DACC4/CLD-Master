terraform {
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-3"
  profile = "DEVOPS03"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Owner     = "DEVOPS03"
    }
  }
}