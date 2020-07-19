module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "custom-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  one_nat_gateway_per_az = true

  tags = {
    Environment = var.environment
  }
}