resource "aws_db_subnet_group" "strapi_db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  # Use all subnets from the Default VPC for the database
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "strapi_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.5" # <-- FINAL UPDATED VERSION
  instance_class         = "db.t3.micro"
  db_name                = "${var.project_name}db"
  username               = "strapiadmin"
  password               = var.db_password
  parameter_group_name   = "default.postgres15" # <-- UPDATED to match version 15
  skip_final_snapshot    = true
  # Note: In a Default VPC, the database will be in a public subnet.
  # Access is restricted by the security group.
  publicly_accessible    = true 
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.strapi_db_subnet_group.name
}

