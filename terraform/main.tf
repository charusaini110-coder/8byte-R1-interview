# =====================================
# VPC Module
# =====================================
module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_config.cidr
  enable_nat_gateway   = var.vpc_config.enable_nat_gateway
  tags                 = local.common_tags
}

# =====================================
# Security Groups Module
# =====================================
module "security_groups" {
  count = var.security_groups_enabled ? 1 : 0

  source = "./modules/security_groups"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags

  depends_on = [module.vpc]
}

# =====================================
# Application Load Balancer Module (for_each)
# =====================================
module "alb" {
  for_each = {
    for key, config in var.alb_config :
    key => config
    if config.enabled
  }

  source = "./modules/alb"

  environment    = var.environment
  alb_sg_id      = module.security_groups[0].alb_sg_id
  public_subnets = module.vpc.public_subnets
  tags = merge(
    local.common_tags,
    {
      ALBName = each.value.name
    }
  )

  depends_on = [module.security_groups]
}

# =====================================
# EC2 Module (for_each)
# =====================================
module "ec2" {
  for_each = {
    for key, config in var.ec2_instances :
    key => config
    if config.enabled
  }

  source = "./modules/ec2"

  environment       = var.environment
  ec2_sg_id         = module.security_groups[0].ec2_sg_id
  target_group_arn  = module.alb[keys(var.alb_config)[0]].target_group_arn
  subnet_id         = module.vpc.public_subnets[0]
  instance_type     = each.value.instance_type
  ami_id            = each.value.ami_id
  tags = merge(
    local.common_tags,
    {
      InstanceName = each.value.name
    }
  )

  depends_on = [module.alb, module.security_groups]
}

# =====================================
# RDS Module (for_each)
# =====================================
module "rds" {
  for_each = {
    for key, config in var.rds_databases :
    key => config
    if config.enabled
  }

  source = "./modules/rds"

  environment            = var.environment
  db_sg_id               = module.security_groups[0].db_sg_id
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  db_username            = var.db_username
  db_password            = var.db_password
  db_allocated_storage   = each.value.allocated_storage
  engine_version         = each.value.engine_version
  instance_class         = each.value.instance_class
  multi_az               = each.value.multi_az
  tags = merge(
    local.common_tags,
    {
      DBName = each.value.name
    }
  )

  depends_on = [module.security_groups]
}

# =====================================
# Local Variables
# =====================================
locals {
  common_tags = {
    Project     = "8byte"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Get primary ALB key for EC2 target group attachment
  # This ensures EC2 can always reference at least one ALB
  alb_primary_key = try(keys(var.alb_config)[0], null)

  # Validation: warn if ALB config is empty when EC2 is enabled
  alb_ec2_compatibility = length([
    for instance in var.ec2_instances :
    instance if instance.enabled
  ]) > 0 && length([
    for alb in var.alb_config :
    alb if alb.enabled
  ]) == 0 ? (
    file("ERROR: EC2 instances are enabled but no ALB is configured. Enable at least one ALB or disable EC2 instances.")
  ) : null
}