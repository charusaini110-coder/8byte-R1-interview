resource "aws_lb" "frontend_alb" {
  name               = "8byte-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = merge(
    {
      Environment = var.environment
      Name        = "8byte-alb-${var.environment}"
    },
    var.tags
  )
}

resource "aws_lb_target_group" "app_tg" {
  name        = "8byte-app-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = merge(
    {
      Environment = var.environment
      Name        = "8byte-app-tg-${var.environment}"
    },
    var.tags
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
