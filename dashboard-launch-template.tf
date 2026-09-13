resource "aws_launch_template" "dashboard" {
  name_prefix   = "dashboard-lt-"
  image_id      = var.dashboard_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.dashboard.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash

    cat > /etc/dashboard.env <<EOT
    PORT=9001
    COUNTING_SERVICE_URL=http://${aws_lb.counting.dns_name}
    EOT

    chown root:root /etc/dashboard.env
    chmod 644 /etc/dashboard.env

    systemctl daemon-reload
    systemctl restart dashboard
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "dashboard-asg-instance"
      App  = "dashboard"
    }
  }
}