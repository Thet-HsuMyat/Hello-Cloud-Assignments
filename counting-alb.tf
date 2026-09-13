resource "aws_lb_target_group" "counting" {
  name     = "counting-tg"
  port     = 9002
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "counting-tg"
  }
}

resource "aws_lb" "counting" {
  name               = "counting-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.counting_alb.id
  ]

  subnets = [
    aws_subnet.counting_private_subnet1.id,
    aws_subnet.counting_private_subnet2.id
  ]

  tags = {
    Name = "counting-alb"
  }
}

resource "aws_lb_listener" "counting" {
  load_balancer_arn = aws_lb.counting.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.counting.arn
  }
}