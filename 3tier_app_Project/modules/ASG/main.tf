# when we create ASG we go through these steps:
# 1. launch template or launch configuration
# 1. ami id
# 2. instance type
# 3. key pair
# 4. security group
# 5. user data
# 2. Launch options
# 1.Network
# 1.VPC
# 2.subnets
# 3.AZs
# 3. Configure group size and scaling 
# 1. min size
# 2. max size
# 3. desired capacity
# 4. Instance maintenance policy
# 5. Scaling policies


## For scaling policies we can use:
# 1. Target tracking scaling
# 2. Step scaling (for more controlled scaling)

locals {
  user_data_content = var.launch_template_object.use_user_data ? templatefile("${path.root}/scripts/${var.launch_template_object.user_data_file_name}.tpl", var.launch_template_object.user_data_vars) : file("${path.root}/scripts/${var.launch_template_object.user_data_file_name}")

}

locals {
  user_data_base64 = base64encode(local.user_data_content)
}

resource "aws_ami_from_instance" "custom" {
  count              = var.enable_ami_from_instance ? 1 : 0
  name               = "macarious-custom-ami-for-alb"
  source_instance_id = var.ami_from_instance_id
}

resource "aws_launch_template" "General_Purpose_LT_for_ASG" {
  name_prefix   = var.launch_template_object.name_prefix
  image_id      = var.enable_ami_from_instance ? try(aws_ami_from_instance.custom[0].id, var.launch_template_object.ami_id) : var.launch_template_object.ami_id
  instance_type = var.launch_template_object.instance_type
  network_interfaces {
    associate_public_ip_address = var.launch_template_object.associate_public_ip
    security_groups             = var.launch_template_object.security_group_ids
  }
  key_name  = var.launch_template_object.key_name
  user_data = local.user_data_base64
}

resource "aws_autoscaling_group" "General_Purpose_ASG" {
  name             = var.asg_name
  max_size         = var.max_size
  min_size         = var.min_size
  desired_capacity = var.desired_capacity

  health_check_type         = var.enable_lb ? "ELB" : "EC2"
  health_check_grace_period = 300

  force_delete        = true
  vpc_zone_identifier = var.asg_subnets_ids

  launch_template {
    id      = aws_launch_template.General_Purpose_LT_for_ASG.id
    version = "$Latest"
  }
  target_group_arns = var.lb_target_group_arns


  tag {
    key                 = "Name"
    value               = var.asg_name_tag_value
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "cpu_target_tracking" {
  count                  = var.enable_target_tracking_policy ? 1 : 0
  name                   = "${aws_autoscaling_group.General_Purpose_ASG.name}-cpu-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.General_Purpose_ASG.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.target_tracking_metric_type
    }
    target_value = var.target_value_cpu_utilization
  }
}






########## (Step Scaling with Alarm)

# # CloudWatch Alarm
# resource "aws_cloudwatch_metric_alarm" "high_cpu" {
#   alarm_name          = "high-cpu"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 70
#   alarm_description   = "Scale up if CPU > 70% for 2 mins"
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.bar.name
#   }
# }

# # Scaling Policy
# resource "aws_autoscaling_policy" "scale_up" {
#   name                   = "scale-up"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 60
#   autoscaling_group_name = aws_autoscaling_group.bar.name
# }

# # Attach alarm to policy
# resource "aws_cloudwatch_metric_alarm" "high_cpu_action" {
#   alarm_name          = "high-cpu-with-action"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 70
#   alarm_description   = "Alarm with action"
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.bar.name
#   }

#   alarm_actions = [aws_autoscaling_policy.scale_up.arn]
# }
