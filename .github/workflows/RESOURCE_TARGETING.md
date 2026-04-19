# Resource Targeting Guide

This guide explains how to use the resource targeting feature in the Terraform provisioning pipeline.

## Overview

The workflow now supports selective deployment of resources/modules, allowing you to:
- Deploy individual modules without affecting others
- Update specific components (e.g., only EC2 instances)
- Perform targeted destruction
- Reduce deployment time for specific resource updates

## Available Resource Targets

| Target | Description | Modules Deployed |
|--------|-------------|------------------|
| `all` | All infrastructure (default) | VPC, Security Groups, ALB, EC2, RDS |
| `vpc` | VPC infrastructure only | VPC Module |
| `security_groups` | Security groups only | Security Groups Module |
| `alb` | Application Load Balancer | ALB Module |
| `ec2` | EC2 instances | EC2 Module |
| `rds` | RDS databases | RDS Module |

## How to Use Resource Targeting

### Via GitHub UI

1. Go to **Actions** tab
2. Select **Terraform Provision Infrastructure**
3. Click **Run workflow**
4. Fill in the inputs:
   - **Action**: Choose `plan`, `apply`, or `destroy`
   - **Resource Target**: Choose the resource to deploy (default: `all`)
5. Click **Run workflow**

### Via GitHub CLI

```bash
# Plan only VPC changes
gh workflow run terraform-provision.yml \
  -f action=plan \
  -f resource_target=vpc

# Apply only EC2 changes
gh workflow run terraform-provision.yml \
  -f action=apply \
  -f resource_target=ec2

# Destroy only RDS
gh workflow run terraform-provision.yml \
  -f action=destroy \
  -f resource_target=rds
```

## Common Use Cases

### Scenario 1: Initial Infrastructure Deployment

**Goal**: Deploy entire infrastructure from scratch

```bash
# Plan all resources
gh workflow run terraform-provision.yml \
  -f action=plan \
  -f resource_target=all

# Apply all resources
gh workflow run terraform-provision.yml \
  -f action=apply \
  -f resource_target=all
```

### Scenario 2: Scale EC2 Instances

**Goal**: Update EC2 configuration (increase instance count or change instance type)

1. Modify `terraform/terraform.tfvars`:
   ```hcl
   ec2_instances = {
     app_server_1 = { enabled = true, ... }
     app_server_2 = { enabled = true, ... }  # New instance
   }
   ```

2. Deploy only EC2 changes:
   ```bash
   gh workflow run terraform-provision.yml \
     -f action=apply \
     -f resource_target=ec2
   ```

### Scenario 3: Update Security Groups Rules

**Goal**: Modify security group rules without recreating other resources

```bash
# 1. Modify security group rules in terraform/modules/security_groups/main.tf
# 2. Plan security group changes
gh workflow run terraform-provision.yml \
  -f action=plan \
  -f resource_target=security_groups

# 3. Apply changes
gh workflow run terraform-provision.yml \
  -f action=apply \
  -f resource_target=security_groups
```

### Scenario 4: Deploy Additional Database

**Goal**: Add a new RDS instance without affecting existing resources

1. Update `terraform/terraform.tfvars`:
   ```hcl
   rds_databases = {
     postgres_primary = { enabled = true, ... }
     postgres_secondary = { enabled = true, ... }  # New database
   }
   ```

2. Deploy only RDS changes:
   ```bash
   gh workflow run terraform-provision.yml \
     -f action=plan \
     -f resource_target=rds

   gh workflow run terraform-provision.yml \
     -f action=apply \
     -f resource_target=rds
   ```

### Scenario 5: Destroy Only Development Environment

**Goal**: Remove EC2 and RDS but keep VPC and security infrastructure

⚠️ **Note**: This requires running separate destroy commands:

```bash
# Destroy EC2
gh workflow run terraform-provision.yml \
  -f action=destroy \
  -f resource_target=ec2

# Destroy RDS
gh workflow run terraform-provision.yml \
  -f action=destroy \
  -f resource_target=rds
```

## How Resource Targeting Works

The workflow uses Terraform's `-target` flag internally:

```bash
# Planning VPC only
terraform plan -target=module.vpc -out=tfplan

# Applying EC2 only
terraform apply -target=module.ec2 tfplan

# Destroying RDS only
terraform destroy -target=module.rds -auto-approve
```

