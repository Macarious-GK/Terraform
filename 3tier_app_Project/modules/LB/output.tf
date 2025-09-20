output "dns_name" {
  value = aws_lb.General_Purpose_LB.dns_name

}

output "target_group_arn" {
  value = aws_lb_target_group.ALB_Target_Group.arn

}
