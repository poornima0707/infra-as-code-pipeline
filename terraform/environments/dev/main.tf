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
  container_port = 80
}
module "monitoring" {
  source = "../../modules/monitoring"

  project_name = "infra-as-code-pipeline"
  environment  = "dev"

  retention_in_days = 30
}
module "compute" {
  source = "../../modules/compute"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.networking.vpc_id

  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id
  ecs_security_group_id = module.security.ecs_security_group_id

  log_group_name = module.monitoring.ecs_log_group_name

  container_image = "public.ecr.aws/docker/library/nginx:latest"

  cpu           = 256
  memory        = 512
  desired_count = 2
  min_capacity  = 2
  max_capacity  = 6
}