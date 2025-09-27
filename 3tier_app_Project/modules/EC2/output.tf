output "ec2_public_ip" {
  value = aws_instance.General_EC2_instance.public_ip
}

output "ec2_instance_name" {
  value = aws_instance.General_EC2_instance.tags["Name"]
}

output "ec2_instance_id" {
  value = aws_instance.General_EC2_instance.id

}

output "ec2_private_ip" {
  value = aws_instance.General_EC2_instance.private_ip

}