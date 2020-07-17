variable "vpc_id" {
	description = "The ID of the VPC to create subnet in"
	type = string
}

variable "cidr_block" {
	description = "CIFR block of the VPC to to create subnet in"
	type = string
}

resource "aws_subnet" "subnet" {
  vpc_id = var.vpc_id
  cidr_block = format("%s/24", element(split("/", var.cidr_block), 0))
  map_public_ip_on_launch = true
}

output "subnet_id" {
	value = "${aws_subnet.subnet.id}"
}
