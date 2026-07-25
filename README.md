# Infrastructure as Code CI/CD Pipeline

A production-style DevOps project that provisions AWS infrastructure using Terraform and automates the build, security scanning, container image publishing, and deployment of a Node.js backend application to Amazon ECS Fargate using GitHub Actions.

---

## Project Overview

This project demonstrates an end-to-end Infrastructure as Code and CI/CD workflow.

The infrastructure is provisioned using Terraform, the backend application is containerized using Docker, the image is stored in Amazon ECR, and the application is deployed to Amazon ECS Fargate behind an Application Load Balancer.

The complete deployment process is automated using GitHub Actions.

---

## Architecture

```text
Developer
    |
    | Git Push
    v
GitHub Repository
    |
    v
GitHub Actions CI/CD
    |
    +-----------------------------+
    |                             |
    v                             v
Backend Tests                 Terraform
    |                         Plan & Apply
    v                             |
Docker Build                    v
    |                         AWS VPC
    v                             |
Trivy Security Scan               |
    |                             v
    v                       Public Subnets
Amazon ECR                       |
    |                             v
    +----------------------> Application
                              Load Balancer
                                  |
                                  v
                            Private Subnets
                                  |
                                  v
                           ECS Fargate Service
                                  |
                                  v
                          Node.js Backend API
```

---

## Technologies Used

### Application

* Node.js
* Express.js
* CORS

### Containerization

* Docker
* Docker Hub / Amazon ECR

### Infrastructure as Code

* Terraform

### Cloud Platform

* Amazon Web Services (AWS)
* Amazon VPC
* Amazon ECS Fargate
* Application Load Balancer
* Amazon ECR
* IAM
* CloudWatch Logs
* NAT Gateway
* Internet Gateway

### CI/CD and Security

* GitHub Actions
* Trivy vulnerability scanner
* Terraform Plan
* Terraform Apply

---

## Project Structure

```text
infra-as-code-pipeline/
│
├── application-code/
│   └── backend/
│       ├── Dockerfile
│       ├── index.js
│       ├── package.json
│       └── package-lock.json
│
├── terraform/
│   │
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars
│   │
│   └── modules/
│       │
│       ├── networking/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       │
│       ├── security/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       │
│       ├── compute/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       │
│       └── monitoring/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
└── README.md
```

---

## Backend Application

The backend is a Node.js Express application running on port `3500`.

### Available Endpoints

| Endpoint  | Description          |
| --------- | -------------------- |
| `/`       | Application status   |
| `/health` | ALB health check     |
| `/ready`  | Readiness check      |
| `/api`    | Example API endpoint |

### Example Health Response

```json
{
  "status": "healthy",
  "service": "infra-as-code-pipeline-backend",
  "environment": "dev"
}
```

---

## Docker

The backend application is packaged into a Docker image.

Example Dockerfile:

```dockerfile
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 3500

CMD ["node", "index.js"]
```

Build the image locally:

```bash
docker build -t mern-backend:latest .
```

Run locally:

```bash
docker run -p 3500:3500 mern-backend:latest
```

Test:

```bash
curl http://localhost:3500/health
```

---

## AWS Infrastructure

Terraform provisions the following infrastructure.

### Networking

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Route tables
* Route table associations

### Security

* ALB security group
* ECS security group
* HTTP ingress rules
* Internal ECS traffic rules
* Outbound traffic rules

### Load Balancing

* Application Load Balancer
* Target Group
* HTTP Listener
* Health check endpoint: `/health`

### ECS

* ECS Cluster
* Fargate Task Definition
* ECS Service
* Auto Scaling Target
* CPU Auto Scaling Policy

### Monitoring

* CloudWatch Log Group
* ECS container logging

---

## Terraform Deployment

Navigate to the development environment:

```bash
cd terraform/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Format Terraform code:

```bash
terraform fmt -recursive
```

Validate the configuration:

```bash
terraform validate
```

Create a plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

---

## CI/CD Pipeline

The GitHub Actions workflow automates the complete deployment lifecycle.

### Pipeline Flow

```text
Code Push
    |
    v
Checkout Source Code
    |
    v
Install Dependencies
    |
    v
Run Backend Tests
    |
    v
Build Docker Image
    |
    v
Run Trivy Security Scan
    |
    v
Authenticate with Amazon ECR
    |
    v
Push Docker Image to ECR
    |
    v
Terraform Init
    |
    v
Terraform Plan
    |
    v
Terraform Apply
    |
    v
Render ECS Task Definition
    |
    v
Deploy to ECS Fargate
    |
    v
Wait for ECS Service Stability
```

---

## Container Image

The Docker image is pushed to Amazon ECR.

Example:

```text
943938400079.dkr.ecr.ap-south-1.amazonaws.com/mern-backend:latest
```

The ECS task definition uses this image to deploy the backend application.

---

## Security Scanning

Trivy is used to scan the container image for vulnerabilities.

Example:

```bash
trivy image mern-backend:latest
```

This helps identify:

* Operating system vulnerabilities
* Package vulnerabilities
* Dependency vulnerabilities
* Critical security issues

---

## ECS Deployment

The application runs on Amazon ECS Fargate.

Configuration:

```text
Cluster:
infra-as-code-pipeline-dev

Service:
infra-as-code-pipeline-dev-service

Container:
infra-as-code-pipeline-dev-container

Container Port:
3500

Desired Tasks:
2
```

The service runs two tasks for availability.

---

## Health Checks

The Application Load Balancer uses:

```text
GET /health
```

The backend returns HTTP status code:

```text
200 OK
```

A healthy deployment can be verified using:

```bash
curl http://<ALB-DNS-NAME>/health
```

Example response:

```json
{
  "status": "healthy",
  "service": "infra-as-code-pipeline-backend",
  "environment": "dev"
}
```

---

## Useful AWS Verification Commands

### Check ECS Service

```bash
aws ecs describe-services \
  --cluster infra-as-code-pipeline-dev \
  --services infra-as-code-pipeline-dev-service \
  --region ap-south-1
```

### Check Target Health

```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET-GROUP-ARN> \
  --region ap-south-1
```

### Check ECS Task Definition

```bash
aws ecs describe-task-definition \
  --task-definition infra-as-code-pipeline-dev \
  --region ap-south-1
```

### Check ECR Images

```bash
aws ecr describe-images \
  --repository-name mern-backend \
  --region ap-south-1
```

---

## Key DevOps Concepts Demonstrated

This project demonstrates practical experience with:

* Infrastructure as Code
* Terraform modules
* AWS networking
* Public and private subnet architecture
* NAT Gateway
* ECS Fargate
* Container orchestration
* Docker image management
* Amazon ECR
* Application Load Balancer
* Health checks
* CloudWatch logging
* CI/CD automation
* GitHub Actions
* Container security scanning
* Automated cloud deployments
* ECS service stability
* Auto scaling

---

## Deployment Result

The final system provides:

```text
GitHub Push
     ↓
Automated CI/CD Pipeline
     ↓
Test
     ↓
Build
     ↓
Security Scan
     ↓
Push to ECR
     ↓
Terraform Infrastructure
     ↓
ECS Fargate Deployment
     ↓
Application Load Balancer
     ↓
Live Backend API
```

---

## Author

**Poornima Kamatar**

Computer Science Engineer | DevOps | Cloud | AI/ML

---

## Project Status

Completed

The project successfully implements an automated Infrastructure as Code and CI/CD pipeline for deploying a containerized Node.js backend application to AWS ECS Fargate.
