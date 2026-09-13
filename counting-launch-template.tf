resource "aws_launch_template" "counting" {
  name_prefix   = "counting-lt-"
  image_id      = var.counting_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.counting.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "counting-asg-instance"
      App  = "counting"
    }
  }
}