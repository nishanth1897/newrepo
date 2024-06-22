provider "aws" {
  region = "ap-south-1" 
}

resource "aws_vpc" "public_vpc" {
  cidr_block = "10.2.0.0/16"

tags = {
    Name = "public-VPC"
  }
}

resource "aws_subnet" "public_subnet" {                                                 
  vpc_id     = aws_vpc.public_vpc.id
  cidr_block = "10.2.2.0/24" 
  availability_zone = "ap-south-1a" 
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.public_vpc.id

  tags = {
    Name = "myigw1"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gateway.id
  }

  tags = {
    Name = "Public-routetable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.public_vpc.id
   tags = {
    Name = "public-sg"
    }

ingress {
    from_port   = 22  
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 0
    to_port     = 65535
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

resource "aws_instance" "public_instance" { 
  ami           = "ami-067aaeea6813afbde" 
  instance_type = "t2.micro" 
  subnet_id     = aws_subnet.public_subnet.id
  availability_zone      = "ap-south-1a"
  key_name      = "alb" 
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "public_instance"
  }
}