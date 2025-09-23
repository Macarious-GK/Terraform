provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "dev"
  region = "us-east-2"

}

provider "aws" {
  alias  = "prod"
  region = "us-west-2"

}