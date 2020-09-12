# Application loadbalancer configurations for ECS service

resource "aws_lb" "ecs_alb" {
  name               = "issueapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = true
}

resource "aws_security_group" "ecs_alb_sg" {
  name        = "container-lb-sg"
  vpc_id      = aws_vpc.VPC.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.issueapp.arn
  }
}

resource "aws_lb_target_group" "issueapp" {
  name     = "issueapp-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id
  target_type = "ip"

  # Should configure this differently for production purposes 
  health_check {
    path   = "/actuator/health"
    port   = 8080
  }

  # aws_lb resource needs to be created before target group is
  # linked to ECS service
  depends_on = [
    aws_lb.ecs_alb
  ]
}

