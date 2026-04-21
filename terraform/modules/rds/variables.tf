# variable "environment" {
#   description = "Environment name"
#   type        = string
# }

# variable "db_sg_id" {
#   description = "Security group ID for RDS"
#   type        = string
# }

# variable "db_subnet_group_name" {
#   description = "DB subnet group name"
#   type        = string
# }

# variable "db_username" {
#   description = "PostgreSQL administrator username"
#   type        = string
#   sensitive   = true
# }

# variable "db_password" {
#   description = "PostgreSQL administrator password"
#   type        = string
#   sensitive   = true
# }

# variable "db_allocated_storage" {
#   description = "Allocated storage for RDS (GB)"
#   type        = number
#   default     = 20
# }

# variable "engine_version" {
#   description = "PostgreSQL engine version"
#   type        = string
#   default     = "15.4"
# }

# variable "instance_class" {
#   description = "RDS instance class"
#   type        = string
#   default     = "db.t3.micro"
# }

# variable "multi_az" {
#   description = "Enable Multi-AZ deployment"
#   type        = bool
#   default     = false
# }

# variable "tags" {
#   description = "Tags to apply to resources"
#   type        = map(string)
#   default     = {}
# }
