terraform {
  backend "s3" {
    bucket       = "meeps-terraform-state-256748318717-eu-west-2"
    key          = "aws-ecs-fastapi-deployment/week-13/dev/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
