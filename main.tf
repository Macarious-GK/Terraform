provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source         = "./VPC_Module"
  cidr_block     = "10.0.0.0/16"
  vpc_name       = "Macarious-VPC"
  public_subnets = ["10.0.1.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.2.0/24", "10.0.4.0/24"]
  azs            = ["us-east-2a", "us-east-2b"]
}

module "security_group" {
  source  = "./SecurityGroup_Module"
  sg_name = "Macarious-Security-Group"
  vpc_id  = module.vpc.vpc_id
}


module "eks" {
  source = "./EKS_Module"

  vpc_id             = module.vpc.vpc_id
  sg_id               = module.security_group.security_group_id
  cluster_name        = "Macarious-eks-cluster"
  node_group_name     = "Macarious-eks-node-group"
  private_subnet_ids  = module.vpc.private_subnets[*]
  instance_types      = ["t3.medium"]
  desired_size        = 1
  max_size            = 1
  min_size            = 1
  kubernetes_version  = "1.30" 
}
