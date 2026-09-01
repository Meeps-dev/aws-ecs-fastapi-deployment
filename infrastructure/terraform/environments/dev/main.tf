module "vpc" {
  source = "../../modules/vpc"

  name_prefix             = local.name_prefix
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_db_subnet_cidrs = var.private_db_subnet_cidrs
  tags                    = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name_prefix      = local.name_prefix
  vpc_id           = module.vpc.vpc_id
  application_port = var.application_port
  database_port    = var.database_port
  tags             = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name          = var.ecr_repository_name
  force_delete             = var.ecr_force_delete
  max_image_count          = var.ecr_max_image_count
  untagged_expiration_days = var.ecr_untagged_expiration_days
  tags                     = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix            = local.name_prefix
  private_db_subnet_ids  = module.vpc.private_db_subnet_ids
  rds_security_group_id  = module.security.rds_security_group_id
  parameter_prefix       = local.ssm_parameter_prefix
  postgres_major_version = var.postgres_major_version
  db_instance_class      = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  db_username            = var.db_username
  backup_retention_days  = var.db_backup_retention_days
  db_password_version    = var.db_password_version
  database_url_version   = var.database_url_version
  tags                   = local.common_tags
}



module "ecs" {
  source = "../../modules/ecs"

  name_prefix    = local.name_prefix
  aws_region     = var.aws_region
  aws_account_id = data.aws_caller_identity.current.account_id

  ecr_repository_arn = module.ecr.repository_arn
  container_image    = "${module.ecr.repository_url}@${var.ecs_image_digest}"
  container_name     = "fastapi"
  container_port     = var.application_port

  log_group_name = "/meeps/week-13/${var.environment}/fastapi"

  environment = {
    PYTHONUNBUFFERED        = "1"
    PYTHONDONTWRITEBYTECODE = "1"
  }

  secret_parameter_arns = {
    DATABASE_URL = module.rds.database_url_parameter_arn
    SECRET_KEY   = aws_ssm_parameter.application_secret_key.arn
  }

  tags = local.common_tags
}
