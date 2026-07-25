variable "project_name" {
  description = "Name of the project"
  type        = string
}


variable "environment" {
  description = "Deployment environment"
  type        = string
}


variable "vpc_id" {
  description = "VPC ID"
  type        = string
}


variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}


variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}


variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}


variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}


variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}


variable "container_image" {
  description = "Docker image URI"
  type        = string

  default = "public.ecr.aws/docker/library/nginx:latest"
}


variable "cpu" {
  description = "Fargate task CPU units"
  type        = number

  default = 256
}


variable "memory" {
  description = "Fargate task memory in MB"
  type        = number

  default = 512
}


variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number

  default = 2
}


variable "min_capacity" {
  description = "Minimum ECS task count"
  type        = number

  default = 2
}


variable "max_capacity" {
  description = "Maximum ECS task count"
  type        = number

  default = 6
}
