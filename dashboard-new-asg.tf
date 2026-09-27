resource "aws_autoscaling_group" "dashboard_new" {
  name = "dashboard-new-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  vpc_zone_identifier = [
    aws_subnet.dashboard_private_subnet1.id,
    aws_subnet.dashboard_private_subnet2.id
  ]

  target_group_arns = [
    aws_lb_target_group.dashboard_new.arn
  ]

  launch_template {
    id      = aws_launch_template.dashboard_new.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "dashboard-new"
    propagate_at_launch = true
  }

  tag {
    key                 = "Version"
    value               = "v2-green"
    propagate_at_launch = true
  }
}