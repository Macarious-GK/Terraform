
module "VPC" {
  source                       = "./modules/VPC"
  vpc_name                     = "my-vpc"
  vpc_owner                    = "Macarious"
  vpc_env                      = "development"
  vpc_cidr                     = "10.0.0.0/16"
  number_of_availability_zones = 2
  azs                          = ["us-east-1a", "us-east-1b"]
  public_subnets               = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets              = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway           = true
  enable_dns_hostnames         = true
  enable_dns_support           = true
}

module "SG" {
  source         = "./modules/SG"
  sg_description = "This security group is for my rds instance"
  sg_name        = "my-sg"
  sg_owner       = "Macarious"
  sg_env         = "development"
  vpc_id         = module.VPC.vpc_id
  vpc_name       = module.VPC.vpc_name
  sg_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP"
    },
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS"
    },
    mysql = {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow MySQL"
    },
    postgres = {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow PostgreSQL"
    },
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow SSH"
    }
  }
}

module "KEY-Bastion" {
  source        = "./modules/KEY"
  key_name      = "Bastion-my-key-pair"
  key_algorithm = "RSA"

}
module "KEY-backend" {
  source        = "./modules/KEY"
  key_name      = "backend-my-key-pair"
  key_algorithm = "RSA"

}

module "Bastion_EC2" {
  source                      = "./modules/EC2"
  instance_name               = "bastion-my-ec2-instance"
  instance_owner              = "Macarious"
  instance_env                = "development"
  ami_id                      = "ami-0360c520857e3138f"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  sg_ids                      = [module.SG.sg_id]
  ec2_aws_key_pair            = module.KEY-Bastion.key_name
  desired_vpc_subnet_id       = module.VPC.public_subnets_ids[0]
  user_data                   = <<-EOF
    #!/bin/bash
    sudo apt update -y
  EOF
}

module "Backend_EC2" {
  source                      = "./modules/EC2"
  instance_name               = "backend-my-ec2-instance"
  instance_owner              = "Macarious"
  instance_env                = "development"
  ami_id                      = "ami-0360c520857e3138f"
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  sg_ids                      = [module.SG.sg_id]
  ec2_aws_key_pair            = module.KEY-backend.key_name
  desired_vpc_subnet_id       = module.VPC.private_subnets_ids[0]
  user_data                   = <<-EOF
    #!/bin/bash
    sudo apt update -y
  EOF
}

module "RDS" {
  source                 = "./modules/RDS"
  identifier_name        = "my-rds-instance"
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  db_port                = 5432
  subnet_ids             = module.VPC.public_subnets_ids
  vpc_security_group_ids = [module.SG.sg_id]

  publicly_accessible    = true
  deletion_protection    = false
  multi_az               = false
  allocated_storage      = 20
  max_allocated_storage  = 30
  storage_type           = "gp3"
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t3.micro"
  parameter_group_family = "postgres17"
  parameters = {
    work_mem      = "65536"
    log_statement = "all"
  }
}

# module "ALB" {
#   source                 = "./modules/ELB"
#   lb_name                = "my-alb"
#   TG_name                = "my-target-group"
#   lb_owner               = "Macarious"
#   lb_env                 = "dev"
#   vpc_id                 = module.VPC.vpc_id
#   lb_sg_id               = module.SG.sg_id
#   vpc_azs                = module.VPC.vpc_azs
#   vpc_public_subnets_ids = module.VPC.public_subnets_ids[*]
#   asg_instance           = module.EC2.ec2_instance_id
# }