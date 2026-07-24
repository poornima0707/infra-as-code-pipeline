# Infrastructure as Code CI/CD Pipeline

## Project Overview

This project replaces manual application deployments with a fully automated Infrastructure as Code and CI/CD platform.

The infrastructure is provisioned using Terraform and deployed on AWS using:

- Amazon VPC
- Amazon ECS Fargate
- Application Load Balancer
- Amazon ECR
- IAM
- CloudWatch
- GitHub Actions

## Project Goals

- Provision AWS infrastructure using Terraform
- Use reusable Terraform modules
- Store Terraform state remotely in Amazon S3
- Use DynamoDB for state locking
- Build and push Docker images to Amazon ECR
- Deploy applications automatically to ECS Fargate
- Deploy pull requests to staging
- Require approval before production deployment
- Automatically rollback failed deployments
- Monitor applications using CloudWatch

## Environments

This project supports:

- Development
- Staging
- Production

## Technology Stack

| Category | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Cloud | AWS |
| Container Platform | ECS Fargate |
| Container Registry | Amazon ECR |
| Load Balancer | Application Load Balancer |
| CI/CD | GitHub Actions |
| Monitoring | CloudWatch |
| Containerization | Docker |
| State Management | S3 + DynamoDB |

## Project Status

🚧 Project under development.
