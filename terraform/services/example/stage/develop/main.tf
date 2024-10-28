provider "aws" {
  region = "ap-northeast-1"
}

module "network" {
  source                      = "../../modules/network"
  vpc_cidr_block              = "10.0.0.0/16"
  public_subnet_1a_cidr_block = "10.0.1.0/24"
  public_subnet_1c_cidr_block = "10.0.2.0/24"
  private_subnet_cidr_block   = "10.0.10.0/24"
  name                        = "develop"
}

module "application" {
  source                = "../../modules/application"
  vpc_id                = module.network.vpc_id
  public_subnet_1a_id   = module.network.public_subnet_1a_id
  public_subnet_1c_id   = module.network.public_subnet_1c_id
  private_subnet_id     = module.network.private_subnet_id
  alb_security_group_id = module.network.alb_security_group_id
  name                  = "develop"
}
