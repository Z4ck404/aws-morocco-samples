provider "aws" {
  alias  = "consumer"
  region = "us-east-1"
}

provider "aws" {
  alias  = "service_provider"
  region = "us-west-2"
}

provider "aws" {
  alias  = "service_provider_outpost"
  region = "us-west-2"
}

