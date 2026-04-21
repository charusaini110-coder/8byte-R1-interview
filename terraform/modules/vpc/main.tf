module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "8byte-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs              = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets   = ["10.0.0.0/26", "10.0.0.64/26"]
  private_subnets = ["10.0.1.0/26", "10.0.1.64/26"]
  database_subnets = ["10.0.2.0/26", "10.0.2.64/26"]

  enable_nat_gateway = var.enable_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true
  create_database_subnet_group = true

  tags = merge(
    {
      Environment = var.environment
      Name        = "8byte-vpc-${var.environment}"
    },
    var.tags
  )
}
