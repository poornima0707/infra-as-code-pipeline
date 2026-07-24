terraform {
  backend "s3" {
    bucket         = "infra-as-code-pipeline-tfstate-poornima-2026"
    key            = "infra-as-code-pipeline/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
