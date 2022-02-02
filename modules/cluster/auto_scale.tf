resource "aws_launch_configuration" "ecs_ec2_launch_config" {
    image_id             = data.aws_ami.latest_amazon_linux.id
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.security_group_port_i80.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.app_name}-${var.environment}-cluster >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"

    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscale" {
    name                      = "${var.app_name}-${var.environment}-auto-asg"
    depends_on                = [aws_launch_configuration.ecs_ec2_launch_config]
    vpc_zone_identifier       = [for subnet in aws_subnet.private : subnet.id]
    launch_configuration      = aws_launch_configuration.ecs_ec2_launch_config.name
    target_group_arns         = [aws_alb_target_group.target_group.arn]
    min_size                  = var.az_count
    max_size                  = var.az_count*2
    
    health_check_grace_period = 20
    health_check_type         = "EC2"

     tag {
    key                 = "Name"
    value               = "${var.app_name}-${var.environment}-ec2-ecs"
    propagate_at_launch = true
  }
}