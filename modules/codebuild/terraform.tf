provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "s3" { }
  required_providers {
    aws = {
      version = "~> 3.74"
    }
  }
}