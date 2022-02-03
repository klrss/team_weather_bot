resource "null_resource" "build" {
  depends_on = [
    aws_ssm_parameter.token,
    aws_ssm_parameter.key
  ]
  provisioner "local-exec" {
    command = "make build"
    working_dir = var.working_dir
    environment = {
        TAG = var.image_tag
        REGISTRY_ID = data.aws_caller_identity.current.account_id
        REPOSITORY_REGION = var.aws_region
        APP_NAME = var.app_name
        ENV_NAME = var.environment

        APP_TOKEN = data.aws_ssm_parameter.bot_token.value
        APP_WEATHER_KEY = data.aws_ssm_parameter.bot_key.value
    }
  }
}
