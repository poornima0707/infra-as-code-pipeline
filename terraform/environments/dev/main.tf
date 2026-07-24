module "networking" {
  source = "../../modules/networking"

  project_name = "infra-as-code-pipeline"
  environment  = "dev"

  vpc_cidr = "10.0.0.0/16"

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  enable_nat_gateway = true
}
module "security" {
  source = "../../modules/security"

  project_name = "infra-as-code-pipeline"
  environment  = "dev"

  vpc_id         = module.networking.vpc_id
  container_port = 8080
}
module "monitoring" {
  source = "../../modules/monitoring"

  project_name = "infra-as-code-pipeline"
  environment  = "dev"

  retention_in_days = 30
}
