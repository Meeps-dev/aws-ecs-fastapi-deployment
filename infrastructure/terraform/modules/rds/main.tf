data "aws_rds_engine_version" "postgres" {
  engine  = "postgres"
  version = var.postgres_major_version
  latest  = true
}

ephemeral "random_password" "db_master" {
  length = 32

  upper   = true
  lower   = true
  numeric = true
  special = true

  min_upper   = 4
  min_lower   = 4
  min_numeric = 4
  min_special = 4

  # RDS passwords cannot contain /, double quotes, or @.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "${var.parameter_prefix}/database/password"
  description = "PostgreSQL master password for the Week 13 development database"

  type = "SecureString"
  tier = "Standard"

  value_wo         = ephemeral.random_password.db_master.result
  value_wo_version = var.db_password_version

  tags = merge(
    var.tags,
    {
      Name    = "${var.name_prefix}-database-password"
      Purpose = "rds-bootstrap-and-rotation"
    }
  )
}

ephemeral "aws_ssm_parameter" "db_password" {
  arn             = aws_ssm_parameter.db_password.arn
  with_decryption = true
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-db-subnet-group"
  description = "Private database subnets for the Week 13 PostgreSQL instance"
  subnet_ids  = var.private_db_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
      Tier = "database"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = data.aws_rds_engine_version.postgres.version_actual
  instance_class = var.db_instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = 0
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  port     = 5432

  password_wo         = ephemeral.aws_ssm_parameter.db_password.value
  password_wo_version = var.db_password_version

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]

  network_type        = "IPV4"
  publicly_accessible = false
  multi_az            = false

  backup_retention_period  = var.backup_retention_days
  copy_tags_to_snapshot    = true
  delete_automated_backups = true

  auto_minor_version_upgrade = true
  apply_immediately          = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  deletion_protection = false
  skip_final_snapshot = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-postgres"
      Tier = "database"
    }
  )

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "aws_ssm_parameter" "database_url" {
  name        = "${var.parameter_prefix}/database/url"
  description = "URL-encoded PostgreSQL DATABASE_URL consumed by ECS tasks"

  type = "SecureString"
  tier = "Standard"

  value_wo = format(
    "postgresql://%s:%s@%s:%d/%s",
    urlencode(var.db_username),
    urlencode(ephemeral.aws_ssm_parameter.db_password.value),
    aws_db_instance.this.address,
    aws_db_instance.this.port,
    var.db_name
  )

  value_wo_version = var.database_url_version

  tags = merge(
    var.tags,
    {
      Name    = "${var.name_prefix}-database-url"
      Purpose = "ecs-secret-injection"
    }
  )
}
