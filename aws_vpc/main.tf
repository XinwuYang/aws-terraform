resource "aws_vpc" "main_vpc" {
	cidr_block = "192.168.0.0/16"
	# To allow instance within VPC to run on dedicated host,
	# switch to "dedicated" or "host"
	instance_tenancy = "default"
	enable_dns_support = true
	enable_dns_hostnames = true
	tags = {
		resource_type = "vpc"
		function = "main"
	}
}

# Add NAT gateways for instance without public ip

# Add internet gateway to VPC for access to internet
resource "aws_internet_gateway" "main_vpc_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
		resource_type = "internet_gateway"
		function = "main"
  }
}

# Add route to allow VPC access to internet
resource "aws_default_route_table" "main_vpc_route" {
	default_route_table_id = aws_vpc.main_vpc.default_route_table_id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.main_vpc_gw.id
	}

}

output "vpc_id" {
	value = "${aws_vpc.main_vpc.id}"
}

output "cidr_block" {
	value = "${aws_vpc.main_vpc.cidr_block}"
}
