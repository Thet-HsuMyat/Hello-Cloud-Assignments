resource "aws_autoscaling_group" "counting" {
  name = "counting-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.counting_private_subnet1.id,
    aws_subnet.counting_private_subnet2.id
  ]

  target_group_arns = [
    aws_lb_target_group.counting.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.counting.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "counting-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "counting_cpu" {
  name                   = "counting-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.counting.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}