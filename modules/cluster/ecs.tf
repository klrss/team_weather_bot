/*
data "template_file" "cb_bot" {
  template = file(var.taskdef_template)
  vars = {
    app_image      = local.app_image
    app_port       = var.app_port
    #aws_region     = var.aws_region
    env            = var.environment
    app_name       = var.app_name
    image_tag      = var.image_tag
  }
}
*/
resource "aws_ecs_cluster" "aws_ecs_cluster" {
  depends_on = [
    aws_ecs_capacity_provider.capacity_provider,
    aws_autoscaling_group.autoscale
  ]
  name = "${var.app_name}-${var.environment}-cluster"
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]
  tags = {
    Name = "${var.app_name}-${var.environment}-cluster"
  }
}

resource "aws_ecs_task_definition" "aws_ecs_task" {
  family = "${var.app_name}-${var.environment}-task"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  #container_definitions    = data.template_file.cb_bot.rendered
  container_definitions     = jsonencode(
[
  {
    name = "${var.app_name}-${var.environment}-container"
    image = "${local.app_image}"
    memory = 512
    cpu = 256
    essential = true
    
    portMappings = [
      {
        "containerPort": var.app_port,
        "hostPort": var.app_port
      }
    ]
  }
])

}


resource "aws_ecs_service" "main" {
  depends_on = [aws_alb_listener.listener, aws_iam_role.ecsTaskExecutionRole]
  name            = "${var.app_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.aws_ecs_cluster.id
  task_definition = aws_ecs_task_definition.aws_ecs_task.arn
  desired_count   = 2
  deployment_minimum_healthy_percent = "90"


  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.environment}-container"
    container_port   = var.app_port
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
    weight = 1
    base = 0
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.app_name}-${var.environment}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.autoscale.arn
    managed_termination_protection = "DISABLED"
  
    managed_scaling {
      maximum_scaling_step_size = var.az_count*2
      minimum_scaling_step_size = 2
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}
