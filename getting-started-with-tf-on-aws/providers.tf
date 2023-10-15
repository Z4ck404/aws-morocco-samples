terraform {

  backend "s3" {
    bucket         = "awsmorocco-terraform-states"
    key            = "awsmorcco/network"
    dynamodb_table = "aws-morocco-tf-backend"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.21.0"
    }
  }
}

provider "aws" {
  profile = "aws-admin"
  alias   = "prod"
}


