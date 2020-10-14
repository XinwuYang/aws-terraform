variable "public_subnet_id" {
	description = "ID of the public subnet"
	type = string
}

variable "private_subnet_id" {
	description = "ID of the private subnet"
	type = string
}

variable "web_server_sg_id" {
	description = "Group security ID for web servers (public subnet)"
	type = string
}

variable "db_server_sg_id" {
	description = "Group security ID on db servers (private subnet)"
	type = string
}

variable "instances_config" {
	description = "Configuration of instances to be created"
	type = map(any)
}

locals {
	default_config = {
		ami = "ami-0d705db840ec5f0c5" # Ubuntu 18.04 LTS
	  instance_type = "t2.micro" # Free tier
		boot_disk_size = 8
		#disks = {} TODO: List of ebs volume IDs
		public = true # Assign public IP
	}
	instances = { for name, config in var.instances_config: name => merge(local.default_config, config) }
}

# Note: data "aws_ami" "ubuntu" enables ami search
resource "aws_instance" "ec2" {
	for_each = local.instances

  ami = each.value.ami #"ami-0d705db840ec5f0c5"
  instance_type = each.value.instance_type #"t2.micro"
  tenancy = "default"

  # Networks
  subnet_id = each.value.public ? var.public_subnet_id : var.private_subnet_id
  associate_public_ip_address = each.value.public #true

  # Attach ebs root ebs volume
  root_block_device {
    volume_type = "gp2"
    volume_size = each.value.boot_disk_size #8
  }

  # Enable cloudwatch
  monitoring = true

  # Security
  # Key pair hard-coded here
  key_name = "ssh key"
  vpc_security_group_ids = each.value.public ? [var.web_server_sg_id] : [var.db_server_sg_id]

  volume_tags = {
    Name = format("root-volume-%s", each.key)
  }

  tags = {
    Name = each.key
  }
}

output "ec2_ids" {
	description = "Map of instance name to instance ID"
	value = {
		for instance in aws_instance.ec2:
		instance.tags.Name => instance.id
	}
}
