output "vpc_id" {
  value = aws_vpc.General_vpc.id
}

output "vpc_arn" {
  value = aws_vpc.General_vpc.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.General_vpc.cidr_block
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.NAT_GW[*].id
}

output "vpc_azs" {
  value = aws_subnet.public_subnets[*].availability_zone
}



