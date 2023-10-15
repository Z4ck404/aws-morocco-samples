resource "aws_vpc" "my_vpc_prod" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "aws-morocco"
  }

  provider = aws.prod
}