resource "aws_db_subnet_group" "postgres" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}


resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"

  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5432

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  backup_retention_period = 1

  backup_window = "18:00-18:30"

  maintenance_window = "sun:19:00-sun:19:30"

  multi_az = false

  deletion_protection = false
  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  copy_tags_to_snapshot = true

  tags = {
    Name = "${var.project_name}-postgres"
  }
}