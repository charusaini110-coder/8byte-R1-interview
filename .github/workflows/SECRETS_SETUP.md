# GitHub Secrets Quick Setup

## Required Secrets for Terraform Pipeline

Set these in **Repository → Settings → Secrets and variables → Actions**

### AWS Credentials

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AWS_ACCESS_KEY_ID` | IAM user access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key | (20+ characters) |
| `AWS_ACCOUNT_ID` | AWS Account ID | `123456789012` |

### Database Credentials

| Secret Name | Value | Example |
|-------------|-------|---------|
| `DB_USERNAME` | PostgreSQL admin user | `admin` |
| `DB_PASSWORD` | PostgreSQL admin password | (Strong password) |

## Quick Setup Steps

### 1. Get AWS Credentials

```bash
# Login to AWS Console
# IAM → Users → Create user → "terraform-ci"
# Attach policy: "AdministratorAccess" (or create custom policy)
# Create access key
# Copy Access Key ID and Secret Access Key
```

### 2. Get AWS Account ID

```bash
aws sts get-caller-identity --query Account --output text
# Output: 123456789012
```

### 3. Set Secrets via GitHub CLI

```bash
# AWS Credentials
gh secret set AWS_ACCESS_KEY_ID --body "AKIAIOSFODNN7EXAMPLE"
gh secret set AWS_SECRET_ACCESS_KEY --body "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
gh secret set AWS_ACCOUNT_ID --body "123456789012"

# Database Credentials
gh secret set DB_USERNAME --body "admin"
gh secret set DB_PASSWORD --body "MySecurePassword123!@#"
```

### 4. Verify Secrets

```bash
gh secret list
```

## Security Recommendations

### 🔒 IAM Policy for Terraform

Create minimal IAM policy for terraform user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*",
        "elasticloadbalancing:*",
        "s3:GetObject",
        "s3:ListBucket",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": "*"
    }
  ]
}
```

### 🔑 Create IAM User for CI/CD

```bash
# Create user
aws iam create-user --user-name terraform-ci

# Attach policy
aws iam put-user-policy --user-name terraform-ci \
  --policy-name terraform-access \
  --policy-document file://policy.json

# Create access key
aws iam create-access-key --user-name terraform-ci
```

### ⚡ Rotate Credentials Regularly

```bash
# Deactivate old key
aws iam update-access-key --user-name terraform-ci \
  --access-key-id AKIAIOSFODNN7EXAMPLE \
  --status Inactive

# Create new key
aws iam create-access-key --user-name terraform-ci

# Update GitHub secrets with new key
gh secret set AWS_ACCESS_KEY_ID --body "NEW_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "NEW_SECRET_KEY"
```

## Verify Setup

Run a test workflow:

```bash
# Via GitHub CLI
gh workflow run terraform-provision.yml -f action=plan
```

Check logs in GitHub Actions UI to confirm secrets are available.

## Troubleshooting

### Secret not found during workflow

**Solution:**
```bash
# Verify secret exists
gh secret list | grep AWS

# Recreate if missing
gh secret set AWS_ACCESS_KEY_ID --body "your-key"
```

### AWS credentials invalid error

**Solution:**
```bash
# Test credentials locally
aws sts get-caller-identity

# If invalid, create new access key and update secrets
```

### DB_PASSWORD not working

**Solution:**
```bash
# Ensure special characters are properly escaped
# Use strong password with quotes if needed
gh secret set DB_PASSWORD --body "complex!@#$%password"
```
