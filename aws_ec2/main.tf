variable "subnet_id" {
	description = "The ID of the subnet to launch instance in"
	type = string
}

variable "allow_ssh_sgid" {
	description = "Group security ID on SSH"
	type = string
}

variable "allow_http_sgid" {
	description = "Group security ID on HTTP"
	type = string
}

# Note: data "aws_ami" "ubuntu" enables ami search
resource "aws_instance" "main_ec2" {
  ami = "ami-0d705db840ec5f0c5"
  instance_type = "t2.micro"
  tenancy = "default"

  # Networks
  subnet_id = var.subnet_id
  associate_public_ip_address = true

  # Attach ebs root ebs volume
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  # Enable cloudwatch
  monitoring = true

  # Security
  # Key pair hard-coded here
  key_name = "ssh key"
  vpc_security_group_ids = [var.allow_ssh_sgid, var.allow_http_sgid]

  volume_tags = {
    resource_type = "ebs"
    function = "root"
  }

  tags = {
    resource_type = "ec2"
		function = "main"
  }
}
