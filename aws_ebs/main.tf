resource "aws_ebs_volume" "main_ebs" {
  availability_zone = "us-west-1b"
  type = "gp2"
  size = 1
  encrypted = false

  tags = {
    resource_type = "vpc"
		function = "main"
  }
}

output "ebs_id" {
	value = "${aws_ebs_volume.main_ebs.id}"
}
