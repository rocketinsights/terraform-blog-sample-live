include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:rocketinsights/terraform-blog-sample-module.git?ref=v0.0.1"
}

inputs = {
  # Override default module variables with environment
  # specific examples.
  aws_region = "us-east-1"
}

