#!/bin/bash

# 1. Fetch data from AWS plugin
steampipe query "
SELECT
  vpc_id,
  arn,
  cidr_block,
  dhcp_options_id,
  instance_tenancy,
  owner_id,
  tags
FROM
  aws_morocco.aws_vpc
WHERE is_default = false;" --output csv > aws_output.csv

# 2. Fetch data from Terraform state
steampipe query "
SELECT
  attributes_std ->> 'id' AS vpc_id,
  attributes_std ->> 'arn' AS arn,
  attributes_std ->> 'cidr_block' AS cidr_block,
  attributes_std ->> 'dhcp_options_id' AS dhcp_options_id,
  attributes_std ->> 'instance_tenancy' AS instance_tenancy,
  attributes_std ->> 'owner_id' AS owner_id,
  attributes_std ->> 'tags' AS tags
FROM
  terraform_resource
WHERE
  type = 'aws_vpc';" --output csv > tf_output.csv

# 3. Compare the two CSV files using diff
diff -i -w aws_output.csv tf_output.csv > differences.txt

# 4. Check if there are differences
if [ -s differences.txt ]; then
    echo "Differences found! Check the differences.txt file."
else
    echo "No differences found!"
    rm differences.txt
fi

# Clean up
rm aws_output.csv tf_output.csv