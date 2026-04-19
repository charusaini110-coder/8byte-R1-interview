# Complete Provider Configuration for Easy Implementation

## Option 1: Simple Implementation (Recommended for Quick Start)

Copy and paste this into your `terraform/providers.tf`:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state management via S3 and DynamoDB for locking
  backend "s3" {
    bucket         = "8byte-tf-state-123456789012"  # Replace 123456789012 with your AWS account ID
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "8byte-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
```

### Implementation Steps:

1. **Get your AWS Account ID:**
   ```bash
   aws sts get-caller-identity --query Account --output text
   ```
   Output example: `123456789012`

2. **Replace the account ID in providers.tf:**
   ```hcl
   bucket = "8byte-tf-state-123456789012"  # Use your actual account ID
   ```

3. **Initialize Terraform with backend:**
   ```bash
   cd terraform/
   terraform init
   ```

4. **Verify backend is configured:**
   ```bash
   terraform state list
   ```

---

## Option 2: Dynamic Implementation (Using Environment Variables)

If you want the account ID to be dynamic, create a separate backend config file:

### File: `terraform/backend-config.hcl`

```hcl
bucket         = "8byte-tf-state-123456789012"
key            = "terraform/state.tfstate"
region         = "ap-south-1"
dynamodb_table = "8byte-tf-lock"
encrypt        = true
```

### File: `terraform/providers.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
```

### Initialize with backend config:

```bash
cd terraform/
terraform init -backend-config=backend-config.hcl
```

---

## Option 3: Automated with Bash Script

Create `terraform/setup-backend.sh`:

```bash
#!/bin/bash

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Update providers.tf with account ID
sed -i '' "s/8byte-tf-state-[0-9]\{12\}/8byte-tf-state-${ACCOUNT_ID}/g" providers.tf

echo "✅ Backend configured with account ID: $ACCOUNT_ID"

# Initialize Terraform
terraform init

echo "✅ Terraform initialized with S3 backend"
```

### Run it:
```bash
cd terraform/
chmod +x setup-backend.sh
./setup-backend.sh
```

---

## Quick Copy-Paste Reference

### For macOS/Linux:
```bash
# 1. Get your account ID
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

# 2. Navigate to terraform directory
cd terraform/

# 3. Create providers.tf with your account ID
cat > providers.tf << EOF
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "8byte-tf-state-${AWS_ACCOUNT}"
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "8byte-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
EOF

# 4. Initialize
terraform init
```

### For Windows PowerShell:
```powershell
# 1. Get your account ID
$AWS_ACCOUNT = aws sts get-caller-identity --query Account --output text

# 2. Navigate to terraform directory
cd terraform/

# 3. Create providers.tf
@"
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "8byte-tf-state-$AWS_ACCOUNT"
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "8byte-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
"@ | Out-File providers.tf -Encoding UTF8

# 4. Initialize
terraform init
```

---

## Verification Checklist

After implementation, verify:

```bash
# ✅ Check backend is configured
terraform state list

# ✅ Check S3 bucket exists
aws s3 ls | grep 8byte-tf-state

# ✅ Check DynamoDB table exists
aws dynamodb list-tables | grep 8byte-tf-lock

# ✅ Check state file in S3
aws s3 ls s3://8byte-tf-state-123456789012/terraform/
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Error: bucket already exists` | Use a different bucket name or check if bucket exists |
| `AccessDenied` | Verify IAM permissions for S3 and DynamoDB |
| `backend initialization required` | Run `terraform init -backend-config=...` |
| `state lock timeout` | DynamoDB table may be missing - check `8byte-tf-lock` exists |

---

## Need to Migrate from Local State?

```bash
# Backup local state
cp terraform.tfstate terraform.tfstate.backup

# Initialize with backend
terraform init

# When prompted, confirm migrating state to remote
```

---

## Reset Backend Configuration

If you need to reconfigure the backend:

```bash
# Reinitialize with new backend config
terraform init -reconfigure -backend-config=backend-config.hcl
```
