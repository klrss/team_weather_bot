resource "aws_ecr_repository" "ecr_repository" {
  name = local.aws_ecr_name
}
