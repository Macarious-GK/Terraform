# To Create Load Balancer we need to define:
# 1. Load Balancer
# 2. Target Group
# 3. Listener
# We start with creating instance or launch template for ASG
# then with target group that will route traffic to the instances
# Then we use a listener to forward requests to the target group


resource "aws_lb" "General_Purpose_LB" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [var.lb_sg_id]
  subnets            = var.vpc_subnets_ids
  tags = {
    Name        = var.lb_name
    Owner       = var.lb_owner
    Environment = var.lb_env
  }
}

resource "aws_lb_target_group" "ALB_Target_Group" {
  name        = var.TG_name
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "General_Purpose_LB_listener" {
  load_balancer_arn = aws_lb.General_Purpose_LB.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALB_Target_Group.arn
  }
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  count            = var.enable_attachment ? 1 : 0
  target_group_arn = aws_lb_target_group.ALB_Target_Group.arn
  target_id        = var.lb_tg_target_id
}