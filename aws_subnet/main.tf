variable "vpc_id" {
	description = "The ID of the VPC to create subnet in"
	type = string
}

variable "cidr_block" {
	description = "CIFR block of the VPC to to create subnet in"
	type = string
}

locals {
	cidr_block_split = split(".", var.cidr_block)
	public_cidr_block = format("%s.%s.%s.0/24", element(local.cidr_block_split, 0),
							 				element(local.cidr_block_split, 1), 0)
	private_cidr_block = format("%s.%s.%s.0/24", element(local.cidr_block_split, 0),
							 				element(local.cidr_block_split, 1), 1)
}

# Creating public subnet within VPC
resource "aws_subnet" "public_subnet" {

  vpc_id = var.vpc_id
  cidr_block = local.public_cidr_block

  map_public_ip_on_launch = true

	tags = {
		Name = "prod-public-subnet"
	}
}

# Creating private subnet within VPC
resource "aws_subnet" "private_subnet" {

  vpc_id = var.vpc_id
  cidr_block = local.private_cidr_block

  map_public_ip_on_launch = false

	tags = {
		Name = "prod-private-subnet"
	}
}

output "public_subnet_id" {
	description = "ID of the public subnet"
	value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
	description = "ID of the private subnet"
	value = aws_subnet.private_subnet.id
}
