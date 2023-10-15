#requester
provider "aws" {
  alias  = "peer"
  region = var.requester_region
}

## accepter 
provider "aws" {
  alias  = "accepter"
  region = var.accepter_region
}