# GitHub Actions - Terraform Provisioning Pipeline

This guide explains how to set up and use the Terraform provisioning pipeline with self-hosted runners.

## Overview

The workflow file `.github/workflows/terraform-provision.yml` provides:
- **Manual trigger** via GitHub Actions UI (`workflow_dispatch`)
- **Self-hosted runner** support for security and control
- **Three actions**: Plan, Apply, Destroy
- **Terraform validation** and formatting checks
- **AWS authentication** via IAM credentials
- **State locking** via DynamoDB

## Prerequisites

1. GitHub repository with Actions enabled
2. AWS Account with appropriate permissions
3. Self-hosted runner configured
4. GitHub Secrets configured

## Step 1: Set Up Self-Hosted Runner

### 1.1 On Your Local Machine (macOS Example)

```bash
# Create a directory for the runner
mkdir -p ~/github-runner
cd ~/github-runner

# Download the latest runner package
curl -o actions-runner-osx-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz

# Extract the installer
tar xzf actions-runner-osx-x64.tar.gz

# Create the runner and start the configuration experience
./config.sh --url https://github.com/<YOUR_USERNAME>/<YOUR_REPO> \
  --token <PERSONAL_ACCESS_TOKEN>

# Last step, run it!
./run.sh
```

### 1.2 On AWS EC2 Instance (Linux)

```bash
# Install required packages
sudo apt-get update
sudo apt-get install -y \
  curl \
  jq \
  awscli \
  build-essential \
  libssl-dev \
  libffi-dev \
  python3-dev

# Download runner (Ubuntu 22.04)
mkdir -p ~/github-runner && cd ~/github-runner

curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

tar xzf actions-runner-linux-x64.tar.gz

# Configure runner
./config.sh --url https://github.com/<YOUR_USERNAME>/<YOUR_REPO> \
  --token <PERSONAL_ACCESS_TOKEN> \
  --labels terraform,linux \
  --runnergroup default

# Install as a service (optional but recommended)
sudo ./svc.sh install
sudo ./svc.sh start
```

### 1.3 Generate Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes:
   - `repo` (full control)
   - `workflow` (manage workflows)
   - `admin:org_hook` (if using organization)
4. Copy the token for use in config.sh

## Step 2: Configure GitHub Secrets

Navigate to **Repository Settings → Secrets and variables → Actions**

### Required Secrets:

#### AWS Credentials
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_ACCOUNT_ID (e.g., 123456789012)
```

#### Database Credentials
```
DB_USERNAME        (PostgreSQL admin username)
DB_PASSWORD        (PostgreSQL admin password)
```

### Example Setup via CLI:

```bash
# Set AWS credentials
gh secret set AWS_ACCESS_KEY_ID --body "your-access-key"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-secret-key"
gh secret set AWS_ACCOUNT_ID --body "123456789012"

# Set database credentials
gh secret set DB_USERNAME --body "admin"
gh secret set DB_PASSWORD --body "secure-password-here"
```

### ⚠️ Security Best Practices:

- **Rotate credentials** regularly
- **Use IAM roles** instead of access keys when possible
- **Restrict IAM permissions** to minimum required
- **Enable MFA** on AWS account
- **Audit secret access** via GitHub logs

## Step 3: Verify Setup

### 3.1 Check Runner Status

```bash
# In GitHub repository, go to Settings → Actions → Runners
# You should see your self-hosted runner with status "Idle"
```

### 3.2 Test Runner Connection

```bash
# In your runner terminal, you should see:
# "Listening for Jobs"
```

### 3.3 Verify Terraform Installation

```bash
# On self-hosted runner machine
terraform --version
aws --version
```

## Step 4: Run the Workflow

### Via GitHub UI:

1. Go to **Actions** tab
2. Select **Terraform Provision Infrastructure**
3. Click **Run workflow**
4. Select action from dropdown:
   - `plan` - Review changes (default)
   - `apply` - Deploy infrastructure
   - `destroy` - Remove infrastructure
5. Click **Run workflow**

### Via GitHub CLI:

```bash
# Plan infrastructure
gh workflow run terraform-provision.yml \
  -f action=plan

# Apply infrastructure
gh workflow run terraform-provision.yml \
  -f action=apply

# Destroy infrastructure
gh workflow run terraform-provision.yml \
  -f action=destroy
```

## Workflow Details

### Jobs Overview:

#### 1. `terraform-validate` (Always runs)
- Checks Terraform formatting
- Initializes Terraform with backend config
- Validates Terraform configuration
- Generates and uploads plan artifact

#### 2. `terraform-apply` (If action == 'apply')
- Downloads plan artifact
- Applies Terraform changes
- Captures outputs
- Posts results to GitHub

#### 3. `terraform-destroy` (If action == 'destroy')
- Destroys all infrastructure
- Posts confirmation comment

### Runner Tags:

The workflow runs on self-hosted runners with labels: `[self-hosted, terraform]`

To use different runners, modify the workflow:
```yaml
runs-on: [self-hosted, <your-label>]
```

## Monitoring Workflow Execution

### View Logs:

1. Go to **Actions** tab
2. Click the workflow run
3. Click the job to see detailed logs

### View Infrastructure Outputs:

After `terraform apply`, outputs are posted as:
- GitHub PR comment
- Workflow artifact (`outputs.json`)

## Troubleshooting

### Issue: Runner offline

**Solution:**
```bash
# On runner machine
cd ~/github-runner
./run.sh  # Restart runner
```

### Issue: AWS credentials invalid

**Solution:**
```bash
# Verify credentials
aws sts get-caller-identity

# Update GitHub secrets if needed
gh secret set AWS_ACCESS_KEY_ID --body "new-key"
```

### Issue: Terraform state lock timeout

**Solution:**
```bash
# Force unlock (⚠️ use with caution)
terraform force-unlock <LOCK_ID>

# Or check DynamoDB table
aws dynamodb scan --table-name 8byte-tf-lock
```

### Issue: Backend bucket not found

**Solution:**
```bash
# Verify bucket exists
aws s3 ls | grep 8byte-tf-state

# If missing, create backend infrastructure first
# See: terraform/BACKEND_SETUP.md
```

## Advanced Configuration

### Using IAM Role Instead of Keys (Recommended)

```bash
# On EC2 instance with IAM role, remove access key secrets
# Let AWS use the instance role credentials instead

# Modify workflow:
# Remove AWS key/secret configuration
# Add role ARN configuration if needed
```

### Custom Runner Labels

```bash
# During runner setup
./config.sh --labels terraform,prod,ec2

# In workflow file
runs-on: [self-hosted, terraform, prod]
```

### Scheduled Terraform Runs

Add to workflow file:
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:
```

## Cleanup

### Remove Runner:

```bash
cd ~/github-runner
./config.sh remove --token <PERSONAL_ACCESS_TOKEN>
```

### Revoke GitHub Secrets:

```bash
# In GitHub UI: Settings → Secrets → Delete
# Or via CLI:
gh secret delete AWS_ACCESS_KEY_ID
gh secret delete AWS_SECRET_ACCESS_KEY
```

## References

- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [AWS Configure Credentials Action](https://github.com/aws-actions/configure-aws-credentials)

## Support

For issues or questions:

1. Check workflow logs in GitHub Actions
2. Review Terraform state: `terraform state list`
3. Check AWS CloudTrail for API calls
4. Review runner logs on machine: `~/github-runner/_diag/`
