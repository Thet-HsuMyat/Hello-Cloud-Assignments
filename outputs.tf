output "dashboard_alb_dns" {
  value = aws_lb.dashboard.dns_name
}

output "counting_internal_alb_dns" {
  value = aws_lb.counting.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "dashboard_asg_name" {
  value = aws_autoscaling_group.dashboard.name
}

output "counting_asg_name" {
  value = aws_autoscaling_group.counting.name
}