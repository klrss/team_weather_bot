resource "null_resource" "build" {
  provisioner "local-exec" {
    command = "make build"
    working_dir = var.working_dir
    environment = {
        TAG = var.image_tag
        REGISTRY_ID = data.aws_caller_identity.current.account_id
        REPOSITORY_REGION = var.aws_region
        APP_NAME = var.app_name
        ENV_NAME = var.environment
        BOT_TOKEN = data.aws_ssm_parameter.bot_token.value
        API_KEY = data.aws_ssm_parameter.bot_key.value
    }
  }
}
