# To Create Load Balancer we need to define:
# 1. Load Balancer
# 2. Target Group
# 3. Listener
# We start with creating instance or launch template for ASG
# then with target group that will route traffic to the instances
# Then we use a listener to forward requests to the target group


resource "aws_lb" "General_Purpose_LB" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = var.vpc_public_subnets_ids

  # enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

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
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALB_Target_Group.arn
  }

  # port              = "443"
  # protocol          = "HTTPS"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
}


resource "aws_ami_from_instance" "custom" {
  name               = "macarious-custom-ami-for-alb"
  source_instance_id = var.asg_instance
}

resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = aws_ami_from_instance.custom.id
  instance_type = "t3.micro"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.lb_sg_id]
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx

    # Replace the Nginx default index page with hostname info
    echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
  EOF
  )

}

resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier = var.vpc_public_subnets_ids
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.ALB_Target_Group.arn]
}

# resource "aws_autoscaling_policy" "bat" {
#   name                   = "foobar3-terraform-test"
#   scaling_adjustment     = 4
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.bar.name
# }

# Create a new load balancer attachment
# resource "aws_autoscaling_attachment" "example" {
#   autoscaling_group_name = aws_autoscaling_group.example.id
#   elb                    = aws_elb.example.id
# }