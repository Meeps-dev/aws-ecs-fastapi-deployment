locals {
  public_subnets = {
    for index, availability_zone in var.availability_zones :
    availability_zone => {
      availability_zone = availability_zone
      cidr_block        = var.public_subnet_cidrs[index]
      position          = index + 1
    }
  }

  private_db_subnets = {
    for index, availability_zone in var.availability_zones :
    availability_zone => {
      availability_zone = availability_zone
      cidr_block        = var.private_db_subnet_cidrs[index]
      position          = index + 1
    }
  }
}
