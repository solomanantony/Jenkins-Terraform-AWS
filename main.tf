terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-2"
}


# S3 BUCKET

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "jenkins-terraform-demo-soloman-001"
}


# VPC

resource "aws_vpc" "demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "soloman-terraform-vpc"
  }
}


# SUBNET (PUBLIC)

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}


# INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "soloman-terraform-igw"
  }
}


# ROUTE TABLE
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "soloman-terraform-public-rt"
  }
}


# ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

# SECURITY GROUP

resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "soloman-terraform-sg"
  }
}

# EC2 INSTANCE
resource "aws_instance" "ec2" {
  ami                    = "ami-070e5bd3ff10324f8"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "MCA-EC2-Key"

  tags = {
    Name = "soloman-ec2"
  }
}
