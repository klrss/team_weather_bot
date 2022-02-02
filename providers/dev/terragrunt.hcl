locals {
environment         = "dev"
app_name            = "bot"
aws_profile         = "default"
aws_account         = "064173783062"
aws_region          = "eu-central-1"
image_tag           = "0.0.1"
app_count           = 2
github_path_url     = "https://github.com/Yagorus/team_weather_bot"
git_trigger        = "PUSH"
git_pattern_branch  = "^refs/heads/terragrunt$"
buildspec_path      = "providers/dev"
buildspec_file      = "buildspec.yml"
working_dir         =  "../../bot"
}

inputs = {
    git_pattern_branch  = local.git_pattern_branch
    bucket_name     = format("%s-%s-s3", local.app_name, local.environment)
    environment     = local.environment
    app_name        = local.app_name
    aws_profile     = local.aws_profile
    aws_account     = local.aws_account
    aws_region      = local.aws_region
    image_tag       = local.image_tag
    app_count       = local.app_count
    git_trigger     = local.git_trigger
    github_path_url = local.github_path_url
    buildspec_path  = local.buildspec_path
    working_dir     = local.working_dir
    buildspec_file  = local.buildspec_file
}

remote_state {
    backend = "s3" 

    config = {
        encrypt = true
        bucket = format("%s-%s-s3", local.app_name, local.environment)
        key =  format("%s/terraform.tfstate", path_relative_to_include())
        region  = local.aws_region
        profile = local.aws_profile
  }
}
