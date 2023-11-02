# Exploring Steampipe for Terrafom drift detection : 
-> Medium blog for detailed instructions : [Exploring Steampipe for Terrafom drift detection](https://awsmorocco.com/exploring-steampipe-for-terraform-drift-detection-4cc4536f6cb5)


## Prerequisites

- AWS account.
- Steampipe CLI.

## Setup Terraform with Steampipe:

```
steampipe plugin install terraform

```

## Configure the Steampipe Terraform plugin

The config file can be found in : `~/.steampipe/config/aws.spc` : 

```
connection "terraform" {
  plugin = "terraform"

  # configuration_file_paths = [
  #  "github.com/Z4ck404/aws-morocco-samples//getting-started-with-tf-on-aws",
  # ]
  
  state_file_paths = [
    "s3::https://awsmorocco-terraform-states.s3.us-east-1.amazonaws.com/awsmorcco/network",
  ]
}

```

## Update the SQL Queries / Script and run it:

The example script compares VPC resources: `./compare_vpc.sh`