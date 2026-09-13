resource "aws_security_group" "dashboard_alb" {
  name        = "dashboard-alb-sg"
  description = "Security group for Dashboard public ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "dashboard-alb-sg"
  }
}

resource "aws_security_group" "dashboard" {
  name        = "dashboard-sg"
  description = "Security group for Dashboard EC2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "dashboard-sg"
  }
}

resource "aws_security_group" "counting_alb" {
  name        = "counting-alb-sg"
  description = "Security group for Counting ALB"
  vpc_id      = aws_vpc.main.id

  # ingress {
  #   description = "Http from Dashboard EC2"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_security_group.dashboard.id]
  # }

  # egress {
  #   description     = "Counting Application"
  #   from_port       = 9002
  #   to_port         = 9002
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.counting.id]
  # }

  tags = {
    Name = "counting-alb-sg"
  }
}

resource "aws_security_group" "counting" {
  name        = "counting-sg"
  description = "Security group for Counting EC2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "counting-sg"
  }
}

resource "aws_security_group" "jump" {
  name   = "jump-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "jump-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "dashboard_alb_http" {
  security_group_id = aws_security_group.dashboard_alb.id
  # from_port         = 80
  # to_port           = 80
  # ip_protocol       = "tcp"
  # cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "dashboard_alb_to_dashboard" {
  security_group_id            = aws_security_group.dashboard_alb.id
  referenced_security_group_id = aws_security_group.dashboard.id
  from_port                    = 9001
  to_port                      = 9001
  ip_protocol                  = "tcp"

}

resource "aws_vpc_security_group_ingress_rule" "dashboard_from_dashboard_alb" {
  security_group_id            = aws_security_group.dashboard.id
  referenced_security_group_id = aws_security_group.dashboard_alb.id
  from_port                    = 9001
  to_port                      = 9001
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "dashboard_to_counting_alb" {
  security_group_id            = aws_security_group.dashboard.id
  referenced_security_group_id = aws_security_group.counting_alb.id
  # from_port                    = 80
  # to_port                      = 80
  # ip_protocol                  = "tcp"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

}

resource "aws_vpc_security_group_ingress_rule" "counting_alb_from_dashboard" {
  security_group_id            = aws_security_group.counting_alb.id
  referenced_security_group_id = aws_security_group.dashboard.id
  # from_port                    = 80
  # to_port                      = 80
  # ip_protocol                  = "tcp"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "counting_alb_to_counting" {
  security_group_id            = aws_security_group.counting_alb.id
  referenced_security_group_id = aws_security_group.counting.id
  from_port                    = 9002
  to_port                      = 9002
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "counting_from_counting_alb" {
  security_group_id            = aws_security_group.counting.id
  referenced_security_group_id = aws_security_group.counting_alb.id
  from_port                    = 9002
  to_port                      = 9002
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "jump_ssh" {
  security_group_id = aws_security_group.jump.id

  cidr_ipv4   = "130.62.145.0/32"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "dashboard_ssh_from_jump" {
  security_group_id = aws_security_group.dashboard.id

  referenced_security_group_id = aws_security_group.jump.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "counting_ssh_from_jump" {
  security_group_id = aws_security_group.counting.id

  referenced_security_group_id = aws_security_group.jump.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "jump_to_dashboard_ssh" {
  security_group_id = aws_security_group.jump.id

  referenced_security_group_id = aws_security_group.dashboard.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "jump_to_counting_ssh" {
  security_group_id = aws_security_group.jump.id

  referenced_security_group_id = aws_security_group.counting.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}