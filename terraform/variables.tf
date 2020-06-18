variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "allowed_account_ids" {
  type = list(string)
}

variable "aws_ami" {
  type = string
}

variable "ec2_instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "key_path" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "associate_public_ip" {
  type = string
}

variable "root_block_device" {
  type = object({
    volume_type           = string
    volume_size           = number
    delete_on_termination = bool
    encrypted             = bool
  })
}
