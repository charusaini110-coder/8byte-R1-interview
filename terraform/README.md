# Terraform Infrastructure as Code

This directory contains the Terraform configuration for provisioning the 8byte infrastructure on AWS.

## 📁 Directory Structure

```
terraform/
├── main.tf                 # Root module orchestrating all sub-modules
├── variables.tf            # Input variables for root module
├── outputs.tf              # Root module outputs
├── providers.tf            # AWS provider and backend configuration
├── terraform.tfvars        # Variable values and resource configuration
├── PROVIDER_SETUP.md       # Instructions for configuring AWS backend
├── BACKEND_SETUP.md        # Guide for S3/DynamoDB state management
├── modules/
│   ├── vpc/               # VPC module (networking)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security_groups/   # Security groups module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/               # Application Load Balancer module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/               # EC2 instances module (for_each)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── rds/               # RDS database module (for_each)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with credentials
- AWS Account ID (get with: `aws sts get-caller-identity --query Account --output text`)

### 1. Initialize Terraform

```bash
cd terraform/

# Initialize with S3 backend (replace with your account ID)
terraform init \
  -backend-config="bucket=8byte-tf-state-123456789012" \
  -backend-config="dynamodb_table=8byte-tf-lock" \
  -backend-config="key=terraform/state.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="encrypt=true"
```

### 2. Configure Variables

Edit `terraform.tfvars` and set:
- `db_username` (PostgreSQL admin user)
- `db_password` (PostgreSQL admin password)

Or pass via command line:
```bash
terraform plan \
  -var="db_username=admin" \
  -var="db_password=your-password"
```

### 3. Plan & Apply

```bash
# Review changes
terraform plan

# Deploy infrastructure
terraform apply

# Destroy (if needed)
terraform destroy
```

## 📦 Modules Overview

### vpc/
Creates VPC with public and private subnets across multiple AZs.

**Outputs:**
- `vpc_id` - VPC identifier
- `public_subnets` - List of public subnet IDs
- `private_subnets` - List of private subnet IDs
- `database_subnet_group_name` - RDS subnet group

### security_groups/
Creates security groups for ALB, EC2, and RDS with appropriate ingress/egress rules.

**Outputs:**
- `alb_sg_id` - ALB security group
- `ec2_sg_id` - EC2 security group
- `db_sg_id` - RDS security group

### alb/
Creates Application Load Balancer with target group and HTTP listener.

**Features:**
- Uses `for_each` for multiple ALBs
- Health checks configured
- Target group attachment to EC2

**Outputs:**
- `alb_dns_name` - ALB endpoint
- `target_group_arn` - Target group for EC2 registration

### ec2/
Creates EC2 instances with Docker pre-installed.

**Features:**
- Uses `for_each` for multiple instances
- User data script for Docker installation
- Automatic ALB target group attachment

**Outputs:**
- `instance_id` - EC2 instance ID
- `instance_public_ip` - Public IP address

### rds/
Creates PostgreSQL RDS database with automated backups.

**Features:**
- Uses `for_each` for multiple databases
- Point-in-time recovery enabled
- Encryption at rest

**Outputs:**
- `db_endpoint` - RDS connection string
- `db_address` - RDS hostname

## 🔄 Resource Management with for_each

The configuration uses `for_each` for EC2 instances, ALBs, and RDS databases, allowing easy scaling:

```hcl
# terraform.tfvars
ec2_instances = {
  app_server_1 = {
    enabled       = true
    instance_type = "t2.micro"
    name          = "app-server-1"
  }
  app_server_2 = {
    enabled       = true
    instance_type = "t2.micro"
    name          = "app-server-2"
  }
}
```

Add/remove entries to scale resources.

## 🎯 Resource Targeting

Deploy specific modules without affecting others:

```bash
# Plan only VPC
terraform plan -target=module.vpc

# Apply only EC2
terraform apply -target=module.ec2

