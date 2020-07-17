provider "aws" {
	# Run aws configure first to set up key pair
	profile = "default"
	region = "us-west-1"
	version = "2.7.0"
}

module "vpc" {
	source = "./aws_vpc"
}

module "subnet" {
	source = "./aws_subnet"
	vpc_id = "${module.vpc.vpc_id}"
	cidr_block = "${module.vpc.cidr_block}"
}


module "security_group" {
	source = "./aws_security_group"
	vpc_id = "${module.vpc.vpc_id}"
	cidr_block = "${module.vpc.cidr_block}"
}

/*
module "ebs" {
	source = "./aws_ebs"
}
*/

module "ec2" {
	source = "./aws_ec2"
	subnet_id = "${module.subnet.subnet_id}"
	allow_ssh_sgid = "${module.security_group.allow_ssh_sgid}"
	allow_http_sgid = "${module.security_group.allow_http_sgid}"
}
