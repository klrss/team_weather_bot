
terraform {
    source = "../../../modules//codebuild"
}

include {
    path = find_in_parent_folders()
}

locals {
  #file secrets.hcl is placed in /module/code-build/ folder
  #secrets = read_terragrunt_config("../../../modules/codebuild/secrets.hcl")

  secrets = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}


dependency "cluster" {
    config_path = "../cluster"
    mock_outputs = {
        vpc_id = "vpc-000000000000"
        subnets = ["subnet-222222222222", "subnet-333333333333"]
      
  }
}

dependency "ecr" {
    config_path = "../ecr"
    mock_outputs = {
      ecr_repository_url = "000000000000.dkr.ecr.eu-west-1.amazonaws.com/image"
  }
}

  inputs = merge(
    local.secrets.inputs,
    {
    vpc_id = dependency.cluster.outputs.vpc_id
    subnets = dependency.cluster.outputs.subnets
    }
  )