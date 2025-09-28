# rds.tf
# Using random provider to generate a secure password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Database subnet group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private.*.id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Create the RDS instance (PostgreSQL)
resource "aws_db_instance" "main" {
  identifier           = "${var.project_name}-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  db_name              = "strapidb"
  username             = var.db_username
  password             = var.db_password != "" ? var.db_password : random_password.db_password.result
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot  = true
  publicly_accessible  = false

  tags = {
    Name = "${var.project_name}-rds"
  }
}
