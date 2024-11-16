resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for encrypting application secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/awsmorocco-key"
  target_key_id = aws_kms_key.secrets_key.key_id
}


resource "aws_kms_key_policy" "example" {
  key_id = aws_kms_key.secrets_key.id
  policy = jsonencode({
    Id = "example"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}

