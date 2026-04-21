# Challenges and Resolutions

1. Challenge: AWS Free Tier Resource Limits
* **Issue:** Initially considered EKS, but realized the Control Plane cost would exceed the free tier.
* **solution:** switched to ECS with EC2 launch type to maintain orchestration while staying under the free usage limits.

2. Challenge: Database Connectivity
* **Issue:** The application could not connect to the RDS PostgreSQL instance from the ECS task.
* **solution:** Identified that the Security Group for RDS did not allow inbound traffic from the ECS Task Security Group. Updated Terraform to allow port 5432 between the specific SGs.

3. Challenge: Image Scanning Failures
* **Issue:** The CI/CD pipeline failed during the Trivy scan due to vulnerabilities in the base Docker image.
* **solution:** Switched the Dockerfile base image from `python:3.9` to `python:3.9-slim-bookworm` to reduce the attack surface and pass the security check.