provider "aws" {
	# Run aws configure first to set up key pair
	profile = "default"
	region = "us-west-1"
	version = "2.7.0"
}

# Create a single VPC
module "vpc" {
	source = "./aws_vpc"
}

# Create Public and Private subnets within the VPC
module "subnet" {
	source = "./aws_subnet"
	vpc_id = module.vpc.vpc_id
	cidr_block = module.vpc.cidr_block
}

# Create Internet Gateway and NAT Gateway
module "gateway" {
	source = "./aws_gateway"
	vpc_id = module.vpc.vpc_id
	public_subnet_id = module.subnet.public_subnet_id
}

# Create Route Tables for both subnets and create association
module "routing" {
	source = "./aws_route_table"
	vpc_id = module.vpc.vpc_id
	private_subnet_id = module.subnet.private_subnet_id
	default_route_table_id = module.vpc.default_route_table_id
	igw_id = module.gateway.igw_id
	nat_id = module.gateway.nat_id
}


module "security_group" {
	source = "./aws_security_group"
	vpc_id = module.vpc.vpc_id
	cidr_block = module.vpc.cidr_block
}

module "ec2" {
	source = "./aws_ec2"
	private_subnet_id = module.subnet.private_subnet_id
	public_subnet_id = module.subnet.public_subnet_id
	instances_config = {
		"prod-svr-web-01": {  },
		"prod-svr-web-02": {  },
		"prod-svr-web-03": { ami = "ami-0d705db840ec5f0c5" },
		"prod-svr-web-04": { ami = "ami-0d705db840ec5f0c5" },
		"prod-svr-db-01": {  public = false }
		"prod-svr-db-02": { ami = "ami-0d705db840ec5f0c5", public = false }
	}
	web_server_sg_id = module.security_group.web_server_sg_id
	db_server_sg_id = module.security_group.db_server_sg_id
}


module "ebs" {
	source = "./aws_ebs"
	ec2_ids = module.ec2.ec2_ids
	ebs_config = {
		"prod-svr-web-01": { vol = 10 }
		"prod-svr-web-02": { vol = 10 }
	}
}
