resource "aws_security_group" "General_SG" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id
  tags = {
    Name        = "${var.sg_name}-sg"
    Owner       = var.sg_owner
    Environment = var.sg_env
    VPC_Related = var.vpc_name

  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_rules" {
  for_each          = var.sg_ingress_rules
  security_group_id = aws_security_group.General_SG.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks
}

resource "aws_vpc_security_group_egress_rule" "sg_egress_rules" {
  for_each          = var.sg_egress_rules
  security_group_id = aws_security_group.General_SG.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks
}