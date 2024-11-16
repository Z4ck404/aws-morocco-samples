### Define variables

variable "aws_region" {
  default = "us-east-1"
}
### Configure the AWS Provider

provider "aws" {
  region = var.aws_region
}

# variables.tf
variable "encrypted_db_password" {
  description = "KMS encrypted database password"
  type        = string
  default     = "AQICAHhw31bEpV7TSsANCrrf6ZKimnQvVlNeIPn2xFDmUQPjOAGLFV0lcS4XiuwfqRIC1YI+AAAAdjB0BgkqhkiG9w0BBwagZzBlAgEAMGAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM/MZEgbuuMwVNBHJ1AgEQgDNUMmkSJO/f1t5w5JIWLc2MmGyU4/Az5IypmMuTTShUqRArmYsyzvA/G54jekuCyip7VmA="

  # the best way is to use a valuesfiles: terraform.tfvars
  # encrypted_db_password = "AQICAHhw31bEpV7TSsANCrrf6ZKimnQvVlNeIPn2xFDmUQPjOAGLFV0lcS4XiuwfqRIC1YI+AAAAdjB0BgkqhkiG9w0BBwagZzBlAgEAMGAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM/MZEgbuuMwVNBHJ1AgEQgDNUMmkSJO/f1t5w5JIWLc2MmGyU4/Az5IypmMuTTShUqRArmYsyzvA/G54jekuCyip7VmA="
}

variable "encrypted_api_key" {
  type    = string
  default = ""
}

### data sources

data "aws_kms_secrets" "application_secrets" {
  secret {
    name    = "db_password"
    payload = var.encrypted_db_password
  }

  # You can decrypt multiple secrets in one block
  # secret {
  #   name    = "api_key"
  #   payload = var.encrypted_api_key
  # }
}

# Access the decrypted value
locals {
  db_password = data.aws_kms_secrets.application_secrets.plaintext["db_password"]
  #api_key     = data.aws_kms_secrets.application_secrets.plaintext["api_key"]
}


### Provision resources and provide the decrypted values

resource "aws_db_instance" "db" {
  identifier           = "awsmorocco-db"
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = "awsmorocco-admin-user-1"
  password             = local.db_password # Using the decrypted 
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  allocated_storage    = 10
}
