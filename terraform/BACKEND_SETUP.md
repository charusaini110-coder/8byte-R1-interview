# Terraform S3 Backend Setup Guide

This guide explains how to set up and use the S3 backend for Terraform state management.

## Overview

The backend setup consists of:
- **S3 Bucket**: Stores the Terraform state file securely with versioning and encryption
- **DynamoDB Table**: Implements state locking to prevent concurrent modifications

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0 installed
- Sufficient IAM permissions to create S3 buckets and DynamoDB tables

## Step 1: Create Backend Infrastructure

Navigate to the backend-setup directory and apply the configuration:

```bash
cd terraform/backend-setup

# Initialize Terraform (no backend configured for setup)
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Note the outputs - you'll need these values
terraform output
```

**Example Output:**
```
backend_config = {
  "bucket" = "8byte-tf-state-123456789012"
  "dynamodb_table" = "8byte-tf-lock"
  "encrypt" = true
  "key" = "terraform/state.tfstate"
  "region" = "ap-south-1"
}
```

## Step 2: Configure Backend in Main Terraform

The backend is configured in `providers.tf`. The configuration uses:
- Bucket name: `8byte-tf-state-${AWS_ACCOUNT_ID}`
- DynamoDB table: `8byte-tf-lock`
- Encryption: Enabled (AES256)
- State file key: `terraform/state.tfstate`

## Step 3: Initialize Main Terraform with Backend

Navigate to the root terraform directory:

```bash
cd ../

# Initialize with the S3 backend
terraform init

# If prompted about migrating existing state, answer "yes"
```

## Step 4: Verify Backend Configuration

Check that the backend is properly configured:

```bash
# List remote state
terraform state list

# Show remote state details
terraform state show
```

## Backend Security Features

✅ **Encryption**: Server-side encryption enabled (AES256)
✅ **Versioning**: S3 bucket versioning enabled for rollback capability
✅ **Public Access**: All public access blocked via bucket policies
✅ **State Locking**: DynamoDB table prevents concurrent modifications
✅ **Point-in-Time Recovery**: Enabled for DynamoDB table

## Manual State Management

### View Remote State
```bash
aws s3 cp s3://8byte-tf-state-${ACCOUNT_ID}/terraform/state.tfstate .
```

### Recover from Backup
```bash
aws s3api get-object --bucket 8byte-tf-state-${ACCOUNT_ID} \
  --key terraform/state.tfstate.backup \
  state.tfstate.backup
```

### Force Unlock (Use with Caution)
```bash
terraform force-unlock <LOCK_ID>
```

## Troubleshooting

### Backend Configuration Error
**Problem**: `Error reading S3 Bucket in account`

**Solution**: 
1. Verify the S3 bucket exists in your AWS account
2. Check IAM permissions on the bucket
3. Run `terraform init -reconfigure` to update backend configuration

### DynamoDB Lock Issues
**Problem**: `Error acquiring the state lock: Conflict`

**Solution**:
1. Another Terraform operation is in progress
2. Wait for the operation to complete
3. If stuck, use `terraform force-unlock <LOCK_ID>`

### State File Migration
**Problem**: Migrating from local to remote state

**Solution**:
```bash
# Backup local state
cp terraform.tfstate terraform.tfstate.backup

# Initialize with backend
terraform init

# Confirm state migration when prompted
```

## Monitoring

Monitor S3 bucket and DynamoDB table:

```bash
# Check S3 bucket versioning
aws s3api list-object-versions \
  --bucket 8byte-tf-state-${ACCOUNT_ID}

# Check DynamoDB table metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedWriteCapacityUnits \
  --dimensions Name=TableName,Value=8byte-tf-lock \
  --statistics Sum \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600
```

## Cost Optimization

- **S3 Storage**: ~$0.023/GB/month for state file (typically < 1MB)
- **DynamoDB**: Pay-per-request billing model (minimal cost)
- **Versioning**: Automatic cleanup of old versions recommended

## Best Practices

1. **Never commit state files to version control**
2. **Use `-backend-config` for sensitive values**
3. **Enable MFA for AWS credentials**
4. **Regularly backup the state file**
5. **Monitor S3 bucket access logs**
6. **Rotate IAM credentials periodically**

## Cleanup

To remove backend infrastructure (⚠️ use with caution):

```bash
cd terraform/backend-setup

# First, migrate local state back
cd ../
terraform init -migrate-state

# Then destroy backend
cd backend-setup
terraform destroy
```

## References

- [Terraform S3 Backend Documentation](https://www.terraform.io/language/settings/backends/s3)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/BestPractices.html)
- [State Locking](https://www.terraform.io/language/state/locking)
