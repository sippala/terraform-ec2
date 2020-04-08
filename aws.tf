terraform {
 required_version = ">= 0.10.3" 
 backend "s3" {
   encrypt = true
   region = "us-west-2"
 }
}

provider "aws" {
  region = "us-west-2"
 
  assume_role {
    role_arn= "${local.this_role_arn}"
  }
}

provider "kubernetes" {}
