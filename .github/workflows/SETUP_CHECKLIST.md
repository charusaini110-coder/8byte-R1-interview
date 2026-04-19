# Terraform Pipeline Setup Checklist

Complete this checklist to set up the Terraform provisioning pipeline.

## ✅ Pre-Requisites

- [ ] GitHub repository created
- [ ] AWS Account with admin access
- [ ] Terraform >= 1.5.0 available
- [ ] AWS CLI configured
- [ ] GitHub CLI installed (`gh`)

## ✅ Step 1: AWS Setup

### AWS Credentials
- [ ] IAM user created for CI/CD (e.g., `terraform-ci`)
- [ ] Access Key created for IAM user
- [ ] Access Key ID copied: `____________________`
- [ ] Secret Access Key copied: `____________________`
- [ ] Account ID copied: `____________________`

### AWS Permissions
- [ ] IAM policy attached (AdministratorAccess or custom)
- [ ] Verified IAM user can create EC2, RDS, ALB, VPC resources

### S3 & DynamoDB Backend
- [ ] S3 bucket created: `8byte-tf-state-ACCOUNT_ID`
- [ ] DynamoDB table created: `8byte-tf-lock`
- [ ] S3 bucket has versioning enabled
- [ ] S3 bucket has encryption enabled
- [ ] DynamoDB table has point-in-time recovery enabled

Commands to verify:
```bash
aws s3 ls | grep 8byte-tf-state
aws dynamodb list-tables | grep 8byte-tf-lock
```

## ✅ Step 2: GitHub Repository Setup

### Workflow Files
- [ ] `.github/workflows/terraform-provision.yml` exists
- [ ] `.github/workflows/deploy.yml` exists (for app)

### GitHub Secrets Configuration
- [ ] `AWS_ACCESS_KEY_ID` set
- [ ] `AWS_SECRET_ACCESS_KEY` set
- [ ] `AWS_ACCOUNT_ID` set
- [ ] `DB_USERNAME` set
- [ ] `DB_PASSWORD` set

Verify via CLI:
```bash
gh secret list
```

Expected output:
```
AWS_ACCESS_KEY_ID       ***
AWS_ACCOUNT_ID          ***
AWS_SECRET_ACCESS_KEY   ***
DB_PASSWORD             ***
DB_USERNAME             ***
```

## ✅ Step 3: Self-Hosted Runner Setup

### Runner Installation
- [ ] Runner directory created: `~/github-runner`
- [ ] Runner package downloaded
- [ ] Runner configured: `./config.sh`
- [ ] PAT (Personal Access Token) generated
- [ ] Runner registered with GitHub

### Runner Verification
- [ ] Runner appears in GitHub UI (Settings → Actions → Runners)
- [ ] Runner status shows "Idle"
- [ ] Runner labels configured: `[self-hosted, terraform]`

Commands on runner machine:
```bash
cd ~/github-runner
./run.sh
# Should show: "Listening for Jobs"
```

### Runner Labels
- [ ] `self-hosted` label present
- [ ] `terraform` label added (optional but recommended)
- [ ] Custom labels added if needed

## ✅ Step 4: Local Terraform Configuration

### Terraform Backend
- [ ] `terraform/providers.tf` has S3 backend configured
- [ ] Bucket name updated with AWS Account ID
- [ ] `terraform/terraform.tfvars` configured
- [ ] `terraform/variables.tf` defined

### Terraform Validation
```bash
cd terraform/
terraform validate
terraform fmt -check
```

- [ ] Terraform validation passed
- [ ] Terraform formatting correct
- [ ] No syntax errors

## ✅ Step 5: Workflow Testing

### Manual Workflow Dispatch
1. [ ] Go to GitHub Actions tab
2. [ ] Select "Terraform Provision Infrastructure"
3. [ ] Click "Run workflow"
4. [ ] Select action: `plan`
5. [ ] Click "Run workflow"

### Monitor Workflow
- [ ] Workflow job started
- [ ] Runner picked up the job
- [ ] `terraform-validate` job completed successfully
- [ ] Plan artifact uploaded

### Check Logs
- [ ] View job logs for any errors
- [ ] Verify AWS credentials worked
- [ ] Verify Terraform initialized with S3 backend

## ✅ Step 6: Deploy Infrastructure (Optional)

Once plan succeeds:

### Apply Infrastructure
1. [ ] Run workflow again with action: `apply`
2. [ ] Monitor the `terraform-apply` job
3. [ ] Verify resources created in AWS Console:
   - [ ] VPC created
   - [ ] Security groups created
   - [ ] ALB created
   - [ ] EC2 instance created
   - [ ] RDS instance created

### Verify Outputs
- [ ] Check GitHub actions output for Terraform outputs
- [ ] Verify ALB DNS name
- [ ] Verify EC2 public IP
- [ ] Verify RDS endpoint

## ✅ Step 7: Documentation & Monitoring

### Documentation
- [ ] Read `.github/workflows/TERRAFORM_PIPELINE.md`
- [ ] Read `.github/workflows/SECRETS_SETUP.md`
- [ ] Read `terraform/PROVIDER_SETUP.md`
- [ ] Read `terraform/BACKEND_SETUP.md`

### Monitoring Setup
- [ ] Configured CloudWatch alarms (optional)
- [ ] Set up SNS notifications (optional)
- [ ] Documented runbook for troubleshooting

## ✅ Step 8: Security Best Practices

### Credential Security
- [ ] Credentials stored in GitHub Secrets (not in code)
- [ ] IAM policy follows least privilege principle
- [ ] Access keys have expiration policy
- [ ] MFA enabled on AWS account

### State Management
- [ ] S3 encryption enabled
- [ ] DynamoDB locking enabled
- [ ] State file not committed to version control
- [ ] `.gitignore` includes `terraform.tfstate*`

### Audit & Compliance
- [ ] GitHub Actions logs reviewed
- [ ] AWS CloudTrail logs enabled
- [ ] Resource tagging implemented
- [ ] Cost monitoring set up

## 🎯 Verification Checklist

Test the complete flow:

```bash
# 1. Verify runner is ready
cd ~/github-runner
./run.sh
# Should see: "Listening for Jobs"

# 2. Trigger workflow
gh workflow run terraform-provision.yml -f action=plan

# 3. Monitor progress
gh run watch

# 4. Verify infrastructure created
aws ec2 describe-instances
aws rds describe-db-instances
aws elbv2 describe-load-balancers
```

All items checked? ✅ **Setup Complete!**

## Troubleshooting Quick Links

- **Runner issues**: See `TERRAFORM_PIPELINE.md` → Troubleshooting
- **Secret issues**: See `SECRETS_SETUP.md` → Troubleshooting
- **Terraform errors**: See `terraform/PROVIDER_SETUP.md`
- **Backend issues**: See `terraform/BACKEND_SETUP.md`

## Support Commands

```bash
# Check runner status
gh runner list

# View workflow runs
gh run list --workflow=terraform-provision.yml

# View latest run
gh run view --web

# Check secrets
gh secret list

# View job logs
gh run view <RUN_ID> --log

# Troubleshoot on runner machine
cd ~/github-runner
tail -f _diag/Worker_* 2>/dev/null | head -100
```

## Next Steps

After successful setup:

1. **Schedule runs** - Add cron trigger to workflow
2. **Add approval** - Implement manual approval for apply/destroy
3. **Add monitoring** - CloudWatch dashboards for resources
4. **Document runbooks** - Procedures for common operations
5. **Plan testing** - Regular dry-runs and disaster recovery tests
