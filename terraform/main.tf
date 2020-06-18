locals {
  # Project wide
  project_name = var.project_name

  # AWS config
  aws_region          = var.aws_region
  allowed_account_ids = var.allowed_account_ids

  # EC2 specs
  aws_ami             = var.aws_ami
  ec2_instance_type   = var.ec2_instance_type
  key_name            = var.key_name
  key_path            = var.key_path
  ingress_rules       = var.ingress_rules
  associate_public_ip = var.associate_public_ip
  root_block_device   = var.root_block_device
}

provider "aws" {
  region              = local.aws_region
  allowed_account_ids = local.allowed_account_ids
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_key_pair" "this" {
  key_name   = local.key_name
  public_key = file(local.key_path)
}

resource "aws_security_group" "this" {
  name        = local.project_name
  description = "Security group for ${var.project_name}"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_shuffle" "subnet_id" {
  input        = data.aws_subnet_ids.default.ids
  result_count = 1
}

resource "aws_instance" "this" {
  ami                         = local.aws_ami
  instance_type               = local.ec2_instance_type
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  subnet_id                   = random_shuffle.subnet_id.result[0]
  associate_public_ip_address = local.associate_public_ip
  
  root_block_device {
    volume_type           = local.root_block_device["volume_type"]
    volume_size           = local.root_block_device["volume_size"]
    delete_on_termination = local.root_block_device["delete_on_termination"]
    encrypted             = local.root_block_device["encrypted"]
  }

  tags = {
    Name = local.project_name
  }
}
