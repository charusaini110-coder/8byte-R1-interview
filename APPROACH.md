 Architectural Approach and Rationale

The objective of this assignment was to demonstrate end-to-end infrastructure provisioning and deployment automation for a web application. Below is the rationale behind the technical decisions made to fulfill these requirements.

## 1. Compute Choice: EC2 over ECS/EKS
While container orchestration tools like Amazon EKS or ECS (with Fargate) represent the enterprise standard for microservices, they introduce significant baseline costs. ECS Fargate charges per vCPU/GB per hour, and EKS requires a $70/month control plane fee. 

**Rationale:** To strictly adhere to the AWS Free Tier while still demonstrating containerized deployments, I opted for an EC2 `t2.micro` instance running Docker engine. This provides a platform to run the containerized Python LLM router application at zero cost, while the deployment logic (SSH and Docker pull) in the GitHub Actions pipeline proves an understanding of automated container lifecycles.

## 2. Networking Strategy: Maximizing Security within Free Tier
A standard enterprise VPC design places compute nodes in private subnets and uses a NAT Gateway to allow them to pull updates and Docker images from the internet. However, NAT Gateways cost approximately $30/month.

**Rationale:** I implemented a hybrid approach. The RDS database strictly resides in a private subnet to demonstrate data-tier security. The EC2 instance resides in a public subnet, allowing it to pull from Amazon ECR without a NAT Gateway. Security for the compute layer is enforced exclusively via strict AWS Security Groups, allowing inbound traffic *only* from the Application Load Balancer (ALB) and SSH from the deployment pipeline.

## 3. CI/CD Implementation: GitHub Actions
**Rationale:** I selected GitHub Actions over Jenkins or GitLab CI. Jenkins requires standing up and maintaining a separate compute instance, increasing both operational overhead and AWS costs. GitHub Actions is natively integrated with the source code repository, agentless (from an infrastructure perspective), and provides excellent community actions (like `appleboy/ssh-action` and `aquasecurity/trivy-action`) to rapidly build robust, secure pipelines.

## 4. Application Context: Python LLM Router
**Rationale:** Although application logic was not the focus, I utilized a containerized Python service simulating LLM routing. This reflects a modern AI workload, keeping the infrastructure test grounded in a realistic, data-driven use case relevant to today's financial services tech landscape. 

## 5. Observability Strategy
**Rationale:** Centralized logging and monitoring are simulated by structuring the application to output JSON-formatted logs to standard out (`stdout`), which can easily be picked up by an agent like CloudWatch Logs or Datadog in a production environment. 