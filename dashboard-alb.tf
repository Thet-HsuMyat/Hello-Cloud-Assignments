resource "aws_lb_target_group" "dashboard" {
  name     = "dashboard-tg"
  port     = 9001
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "dashboard-tg"
  }
}

resource "aws_lb" "dashboard" {
  name               = "dashboard-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.dashboard_alb.id
  ]

  subnets = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id
  ]

  tags = {
    Name = "dashboard-alb"
  }
}

resource "aws_lb_listener" "dashboard" {
  load_balancer_arn = aws_lb.dashboard.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dashboard.arn
  }
}