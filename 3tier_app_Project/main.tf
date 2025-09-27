locals {
  common_tags = {
    Owner = "Macarious"
    Env   = "Development"
  }
}


module "VPC" {
  source               = "./modules/VPC_v2"
  name                 = "my-vpc-2"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnets       = ["10.0.5.0/24", "10.0.6.0/24"]
  private_subnets      = ["10.0.3.0/24", "10.0.4.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  nat_gateway          = "none"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Owner       = "Macarious"
    Environment = "development"
  }
}

# module "SG" {
#   source         = "./modules/SG"
#   sg_description = "This security group is for my rds instance"
#   sg_name        = "my-sg"
#   sg_owner       = local.common_tags["Owner"]
#   sg_env         = local.common_tags["Env"]
#   vpc_id         = module.VPC.vpc_id
#   vpc_name       = module.VPC.vpc_arn
#   sg_ingress_rules = {
#     http = {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = "0.0.0.0/0"
#       description = "Allow HTTP"
#     },
#     https = {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = "0.0.0.0/0"
#       description = "Allow HTTPS"
#     },
#     mysql = {
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       cidr_blocks = "10.0.3.0/24"
#       description = "Allow MySQL from private subnets 10.0.3.0/24 only"
#     },
#     mysql_2 = {
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       cidr_blocks = "10.0.4.0/24"
#       description = "Allow MySQL from private subnets 10.0.4.0/24 only"
#     },
#     postgres = {
#       from_port   = 5432
#       to_port     = 5432
#       protocol    = "tcp"
#       cidr_blocks = "10.0.3.0/24"
#       description = "Allow PostgreSQL from private subnets 10.0.3.0/24 only"
#     },
#     postgres_2 = {
#       from_port   = 5432
#       to_port     = 5432
#       protocol    = "tcp"
#       cidr_blocks = "10.0.4.0/24"
#       description = "Allow PostgreSQL from private subnets 10.0.4.0/24 only"
#     },
#     ssh = {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = "0.0.0.0/0"
#       description = "Allow SSH"
#     }
#   }
# }

# module "KEY_Bastion" {
#   source        = "./modules/KEY"
#   key_name      = "Bastion-my-key-pair"
#   key_algorithm = "RSA"
# }

# module "Backend_EC2" {
#   source                      = "./modules/EC2"
#   instance_name               = "backend-my-ec2-instance"
#   instance_owner              = "Macarious"
#   instance_env                = "development"
#   ami_id                      = "ami-0360c520857e3138f"
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
#   sg_ids                      = [module.SG.sg_id]
#   ec2_aws_key_pair            = module.KEY_Bastion.key_name
#   desired_vpc_subnet_id       = module.VPC.public_subnets_ids[1]
#   user_data                   = file("${path.root}/scripts/user_data_backend.sh")
# }

# module "LB_internal_backend" {
#   source            = "./modules/LB"
#   lb_name           = "my-lb-internal-backend"
#   TG_name           = "my-target-group-internal"
#   lb_owner          = "Macarious"
#   lb_env            = "dev"
#   vpc_id            = module.VPC.vpc_id
#   lb_sg_id          = module.SG.sg_id
#   vpc_azs           = module.VPC.vpc_azs
#   vpc_subnets_ids   = module.VPC.public_subnets_ids[*]
#   enable_attachment = true
#   lb_tg_target_id   = module.Backend_EC2.ec2_instance_id
# }

# module "ASG" {
#   source             = "./modules/ASG"
#   asg_name           = "my-asg"
#   asg_name_tag_value = "my-asg-instance"
#   min_size           = 1
#   max_size           = 2
#   desired_capacity   = 1

#   asg_subnets_ids      = module.VPC.public_subnets_ids
#   enable_lb            = true
#   lb_target_group_arns = [module.LB_internet_facing.target_group_arn]

#   enable_target_tracking_policy = true
#   target_tracking_metric_type   = "ASGAverageCPUUtilization"
#   target_value_cpu_utilization  = 50.0

#   # enable_ami_from_instance      = true
#   # ami_from_instance_id          = module.Bastion_EC2.ec2_instance_id

#   launch_template_object = {
#     name_prefix         = "my-launch-template-"
#     ami_id              = "ami-0360c520857e3138f"
#     instance_type       = "t2.micro"
#     associate_public_ip = true
#     security_group_ids  = [module.SG.sg_id]
#     key_name            = module.KEY_Bastion.key_name
#     user_data_file_name = "user_data_frontend"
#     use_user_data       = true
#     user_data_vars = {
#       lb_url = module.LB_internal_backend.dns_name
#     }
#   }
# }

# module "LB_internet_facing" {
#   source            = "./modules/LB"
#   lb_name           = "my-alb"
#   TG_name           = "my-target-group"
#   lb_owner          = local.common_tags["Owner"]
#   lb_env            = local.common_tags["Env"]
#   vpc_id            = module.VPC.vpc_id
#   lb_sg_id          = module.SG.sg_id
#   vpc_azs           = module.VPC.vpc_azs
#   vpc_subnets_ids   = module.VPC.public_subnets_ids[*]
#   enable_attachment = false
# }

# module "RDS" {
#   source                 = "./modules/RDS"
#   identifier_name        = "my-rds-instance"
#   db_name                = var.db_name
#   db_username            = var.db_username
#   db_password            = var.db_password
#   db_port                = 5432
#   subnet_ids             = module.VPC.private_subnets_ids
#   vpc_security_group_ids = [module.SG.sg_id]

#   publicly_accessible    = false
#   deletion_protection    = false
#   multi_az               = false
#   allocated_storage      = 20
#   max_allocated_storage  = 30
#   storage_type           = "gp3"
#   engine                 = "postgres"
#   engine_version         = "17"
#   instance_class         = "db.t3.micro"
#   parameter_group_family = "postgres17"
#   parameters = {
#     work_mem      = "65536"
#     log_statement = "all"
#   }
# }

# module "R53" {
#   source        = "./modules/R53"
#   domain_name   = "example.com"
#   www_record_ip = module.LB_internet_facing.dns_name
# }

# module "Bastion_EC2" {
#   source                      = "./modules/EC2"
#   instance_name               = "bastion-my-ec2-instance"
#   instance_owner              = "Macarious"
#   instance_env                = "development"
#   ami_id                      = "ami-0360c520857e3138f"
#   instance_type               = "t3.micro"
#   associate_public_ip_address = true
#   sg_ids                      = [module.SG.sg_id]
#   ec2_aws_key_pair            = module.KEY_Bastion.key_name
#   desired_vpc_subnet_id       = module.VPC.public_subnets_ids[0]
#   user_data                   = <<-EOF
#     #!/bin/bash
#     sudo apt update -y
#   EOF
# }

