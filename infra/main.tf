# infra/main.tf

# 1. Define the VPC (Virtual Private Cloud) - your private slice of the cloud
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0.16"
  enable_dns_hostnames = true
  tags = {
    Name = "devops-demo-vpc"
  }
}

# 2. Create an Internet Gateway so our app can talk to the world
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# 3. Create a Public Subnet for our server
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow port 3000 for our backend"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outgoing traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}