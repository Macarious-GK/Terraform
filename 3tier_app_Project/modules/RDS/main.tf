resource "aws_db_subnet_group" "RDS_subnet_group" {
  name       = "${var.identifier_name}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "RDS_parameter_group" {
  name        = "${var.identifier_name}-param-group"
  family      = var.parameter_group_family
  description = "Custom parameter group for ${var.engine}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}


resource "aws_db_instance" "General_RDS_instance" {

  identifier            = var.identifier_name
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.RDS_subnet_group.name
  vpc_security_group_ids = var.vpc_security_group_ids

  parameter_group_name = aws_db_parameter_group.RDS_parameter_group.name
  publicly_accessible     = var.publicly_accessible
  deletion_protection     = var.deletion_protection
  multi_az                = var.multi_az
  skip_final_snapshot     = true
  backup_retention_period = 7
}