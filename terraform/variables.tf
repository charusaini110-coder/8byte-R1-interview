variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (e.g., staging, prod)"
  type        = string
  default     = "staging"
}

# VPC Configuration
variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr               = string
    enable_nat_gateway = bool
  })
  default = {
    cidr               = "10.0.0.0/16"
    enable_nat_gateway = false
  }
}

# Security Groups - no for_each needed (VPC level)
variable "security_groups_enabled" {
  description = "Enable security groups creation"
  type        = bool
  default     = true
}

# ALB Configuration
# COMMENTED OUT - ALB not currently deployed
# variable "alb_config" {
#   description = "Application Load Balancer configuration"
#   type = map(object({
#     enabled = bool
#     name    = string
#   }))
#   default = {
#     primary = {
#       enabled = true
#       name    = "primary"
#     }
#   }
# }

# EC2 Configuration
variable "ec2_instances" {
  description = "EC2 instances configuration"
  type = map(object({
    enabled       = bool
    instance_type = string
    ami_id        = string
    name          = string
  }))
  default = {
    app_server_1 = {
      enabled       = true
      instance_type = "t2.micro"
      ami_id        = "ami-0c2af51e265bd5e0e"
      name          = "app-server-1"
    }
  }
}

# RDS Configuration
variable "rds_databases" {
  description = "RDS database instances configuration"
  type = map(object({
    enabled          = bool
    engine_version   = string
    instance_class   = string
    allocated_storage = number
    multi_az         = bool
    name             = string
  }))
  default = {
    postgres_primary = {
      enabled          = true
      engine_version   = "15.4"
      instance_class   = "db.t3.micro"
      allocated_storage = 20
      multi_az         = false
      name             = "postgres-primary"
    }
  }
}

# Database Credentials
variable "db_username" {
  description = "PostgreSQL administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}