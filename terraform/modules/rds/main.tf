resource "aws_db_instance" "postgres" {
  identifier             = "byte8-db-${var.environment}"
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.db_allocated_storage
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_sg_id]
  
  publicly_accessible    = false
  multi_az               = var.multi_az
  skip_final_snapshot    = true
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  tags = merge(
    {
      Environment = var.environment
      Name        = "8byte-db-${var.environment}"
    },
    var.tags
  )
}
