resource "random_password" "database" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "database" {
  name                    = "${var.project_name}/${var.environment}/database"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = "appuser"
    password = random_password.database.result
    database = "hello_world"
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = [for i in range(3) : aws_subnet.tier[i * 4 + 3].id]
  tags       = { Name = "${var.project_name}-db-subnets" }
}

resource "aws_db_instance" "main" {
  identifier              = "${var.project_name}-${var.environment}"
  engine                  = "mysql"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = max(var.db_allocated_storage, 100)
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = "hello_world"
  username                = "appuser"
  password                = random_password.database.result
  port                    = 3306
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.database.id]
  multi_az                = true
  publicly_accessible     = false
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately       = true

  depends_on = [aws_secretsmanager_secret_version.database]
}
