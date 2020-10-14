variable "vpc_id" {
	description = "The ID of the VPC to apply security groups on"
	type = string
}

variable "cidr_block" {
	description = "CIFR block of the VPC to apply security groups on"
	type = string
}

locals {
	cidr_block_split = split(".", var.cidr_block)
	public_cidr_block = format("%s.%s.%s.0/24", element(local.cidr_block_split, 0),
							 				element(local.cidr_block_split, 1), 0)
	private_cidr_block = format("%s.%s.%s.0/24", element(local.cidr_block_split, 0),
							 				element(local.cidr_block_split, 1), 1)
}

resource "aws_security_group" "web_server" {
	name = "web_server_sg"
	description = "Defines security groups for web server (public subnet)"
	vpc_id = var.vpc_id

	ingress {
		description = "HTTP access from any IPv4 address"
		protocol = "TCP"
		from_port = 80
		to_port = 80
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "HTTPS access from any IPv4 address"
		protocol = "TCP"
		from_port = 443
		to_port = 443
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "SSH access from Home/Dev network"
		protocol = "TCP"
		from_port = 22
		to_port = 22
		cidr_blocks = ["75.37.203.213/32"]
	}

	ingress {
		description = "RDP access from Home/Dev network"
		protocol = "TCP"
		from_port = 3389
		to_port = 3389
		cidr_blocks = ["75.37.203.213/32"]
	}

	egress {
		description = "HTTP access to any IPv4 address"
		protocol = "TCP"
		from_port = 80
		to_port = 80
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		description = "HTTPS access to any IPv4 address"
		protocol = "TCP"
		from_port = 443
		to_port = 443
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		description = "SSH access to instances on private subnet"
		protocol = "TCP"
		from_port = 22
		to_port = 22
		cidr_blocks = [local.private_cidr_block]
	}

	egress {
		description = "RDP access to instances on private subnet"
		protocol = "TCP"
		from_port = 3389
		to_port = 3389
		cidr_blocks = [local.private_cidr_block]
	}

	tags = {
		Name = "web_server_sg"
	}
}


resource "aws_security_group" "db_server" {
	name = "db_server_sg"
	description = "Defines security groups for db server (private subnet)"
	vpc_id = var.vpc_id


	ingress {
		description = "SSH access from instances on public subnet"
		protocol = "TCP"
		from_port = 22
		to_port = 22
		cidr_blocks = ["75.37.203.213/32", local.public_cidr_block]
	}

	ingress {
		description = "RDP access from instances on public subnet"
		protocol = "TCP"
		from_port = 3389
		to_port = 3389
		cidr_blocks = ["75.37.203.213/32", local.public_cidr_block]
	}

	egress {
		description = "HTTP access to any IPv4 address"
		protocol = "TCP"
		from_port = 80
		to_port = 80
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		description = "HTTPS access to any IPv4 address"
		protocol = "TCP"
		from_port = 443
		to_port = 443
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "db_server_sg"
	}
}

output "web_server_sg_id" {
	value = aws_security_group.web_server.id
}

output "db_server_sg_id" {
	value = aws_security_group.db_server.id
}
