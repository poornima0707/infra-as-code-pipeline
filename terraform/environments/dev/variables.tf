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
