resource "aws_instance" "General_EC2_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = var.sg_ids
  subnet_id                   = var.desired_vpc_subnet_id
  key_name                    = var.ec2_aws_key_pair
  user_data                   = var.user_data


  tags = {
    Name        = "${var.instance_name}-instance"
    Owner       = var.instance_owner
    Environment = var.instance_env
  }
}

