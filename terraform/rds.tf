resource "aws_db_subnet_group" "strapi_db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "strapi_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14.5"
  instance_class         = "db.t3.micro"
  db_name                = "${var.project_name}db"
  username               = "strapiadmin"
  password               = var.db_password
  parameter_group_name   = "default.postgres14"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.strapi_db_subnet_group.name
}

