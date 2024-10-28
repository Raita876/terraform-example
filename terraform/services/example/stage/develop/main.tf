provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source                    = "../../modules/vpc"
  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_block  = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.2.0/24"
  name                      = "develop"
}