# Destroy only RDS
terraform destroy -target=module.rds
```

See `.github/workflows/RESOURCE_TARGETING.md` for GitHub Actions integration.

## 🔒 State Management

State is stored in S3 with DynamoDB locking:
- **Encryption**: AES256
- **Versioning**: Enabled for rollback
- **Locking**: DynamoDB prevents concurrent modifications
- **Backup**: Point-in-time recovery enabled

See `BACKEND_SETUP.md` for detailed setup.

## 📝 Variable Configuration

### Required Variables
```hcl
db_username     # PostgreSQL admin username (sensitive)
db_password     # PostgreSQL admin password (sensitive)
```

### Optional Variables with Defaults

```hcl
aws_region              = "ap-south-1"
environment             = "staging"
vpc_config = {
  cidr               = "10.0.0.0/16"
  enable_nat_gateway = false
}
alb_config = {
  primary = {
    enabled = true
    name    = "primary"
  }
}
ec2_instances = {
  app_server_1 = {
    enabled       = true
    instance_type = "t2.micro"
    ami_id        = "ami-0c2af51e265bd5e0e"
    name          = "app-server-1"
  }
}
rds_databases = {
  postgres_primary = {
    enabled          = true
    engine_version   = "15.4"
    instance_class   = "db.t3.micro"
    allocated_storage = 20
    multi_az         = false
    name             = "postgres-primary"
  }
}
```

## ⚠️ Important Notes

### 1. ALB Requirement for EC2
EC2 instances require an ALB to be configured. The validation in `main.tf` will prevent deploying EC2 without ALB.

### 2. Security Groups Dependencies
Security groups depend on VPC. Always deploy VPC first.

### 3. Resource Naming
Resources are automatically tagged with:
- `Project`: 8byte
- `Environment`: From `var.environment`
- `ManagedBy`: Terraform

### 4. Cost Optimization
- All resources use Free Tier eligible instance types
- NAT Gateway disabled by default (set `enable_nat_gateway = true` if needed)
- DynamoDB uses pay-per-request billing

### 5. Credentials
Never commit `terraform.tfvars` with actual passwords:
```bash
# Add to .gitignore
terraform.tfvars
```

## 🔧 Common Commands

```bash
# Validate configuration
terraform validate

# Format code (recommended)
terraform fmt -recursive

# Plan specific module
terraform plan -target=module.ec2

# Apply with auto-approve (use with caution)
terraform apply -auto-approve

# Destroy specific resources
terraform destroy -target=module.rds["postgres_primary"]

# Show state
terraform state list
terraform state show module.ec2["app_server_1"]

# Refresh state
terraform refresh

# Force unlock (if stuck)
terraform force-unlock <LOCK_ID>
```

## 📊 Outputs

After `terraform apply`, retrieve outputs:

```bash
# All outputs
terraform output

# Specific output
terraform output alb_dns_name

# JSON format
terraform output -json
```

## 🐛 Troubleshooting

### State Lock Error
```bash
# Check lock
aws dynamodb scan --table-name 8byte-tf-lock

# Force unlock
terraform force-unlock <LOCK_ID>
```

### Backend Initialization Failed
```bash
# Verify S3 bucket exists
aws s3 ls | grep 8byte-tf-state

# Reconfigure backend
terraform init -reconfigure
```

### Module Not Found
```bash
# Reinitialize modules
terraform init -upgrade
```

### Invalid AWS Credentials
```bash
# Verify credentials
aws sts get-caller-identity

# Configure new credentials
aws configure
```

## 📚 Documentation

- **PROVIDER_SETUP.md** - AWS provider configuration options
- **BACKEND_SETUP.md** - S3 backend and state locking details
- **.github/workflows/RESOURCE_TARGETING.md** - GitHub Actions resource targeting
- **.github/workflows/TERRAFORM_PIPELINE.md** - CI/CD pipeline setup

## 🔐 Security Best Practices

1. **Never commit sensitive data** (passwords, keys)
2. **Use GitHub Secrets** for credentials in CI/CD
3. **Enable MFA** on AWS account
4. **Rotate credentials** regularly
5. **Audit Terraform State Access** via CloudTrail
6. **Use `terraform plan` before apply**
7. **Enable resource tagging** for cost tracking

## 🚀 Deployment via GitHub Actions

For automated deployments with resource targeting:

```bash
# Plan all resources
gh workflow run terraform-provision.yml -f action=plan -f resource_target=all

# Apply only EC2
gh workflow run terraform-provision.yml -f action=apply -f resource_target=ec2

# Destroy only RDS
gh workflow run terraform-provision.yml -f action=destroy -f resource_target=rds
```

See `.github/workflows/` for pipeline documentation.

## 📞 Support

For issues or questions:
1. Check `terraform validate` output
2. Review AWS CloudTrail logs
3. Check Terraform state: `terraform state list`
4. Review module documentation in individual module folders
