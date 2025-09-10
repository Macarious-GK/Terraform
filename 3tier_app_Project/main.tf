resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  filename        = "${path.module}/my-generated-key.pem"
  content         = tls_private_key.my_key.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "General_Key_Pair" {
  key_name   = "General_Key_Pair-for-ssh-access-key"
  public_key = tls_private_key.my_key.public_key_openssh
}
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
  enable_nat_gateway           = false
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

module "EC2" {
  source                      = "./modules/EC2"
  instance_name               = "my-ec2-instance"
  instance_owner              = "Macarious"
  instance_env                = "development"
  ami_id                      = "ami-0360c520857e3138f"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  sg_ids                      = [module.SG.sg_id]
  ec2_aws_key_pair            = aws_key_pair.General_Key_Pair.key_name
  desired_vpc_subnet_id       = module.VPC.public_subnets_ids[0]
  user_data                   = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
  EOF

}

module "ALB" {
  source                 = "./modules/ELB"
  lb_name                = "my-alb"
  TG_name                = "my-target-group"
  lb_owner               = "Macarious"
  lb_env                 = "dev"
  vpc_id                 = module.VPC.vpc_id
  lb_sg_id               = module.SG.sg_id
  vpc_azs                = module.VPC.vpc_azs
  vpc_public_subnets_ids = module.VPC.public_subnets_ids[*]
  asg_instance           = module.EC2.ec2_instance_id
}

module "RDS" {
  source                 = "./modules/RDS"
  identifier_name        = "my-rds-instance"
  db_name                = "mydb"
  db_username            = "macariousadmin"
  db_password            = "YourSecurePassword123!"
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