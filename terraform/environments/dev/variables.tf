# ---------------------------------------------------------
# PROJECT
# ---------------------------------------------------------

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "infra-as-code-pipeline"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}


# ---------------------------------------------------------
# NETWORKING
# ---------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "availability_zones" {
  description = "Availability zones for the deployment"
  type        = list(string)

  default = [
    "ap-south-1a",
    "ap-south-1b"
  ]
}


# ---------------------------------------------------------
# APPLICATION
# ---------------------------------------------------------

variable "container_image" {
  description = "Docker image used by ECS"
  type        = string

  default = "943938400079.dkr.ecr.ap-south-1.amazonaws.com/mern-backend:latest"
}

variable "container_port" {
  description = "Port on which the application container listens"
  type        = number
  default     = 3500
}


# ---------------------------------------------------------
# ECS COMPUTE
# ---------------------------------------------------------

variable "cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum ECS service capacity"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum ECS service capacity"
  type        = number
  default     = 4
}


# ---------------------------------------------------------
# SECURITY
# ---------------------------------------------------------

variable "alb_ingress_cidr" {
  description = "CIDR allowed to access the Application Load Balancer"
  type        = list(string)

  default = [
    "0.0.0.0/0"
  ]
}
