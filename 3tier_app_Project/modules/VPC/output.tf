output "vpc_id" {
  value = aws_vpc.General_vpc.id
}

output "vpc_name" {
  value = aws_vpc.General_vpc.arn
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "vpc_azs" {
  value = aws_subnet.public_subnets[*].availability_zone
}