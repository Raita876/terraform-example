provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source     = "../../modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "develop"
}

# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
# }

# resource "aws_subnet" "private_subnet" {
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = "10.0.2.0/24"
# }
