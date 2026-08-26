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
