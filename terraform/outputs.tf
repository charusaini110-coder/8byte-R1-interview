# =====================================
# VPC Outputs
# =====================================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

# =====================================
# Security Groups Outputs
# =====================================
output "alb_sg_id" {
  description = "Security group ID for ALB"
  value       = try(module.security_groups[0].alb_sg_id, null)
}

output "ec2_sg_id" {
  description = "Security group ID for EC2"
  value       = try(module.security_groups[0].ec2_sg_id, null)
}

output "db_sg_id" {
  description = "Security group ID for RDS"
  value       = try(module.security_groups[0].db_sg_id, null)
}

# =====================================
# Load Balancer Outputs (for_each)
# =====================================
# COMMENTED OUT - ALB not currently deployed
# output "alb_dns_names" {
#   description = "DNS names of all load balancers"
#   value = {
#     for key, alb in module.alb :
#     key => alb.alb_dns_name
#   }
# }
#
# output "alb_arns" {
#   description = "ARNs of all load balancers"
#   value = {
#     for key, alb in module.alb :
#     key => alb.alb_arn
#   }
# }
#
# output "target_group_arns" {
#   description = "ARNs of all target groups"
#   value = {
#     for key, alb in module.alb :
#     key => alb.target_group_arn
#   }
# }

# =====================================
# EC2 Outputs (for_each)
# =====================================
output "ec2_instance_ids" {
  description = "IDs of all EC2 instances"
  value = {
    for key, ec2 in module.ec2 :
    key => ec2.instance_id
  }
}

output "ec2_public_ips" {
  description = "Public IP addresses of all EC2 instances"
  value = {
    for key, ec2 in module.ec2 :
    key => ec2.instance_public_ip
  }
}

output "ec2_private_ips" {
  description = "Private IP addresses of all EC2 instances"
  value = {
    for key, ec2 in module.ec2 :
    key => ec2.instance_private_ip
  }
}

output "ec2_public_dns" {
  description = "Public DNS names of all EC2 instances"
  value = {
    for key, ec2 in module.ec2 :
    key => ec2.instance_public_dns
  }
}

# =====================================
# RDS Outputs (for_each)
# =====================================
output "rds_endpoints" {
  description = "Connection endpoints of all RDS instances"
  value = {
    for key, rds in module.rds :
    key => rds.db_endpoint
  }
}

output "rds_addresses" {
  description = "Addresses of all RDS instances"
  value = {
    for key, rds in module.rds :
    key => rds.db_address
  }
}

output "rds_ports" {
  description = "Ports of all RDS instances"
  value = {
    for key, rds in module.rds :
    key => rds.db_port
  }
}

output "rds_instance_ids" {
  description = "Instance identifiers of all RDS databases"
  value = {
    for key, rds in module.rds :
    key => rds.db_instance_id
  }
}

# =====================================
# Summary Outputs
# =====================================
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    vpc_id           = module.vpc.vpc_id
    # alb_count        = length(module.alb) # COMMENTED OUT - ALB disabled
    ec2_count        = length(module.ec2)
    rds_count        = length(module.rds)
    # primary_alb_dns  = try(module.alb[keys(var.alb_config)[0]].alb_dns_name, "N/A") # COMMENTED OUT - ALB disabled
    primary_rds_host = try(module.rds[keys(var.rds_databases)[0]].db_address, "N/A")
  }
}