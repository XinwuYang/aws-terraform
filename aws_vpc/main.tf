resource "aws_vpc" "vpc" {
	cidr_block = "192.168.0.0/16"
	# To allow instance within VPC to run on dedicated host,
	# switch to "dedicated" or "host"
	instance_tenancy = "default"
	enable_dns_support = true
	enable_dns_hostnames = true
	tags = {
		Name = "prod-vpc"
	}
}

output "vpc_id" {
	description = "ID of the created VPC"
	value = aws_vpc.vpc.id
}

output "cidr_block" {
	description = "CIDR block of the created VPC"
	value = aws_vpc.vpc.cidr_block
}

output "default_route_table_id" {
	description = "Default route table ID of the created VPC"
	value = aws_vpc.vpc.default_route_table_id
}
