resource "aws_secretsmanager_secret" "database" {
  name = "${var.project_name}/database"

  description = "PostgreSQL credentials for the Platform Engineer application"

  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-database-secret"
  }
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    database = aws_db_instance.postgres.db_name
  })
}
