resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "dashboard-public-route-table"
  }
}

resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "-private-route-table"
  }
}

resource "aws_route_table_association" "dashboard_private_rt1" {
  subnet_id      = aws_subnet.dashboard_private_subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "dashboard_private_rt2" {
  subnet_id      = aws_subnet.dashboard_private_subnet2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "counting_private_rt1" {
  subnet_id      = aws_subnet.counting_private_subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "counting_private_rt2" {
  subnet_id      = aws_subnet.counting_private_subnet2.id
  route_table_id = aws_route_table.private.id
}