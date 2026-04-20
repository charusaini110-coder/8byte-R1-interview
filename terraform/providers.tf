terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state management via S3 and DynamoDB for locking
  # Note: Backend configuration uses static values (no interpolation)
  # Update the bucket name with your AWS account ID after running backend-setup
 /* backend "s3" {
    bucket         = "8byte-tf-state-123456789012"  # Replace with your account ID
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    //dynamodb_table = "8byte-tf-lock"
    encrypt        = true
  }*/
}

provider "aws" {
  region = var.aws_region
}

# Data source to get current AWS account ID for reference
data "aws_caller_identity" "current" {}