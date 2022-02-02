terraform {
  source = "../../../modules//initbuild"
}

include {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
  skip_outputs = true
}

inputs = merge(
    local.secrets.inputs,
  {
    working_dir = format("%s/../../../bot", get_terragrunt_dir())
  }
)


locals {
  #file secrets.hcl is placed in /module/code-build/ folder
  #secrets = read_terragrunt_config("../../../modules/ecr/secrets.hcl")
  secrets = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}