## Important Considerations

### 1. Resource Dependencies

When targeting specific modules, Terraform still respects dependencies:

- **Applying EC2** requires VPC and Security Groups to exist
- **Applying ALB** requires VPC and Security Groups to exist
- **Applying RDS** requires VPC and Security Groups to exist

**Example**: If VPC doesn't exist yet, you cannot deploy EC2 directly.

### 2. State Management

- Terraform targets only affect which resources are planned/applied
- State file contains all resources
- You can always view all resources: `terraform state list`

### 3. Best Practices

✅ **DO:**
- Always run `plan` before `apply` to review changes
- Target related modules together (e.g., update security groups before EC2)
- Document what you're changing and why
- Maintain a consistent naming convention for resources

❌ **DON'T:**
- Mix targeting with `terraform apply` on remote state without planning
- Target destruction of dependency resources first (e.g., don't destroy VPC before EC2)
- Use targeting for regular deployments if you want full infrastructure management

## Workflow Output & Summary

When you run a targeted deployment, the workflow provides:

### Plan Summary
```
📦 Deployment Scope
Action: plan
Target Resource: EC2 Instances Module
Terraform Version: 1.5.0
AWS Region: ap-south-1
```

### Apply Summary
```
✅ Terraform Apply Completed
Target Resource: EC2 Instances Module
Outputs:
{
  "ec2_instance_ids": {...},
  "ec2_public_ips": {...}
}
```

### Destroy Summary
```
⚠️ Terraform Destroy Completed
Target Resource: RDS Database Module
Status: Resources have been destroyed
```

## Monitoring & Debugging

### View Workflow Logs

```bash
# List recent workflow runs
gh run list --workflow=terraform-provision.yml

# View specific run
gh run view <RUN_ID>

# View job logs
gh run view <RUN_ID> --log

# Watch in real-time
gh run watch <RUN_ID>
```

### Check Terraform State

```bash
# List all resources in state
terraform state list

# List specific module resources
terraform state list | grep module.ec2

# Show specific resource details
terraform state show module.ec2["app_server_1"].aws_instance.app_server
```

## Troubleshooting

### Issue: "Error acquiring the state lock"

**Cause**: Another terraform operation is in progress

**Solution**:
```bash
# Wait for previous operation to complete
# Or force unlock if stuck:
terraform force-unlock <LOCK_ID>
```

### Issue: "Module not found" error

**Cause**: Trying to target a module that doesn't have resources enabled

**Solution**: 
- Check `terraform.tfvars` - ensure resources are enabled
- Verify module syntax: `-target=module.vpc` not `-target=vpc`

### Issue: Dependency error when targeting

**Cause**: Targeting a resource whose dependencies don't exist

**Solution**:
- Deploy dependencies first (use `all` to deploy everything)
- Or target multiple related modules together

## Advanced: Custom Targeting

For more complex scenarios, you can modify the workflow to add custom target combinations.

**Example**: Create a "prod-web-stack" that deploys VPC + ALB + EC2:

1. Edit `terraform-provision.yml`
2. Add custom target in inputs:
   ```yaml
   - prod-web-stack
   ```
3. Add case in `set-targets` step:
   ```bash
   elif [ "$RESOURCE_TARGET" = "prod-web-stack" ]; then
     TARGETS="-target=module.vpc -target=module.alb -target=module.ec2"
   ```

## Resource Targeting Cheat Sheet

```bash
# Plan everything
gh workflow run terraform-provision.yml -f action=plan -f resource_target=all

# Plan VPC only
gh workflow run terraform-provision.yml -f action=plan -f resource_target=vpc

# Apply EC2 changes
gh workflow run terraform-provision.yml -f action=apply -f resource_target=ec2

# Plan security groups changes
gh workflow run terraform-provision.yml -f action=plan -f resource_target=security_groups

# Destroy RDS only
gh workflow run terraform-provision.yml -f action=destroy -f resource_target=rds
```

## See Also

- [Terraform `-target` Documentation](https://www.terraform.io/cli/commands/plan#resource-targeting)
- [Main Pipeline Documentation](TERRAFORM_PIPELINE.md)
- [Setup Checklist](SETUP_CHECKLIST.md)
