provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "coffee_shop_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.coffee_shop_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.coffee_shop_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.coffee_shop_vpc.id
}

# Create a public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.coffee_shop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security group for website instance
resource "aws_security_group" "website_sg" {
  vpc_id = aws_vpc.coffee_shop_vpc.id

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

# Security group for backend instance
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.coffee_shop_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Restrict traffic to public subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch frontend EC2 instance
resource "aws_instance" "website_instance" {
  ami             = "ami-0a5c3558529277641" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.website_sg.id]

  tags = {
    Name = "CoffeeShop-Website"
  }
}

# Launch backend EC2 instance
resource "aws_instance" "backend_instance" {
  ami             = "ami-0a5c3558529277641" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "CoffeeShop-Backend"
  }
}

# Public subnet NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.coffee_shop_vpc.id

  # Associate NACL with public subnet
  subnet_ids = [aws_subnet.public_subnet.id]
}

# Allow inbound HTTP traffic (port 80)
resource "aws_network_acl_rule" "allow_http_inbound" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow inbound SSH traffic (port 22) - Optional
resource "aws_network_acl_rule" "allow_ssh_inbound" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 101
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

# Allow all outbound traffic
resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 200
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# Deny all other inbound traffic
resource "aws_network_acl_rule" "deny_all_inbound" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 300
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
}

# Deny all other outbound traffic
resource "aws_network_acl_rule" "deny_all_outbound" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 400
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
}
