terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  # Four /20 networks per AZ, in public-web, private-web, private-app, private-db order.
  subnet_cidrs = [
    ["10.0.0.0/20", "10.0.48.0/20", "10.0.96.0/20", "10.0.144.0/20"],
    ["10.0.16.0/20", "10.0.64.0/20", "10.0.112.0/20", "10.0.160.0/20"],
    ["10.0.32.0/20", "10.0.80.0/20", "10.0.128.0/20", "10.0.176.0/20"],
  ]
}
