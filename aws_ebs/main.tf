variable "ec2_ids" {
	description = "Map of instance name to instance ID"
	type = map(string)
}

variable "ebs_config" {
	description = "Configuration of ebs to be created"
	type = map(any)
}

locals {
	default_config = {
		vol = 20
	  ebs_type = "gp2" # General Purpose
	}
	disks = { for name, config in var.ebs_config: name => merge(local.default_config, config) }
}

resource "aws_ebs_volume" "ebs" {
  for_each = local.disks

  availability_zone = "us-west-1b"
  type = each.value.ebs_type
  size = each.value.vol
  encrypted = false

  tags = {
    Name = format("ebs-%s", each.key)
  }
}


resource "aws_volume_attachment" "attach_ebs" {
  for_each = local.disks

  device_name = "/dev/sdh"
  volume_id = lookup(lookup(aws_ebs_volume.ebs, each.key), "id")
  instance_id = lookup(var.ec2_ids, each.key)
}

# TODO: Format mounted disk
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
