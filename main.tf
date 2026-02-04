terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# SSH Key Pair and Gateway Key Pair Generation
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "tls_private_key" "gateway" {
  algorithm = "ED25519"
}

locals {
  gateway_token = substr(
    sha256(tls_private_key.gateway.public_key_openssh),
    0,
    48
  )
}

resource "aws_key_pair" "this" {
  key_name   = "openclaw-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Networking and Security Resources
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "openclaw-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "openclaw-igw" }
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "openclaw-subnet" }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_security_group" "this" {
  name        = "openclaw-sg"
  description = "OpenClaw security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH (fallback)"
    from_port   = 22
    to_port     = 22
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

# AMI Data Source
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance Resource
resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.this.id
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = aws_key_pair.this.key_name

  user_data = templatefile("${path.module}/userdata.sh.tftpl", {
    llm_provider         = var.llm_provider
    anthropic_api_key    = var.anthropic_api_key
    openrouter_api_key   = var.openrouter_api_key
    openai_api_key       = var.openai_api_key
    opencode_zen_api_key = var.opencode_zen_api_key
    tailscale_auth_key   = var.tailscale_auth_key
    gateway_port         = var.gateway_port
    gateway_token        = local.gateway_token
  })

  user_data_replace_on_change = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "openclaw"
  }
}
