resource "aws_instance" "jump" {
  ami                    = "ami-053ea429a1c73a5b7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.jump.id]
  key_name               = var.key_name

  associate_public_ip_address = true

  tags = {
    Name = "jump-host"
  }
}