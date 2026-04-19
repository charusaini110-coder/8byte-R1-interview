module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "8byte-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = var.enable_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Environment = var.environment
      Name        = "8byte-vpc-${var.environment}"
    },
    var.tags
  )
}
