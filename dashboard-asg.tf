resource "aws_autoscaling_group" "dashboard" {
  name = "dashboard-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.dashboard_private_subnet1.id,
    aws_subnet.dashboard_private_subnet2.id
  ]

  target_group_arns = [
    aws_lb_target_group.dashboard.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.dashboard.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "dashboard-asg-instance"
    propagate_at_launch = true
  }
}

#target tracking
resource "aws_autoscaling_policy" "dashboard_cpu" {
  name                   = "dashboard-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.dashboard.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}