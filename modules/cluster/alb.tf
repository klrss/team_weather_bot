resource "aws_alb" "application_load_balancer" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.security_group_port_i80.id]
  tags = {
    Name        = "${var.app_name}-${var.environment}-alb"
  }
}

resource "aws_alb_target_group" "target_group" {
  depends_on = [ aws_alb.application_load_balancer ]
  name        = "${var.app_name}-${var.environment}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  
  health_check {
    healthy_threshold   = 2
    interval            = 15
    protocol            = "HTTP"
    port               =  80
    matcher             = 200
    timeout             = 10
    path                = "/"
    unhealthy_threshold = 2
  }
  tags = {
    Name   = "${var.app_name}-${var.environment}-alb-tg"
  }
}
resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = var.app_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = [aws_alb_target_group.target_group,
                  aws_alb_listener.listener]  
  listener_arn = aws_alb_listener.listener.arn  

  action {    
    type             = "forward"    
    target_group_arn = aws_alb_target_group.target_group.arn  
  }   
  condition {
    path_pattern {
      values = ["/"]
    }        
  }
}