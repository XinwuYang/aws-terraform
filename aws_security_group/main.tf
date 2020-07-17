variable "vpc_id" {
	description = "The ID of the VPC to apply security groups on"
	type = string
}

variable "cidr_block" {
	description = "CIFR block of the VPC to apply security groups on"
	type = string
}

resource "aws_security_group" "allow_ssh" {
	name = "allow_ssh"
	description = "Allow SSH from seleted IPs"
	vpc_id = var.vpc_id

	ingress {
		description = "SSH from selected IPs"
		protocol = "TCP"
		from_port = 22
		to_port = 22
		cidr_blocks = [var.cidr_block,
			       "75.37.203.213/32"]
	}

	tags = {
		resource_type = "aws_security_group"
		function = "ssh"
	}
}

resource "aws_security_group" "allow_http" {
	name = "allow_http"
	description = "Allow HTTP from all IPs"
	vpc_id = var.vpc_id

	ingress {
		description = "HTTP from selected IPs"
		protocol = "TCP"
		from_port = 80
		to_port = 80
		cidr_blocks = [var.cidr_block,
                               "75.37.203.213/32"]
	}

	egress {
		description = "HTTP to all IPs"
		protocol = "TCP"
		from_port = 80
		to_port = 80
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		resource_type = "aws_security_group"
		funtion = "http"
	}
}

output "allow_ssh_sgid" {
	value = "${aws_security_group.allow_ssh.id}"
}

output "allow_http_sgid" {
	value = "${aws_security_group.allow_http.id}"
}
