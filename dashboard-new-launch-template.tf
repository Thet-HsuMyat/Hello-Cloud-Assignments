resource "aws_launch_template" "dashboard_new" {
  name_prefix   = "dashboard-new-"
  image_id      = var.dashboard_new_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.dashboard.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "dashboard-new"
      Version = "v2-green"
    }
  }
}