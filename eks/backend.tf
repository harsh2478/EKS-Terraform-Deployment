terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote Backend 
  backend "s3" {
    bucket         = "terraform-state-backend-40490"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws-region
}

