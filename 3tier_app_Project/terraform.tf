terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.10.0, < 2.0.0"

  backend "s3" {
    bucket       = "macarious-terraform-state-bucket"
    encrypt      = true
    key          = "terraform-2/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}


