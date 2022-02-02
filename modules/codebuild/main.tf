resource "aws_codebuild_source_credential" "github_token" {
  auth_type = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token = var.token_git
}

resource "aws_codebuild_project" "project" {
  depends_on = [aws_codebuild_source_credential.github_token]
  name = "${var.app_name}-${var.environment}-code-build-project"
  description = "test"
  build_timeout = "60"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
}

# https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
# https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html

  environment {
    compute_type = "BUILD_GENERAL1_SMALL" # 7 GB memory
    image = "aws/codebuild/standard:4.0"
    type = "LINUX_CONTAINER"
    # The privileged flag must be set so that your project has the required Docker permissions
    privileged_mode = true

    environment_variable {
      name = "provider"
      value = var.environment
    }
  }

  source {
    buildspec = "${var.buildspec_path}/${var.buildspec_file}"
    type = "GITHUB"
    location = var.github_path_url
    git_clone_depth = 1
    report_build_status = "true"
  }

vpc_config {
    vpc_id = var.vpc_id
    subnets = var.subnets
    security_group_ids = [ aws_security_group.sg_codebuild.id ]
  }
}

resource "aws_codebuild_webhook" "develop_webhook" {
  project_name = aws_codebuild_project.project.name

  # https://docs.aws.amazon.com/codebuild/latest/APIReference/API_WebhookFilter.html
  filter_group {
    filter {
      type = "EVENT"
      pattern = var.git_trigger
    }

    filter {
      type = "HEAD_REF"
      pattern = var.git_pattern_branch
    }
  }
}