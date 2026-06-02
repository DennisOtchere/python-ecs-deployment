resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
}

# Zone A
resource "aws_subnet" "main_subnet" {
    vpc_id     = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}

# Zone B (ALB)
resource "aws_subnet" "secondary_subnet" {
    vpc_id     = aws_vpc.main_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
}

resource "aws_security_group" "alb_sg" {
    name        = "alb_security_group"
    description = "Allow inbound HTTP traffic to ALB"
    vpc_id      = aws_vpc.main_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs_sg" {
    name        = "ecs_security_group"
    description = "Allow inbound traffic ONLY from ALB"
    vpc_id      = aws_vpc.main_vpc.id

    ingress {
        from_port       = 3000
        to_port         = 3000
        protocol        = "tcp"
        security_groups = [aws_security_group.alb_sg.id] 
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "secondary_subnet_assoc" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.public_rt.id
}