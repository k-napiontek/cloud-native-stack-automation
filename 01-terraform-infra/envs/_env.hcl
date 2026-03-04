locals {
  aws_region  = "eu-central-1"
  project     = "myapp"
  azs         = ["eu-central-1b", "eu-central-1c"] # c7i-flex.large only supports eu-central-1b and eu-central-1c
  domain_root = "bzyk0945.site" 
}
