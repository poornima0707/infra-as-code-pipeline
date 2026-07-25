# Infrastructure as Code CI/CD Pipeline Runbook

## 1. Project Overview

This runbook describes how to deploy, verify, troubleshoot, and roll back the Infrastructure as Code CI/CD pipeline.

The application is a containerized Node.js backend deployed to Amazon ECS Fargate using Terraform and GitHub Actions.

---

## 2. Technology Stack

* AWS
* Terraform
* Docker
* Amazon ECR
* Amazon ECS Fargate
* Application Load Balancer
* GitHub Actions
* Trivy
* CloudWatch Logs

---

## 3. Repository Structure

```text
application-code/backend
terraform/environments/dev
terraform/modules/networking
terraform/modules/security
terraform/modules/compute
terraform/modules/monitoring
.github/workflows
```

---

## 4. Local Backend Testing

Navigate to the backend:

```bash
cd application-code/backend
```

Install dependencies:

```bash
npm install
```

Start the application:

```bash
node index.js
```

Test the health endpoint:

```bash
curl http://localhost:3500/health
```

Expected result:

```json
{
  "status": "healthy"
}
```

---

## 5. Docker Testing

Build the image:

```bash
docker build -t mern-backend:latest .
```

Run the container:

```bash
docker run -p 3500:3500 mern-backend:latest
```

Test:

```bash
curl http://localhost:3500/health
```

---

## 6. Terraform Deployment

Navigate to the environment:

```bash
cd terraform/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Format the code:

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

Apply infrastructure:

```bash
terraform apply
```

---

## 7. CI/CD Deployment

The GitHub Actions pipeline performs the following:

1. Checks out the source code.
2. Installs backend dependencies.
3. Tests the backend application.
4. Builds the Docker image.
5. Scans the image using Trivy.
6. Authenticates with Amazon ECR.
7. Pushes the Docker image to ECR.
8. Executes Terraform validation and planning.
9. Applies the infrastructure changes.
10. Updates the ECS task definition.
11. Deploys the new version to ECS.
12. Waits for ECS service stability.

A successful deployment should result in the ECS service reaching:

```text
runningCount = desiredCount
rolloutState = COMPLETED
```

---

## 8. ECS Service Verification

Check the ECS service:

```bash
aws ecs describe-services \
  --cluster infra-as-code-pipeline-dev \
  --services infra-as-code-pipeline-dev-service \
  --region ap-south-1
```

Verify:

* Service status is ACTIVE.
* Desired count is running.
* Deployment rollout is COMPLETED.

---

## 9. Load Balancer Health Verification

Find the ALB DNS name:

```bash
terraform output -raw alb_dns_name
```

Test the application:

```bash
curl http://<ALB-DNS-NAME>/health
```

Expected response:

```json
{
  "status": "healthy",
  "service": "infra-as-code-pipeline-backend"
}
```

---

## 10. Target Health Verification

Check the target group:

```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET-GROUP-ARN> \
  --region ap-south-1
```

Expected state:

```text
healthy
```

---

## 11. Troubleshooting

### ECS Tasks Are Not Starting

Check the ECS service events:

```bash
aws ecs describe-services \
  --cluster infra-as-code-pipeline-dev \
  --services infra-as-code-pipeline-dev-service \
  --region ap-south-1 \
  --query "services[0].events[0:10]"
```

Check stopped tasks:

```bash
aws ecs list-tasks \
  --cluster infra-as-code-pipeline-dev \
  --desired-status STOPPED \
  --region ap-south-1
```

---

### ALB Target Is Unhealthy

Verify:

* Application listens on port 3500.
* ECS task exposes port 3500.
* Target group uses port 3500.
* Health check path is `/health`.
* The application returns HTTP 200.
* ECS security group allows traffic from the ALB security group.

---

### Docker Image Cannot Be Pulled

Check:

* The image exists in Amazon ECR.
* ECS task execution role has the required permissions.
* The image URI is correct.
* The AWS region is correct.

---

### GitHub Actions Deployment Fails

Check:

* AWS credentials are configured correctly.
* GitHub Actions secrets are present.
* The ECR repository exists.
* The ECS cluster and service exist.
* Terraform validation succeeds.

---

## 12. Rollback Procedure

If a new deployment causes the ECS service to fail, identify the previous task definition revision:

```bash
aws ecs list-task-definitions \
  --family-prefix infra-as-code-pipeline-dev \
  --status ACTIVE \
  --region ap-south-1
```

Deploy a previous task definition revision:

```bash
aws ecs update-service \
  --cluster infra-as-code-pipeline-dev \
  --service infra-as-code-pipeline-dev-service \
  --task-definition infra-as-code-pipeline-dev:<PREVIOUS_REVISION> \
  --region ap-south-1
```

Wait for the service to become stable:

```bash
aws ecs wait services-stable \
  --cluster infra-as-code-pipeline-dev \
  --services infra-as-code-pipeline-dev-service \
  --region ap-south-1
```

Verify:

```bash
curl http://<ALB-DNS-NAME>/health
```

---

## 13. Infrastructure Destruction

To destroy the development environment:

```bash
cd terraform/environments/dev
terraform destroy
```

Use this command carefully because it deletes the AWS infrastructure managed by Terraform.

---

## 14. Successful Deployment Criteria

The deployment is considered successful when:

* GitHub Actions workflow completes successfully.
* Docker image is available in Amazon ECR.
* ECS tasks are running.
* ECS service is stable.
* ALB targets are healthy.
* `/health` returns HTTP 200.
* The application is accessible through the ALB DNS name.

---

## 15. Final Verification

```bash
curl http://<ALB-DNS-NAME>/health
```

Successful response:

```json
{
  "status": "healthy"
}
```

This confirms that the complete CI/CD pipeline has successfully deployed the application to AWS.
