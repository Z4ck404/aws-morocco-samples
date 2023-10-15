# Get Started with Terraform on AWS : 
-> Medium blog for detailed instructions : [Getting Started With Terraform on AWS](https://awsmorocco.com/get-started-with-terraform-on-aws-1de0b6deb085)

This guide provides a quick overview of how to use Terraform with Amazon Web Services (AWS). If you're already familiar with Terraform basics and have some AWS knowledge, you can jump right into the practical aspects.

## Prerequisites

- AWS account.
- AWS CLI and Terraform CLI installed.
- Basic Terraform and AWS knowledge.

## Setting Up Terraform for AWS

1. Create an AWS IAM user with admin access for Terraform.
2. Generate Access Keys for the user.
3. Configure an AWS profile for Terraform using `aws configure`.
4. Define the AWS provider in your Terraform project.

```hcl
provider "aws" {
  profile = "aws-admin"
  region  = "your-region"
}
```

## Terraform S3 State Backend with State Locking

- Use an S3 bucket for state storage with versioning.
- Add configurations for S3 state backend in your `providers.tf`.

```hcl
terraform {
  backend "s3" {
    bucket = "<your-bucket>"
    key    = "path/to/terraform.tfstate"
    region = "<your-region>"
  }
}
```

## Terraform S3 State Locking

- Create a DynamoDB table in the same region as your S3 bucket with a String partition key (LockID).
- Add configurations for state locking in your `providers.tf`.

```hcl
terraform {
  backend "s3" {
    bucket = "<your-bucket>"
    key    = "terraform.tfstate"
    region = "<your-region>"
    dynamodb_table = "<your-locking-table>"
  }
}
```