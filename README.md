# 8byte-R1-interview

# 8byte DevOps Assignment: Infrastructure & Deployment Automation

This repository contains the Infrastructure as Code (IaC) and CI/CD pipelines for deploying a containerized Python-based LLM Routing Service to AWS. The architecture is explicitly designed to maximize efficiency and maintain security practices while strictly operating within the AWS Free Tier limits.

## Infrastructure Architecture

The infrastructure is provisioned using Terraform and consists of:
* VPC: Custom VPC with isolated public and private subnets.
* Compute: An EC2 instance (`t2.micro`) running Docker, serving as the compute layer for the Python backend.
* Database: Amazon RDS for PostgreSQL (`db.t3.micro`) deployed in private subnets for secure data persistence.
* Load Balancing: An Application Load Balancer (ALB) to distribute incoming frontend/API traffic securely to the compute layer.
* State Management: Terraform state is securely stored in an S3 bucket with DynamoDB state locking.

## Prerequisites

To deploy this infrastructure, you will need:
* AWS CLI installed and configured with appropriate IAM credentials.
* Terraform (v1.5.0+) installed.
* A GitHub account for CI/CD pipeline execution.
* Docker installed locally (for local testing).

## How to Set Up and Run the Infrastructure

### 1. Provision Infrastructure (Terraform)
1. Navigate to the `terraform/` directory.
2. Initialize Terraform to download providers and setup the backend:
   ```bash
   terraform init