# AWS Configuration
aws_region = "us-east-1"
environment = "staging"

# VPC Configuration
vpc_config = {
  cidr               = "10.0.0.0/22"
  enable_nat_gateway = false
}

# Security Groups
security_groups_enabled = true

# ALB Configuration (for_each)
# COMMENTED OUT - ALB not currently deployed
# alb_config = {
#   primary = {
#     enabled = true
#     name    = "primary"
#   }
#   # secondary = {
#   #   enabled = true
#   #   name    = "secondary"
#   # }
# }

# EC2 Instances Configuration (for_each)
# Add/remove instances by adding/removing entries
ec2_instances = {
  app_server_1 = {
    enabled       = true
    instance_type = "t2.micro"
    ami_id        = "ami-098e39bafa7e7303d" # Ubuntu 22.04 LTS (ap-south-1)
    name          = "app-server-1"
  }
  # app_server_2 = {
  #   enabled       = true
  #   instance_type = "t2.micro"
  #   ami_id        = "ami-0c2af51e265bd5e0e"
  #   name          = "app-server-2"
  # }
}

# RDS Databases Configuration (for_each)
# Add/remove databases by adding/removing entries
# rds_databases = {
#   postgres_primary = {
#     enabled          = true
#     engine_version   = "15.4"
#     instance_class   = "db.t3.micro"
#     allocated_storage = 20
#     multi_az         = false
#     name             = "postgres-primary"
#   }
  # postgres_secondary = {
  #   enabled          = true
  #   engine_version   = "15.4"
  #   instance_class   = "db.t3.micro"
  #   allocated_storage = 20
  #   multi_az         = true
  #   name             = "postgres-secondary"
  # }
//}

# Database Credentials
//db_username = "admin"
//db_password = "SecurePassword123!"


