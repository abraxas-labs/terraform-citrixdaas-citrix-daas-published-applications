# 001: Terraform Root Module Destroy & Deploy Test Plan

**Status**: pending
**Created**: 2025-09-26
**Priority**: high

## Description

Comprehensive test plan for safely destroying and redeploying the Citrix DaaS Terraform root module. Includes validation steps, safety checks, and rollback procedures to ensure infrastructure operations are reliable and reversible.

## Pre-Requisites

### Environment Setup
- [ ] All environment variables configured (siehe README.md Quick Start)
- [ ] Azure CLI authenticated (`az account show`)
- [ ] Citrix Cloud credentials validated
- [ ] GitLab token with appropriate permissions
- [ ] Terraform >= 1.9 installed
- [ ] Current working directory: `terraform/`

### Safety Preparations
- [ ] **CRITICAL**: Create state file backup before any destroy operations
- [ ] Verify current infrastructure status with `terraform show`
- [ ] Document all existing resources for comparison
- [ ] Ensure no active user sessions in Citrix DaaS environment
- [ ] Notify stakeholders of planned maintenance window

## Test Scenarios

### Phase 1: Pre-Test Validation

#### 1.1 Environment Validation
```bash
# Verify all required environment variables
echo "MVD Mandant: $TF_VAR_mvd_mandant"
echo "Customer Code: $TF_VAR_mvd_customer_code"
echo "Environment: $TF_VAR_mvd_environment"
echo "Azure Subscription: $TF_VAR_azure_subscription_id"
echo "Citrix Customer: $TF_VAR_customer_id"

# Verify provider connectivity
az account show
terraform version
```

#### 1.2 Current State Documentation
```bash
# Document current infrastructure
terraform show > pre-test-state-$(date +%Y%m%d-%H%M%S).txt
terraform state list > pre-test-resources-$(date +%Y%m%d-%H%M%S).txt

# Backup state file
cp terraform.tfstate terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)
```

#### 1.3 Configuration Validation
```bash
# Validate configuration
terraform fmt -check -recursive
terraform validate
terraform plan -detailed-exitcode -var-file="customer.auto.tfvars"
```

**Expected Results:**
- [ ] All environment variables set and valid
- [ ] Provider authentication successful
- [ ] Configuration validation passes
- [ ] Plan shows current state (no unexpected changes)

### Phase 2: Destroy Testing

#### 2.1 Destroy Plan Generation
```bash
# Generate destroy plan
terraform plan -destroy -var-file="customer.auto.tfvars" -out=destroy.tfplan

# Review destroy plan carefully
terraform show destroy.tfplan
```

**Validation Checklist:**
- [ ] Destroy plan includes all expected resources
- [ ] No unexpected resources in destroy plan
- [ ] Resource dependencies properly ordered
- [ ] No external references that could cause failures

#### 2.2 Selective Destroy Testing (Optional)
```bash
# Test destroy of specific resource types (if needed)
terraform destroy -target=module.citrix_delivery_group_hsd_test -var-file="customer.auto.tfvars"
terraform destroy -target=module.citrix_machine_catalog_hsd_test -var-file="customer.auto.tfvars"
```

#### 2.3 Complete Infrastructure Destroy
```bash
# Apply destroy plan
terraform apply destroy.tfplan

# Verify destruction
terraform show
terraform state list
```

**Expected Results:**
- [ ] All Citrix DaaS resources destroyed successfully
- [ ] No resources remaining in Terraform state
- [ ] Azure resources (if any) properly cleaned up
- [ ] No orphaned resources in cloud providers

#### 2.4 Post-Destroy Validation
```bash
# Verify clean state
terraform state list | wc -l  # Should return 0

# Verify in Azure Portal
az resource list --resource-group "rg-mvd-m${TF_VAR_mvd_mandant}-ch-001" --query "[].name" -o table

# Verify in Citrix Cloud Console
# Manual verification of Machine Catalogs and Delivery Groups removal
```

### Phase 3: Deploy Testing

#### 3.1 Clean Deploy Preparation
```bash
# Ensure clean working directory
rm -f destroy.tfplan
rm -f .terraform.lock.hcl
rm -rf .terraform/

# Re-initialize
terraform init
```

#### 3.2 Deploy Plan Generation
```bash
# Generate fresh deployment plan
terraform plan -var-file="customer.auto.tfvars" -out=deploy.tfplan

# Review deployment plan
terraform show deploy.tfplan
```

**Validation Checklist:**
- [ ] All expected resources in deployment plan
- [ ] Resource configuration matches expectations
- [ ] No unexpected dependencies or conflicts
- [ ] Image references are valid and available

#### 3.3 Infrastructure Deployment
```bash
# Apply deployment plan
terraform apply deploy.tfplan

# Monitor deployment progress
# Note: Large deployments may take 15-30 minutes
```

**Expected Results:**
- [ ] All resources created successfully
- [ ] No timeout errors during creation
- [ ] Resource dependencies resolved correctly
- [ ] State file updated with all resources

#### 3.4 Post-Deploy Validation

##### Infrastructure Validation
```bash
# Verify all resources exist in state
terraform state list > post-deploy-resources-$(date +%Y%m%d-%H%M%S).txt

# Compare with pre-test resource list
diff pre-test-resources-*.txt post-deploy-resources-*.txt

# Run terraform plan to verify no drift
terraform plan -detailed-exitcode -var-file="customer.auto.tfvars"
```

##### Functional Validation
- [ ] **Citrix Machine Catalogs**: Verify in Citrix Cloud Console
  - [ ] Machine Catalog exists with correct name pattern
  - [ ] Correct number of VMs provisioned
  - [ ] VMs are powered on and registered
  - [ ] Image assignment is correct

- [ ] **Citrix Delivery Groups**: Verify in Citrix Cloud Console
  - [ ] Delivery Group exists with correct name pattern
  - [ ] Associated with correct Machine Catalog
  - [ ] Desktop publication configured
  - [ ] User access permissions set correctly

- [ ] **Azure Resources**: Verify in Azure Portal
  - [ ] Resource Group exists
  - [ ] Virtual Network and Subnet configured
  - [ ] Service Principal has appropriate permissions
  - [ ] Network Security Groups properly configured

##### End-to-End Testing
- [ ] **User Desktop Access**: Test desktop launch from Citrix Workspace
- [ ] **Application Delivery**: Verify published applications (if any)
- [ ] **Network Connectivity**: Test internal and external connectivity
- [ ] **Performance**: Basic performance validation

## Risk Mitigation

### Destroy Risks
- **Risk**: Accidental destruction of production resources
- **Mitigation**: Always verify `mvd_environment` variable before destroy
- **Rollback**: Restore from state backup and redeploy

### Deploy Risks
- **Risk**: Resource naming conflicts
- **Mitigation**: Verify naming conventions in locals.tf
- **Rollback**: Destroy conflicting resources and retry

### State File Risks
- **Risk**: State file corruption or loss
- **Mitigation**: Multiple backups before major operations
- **Rollback**: Restore from most recent backup

## Success Criteria

### Destroy Success
- [ ] All resources removed from Terraform state
- [ ] All resources removed from cloud providers
- [ ] No orphaned resources or dependencies
- [ ] State file backup created and verified

### Deploy Success
- [ ] All resources created successfully
- [ ] Resource configuration matches expected state
- [ ] Functional validation passes
- [ ] End-to-end testing successful
- [ ] No configuration drift detected

## Rollback Procedures

### Emergency Rollback from Failed Destroy
```bash
# Restore state file
cp terraform.tfstate.backup-[timestamp] terraform.tfstate

# Verify state restoration
terraform plan -var-file="customer.auto.tfvars"

# If needed, import missing resources
terraform import [resource_type.resource_name] [resource_id]
```

### Emergency Rollback from Failed Deploy
```bash
# Destroy partially created resources
terraform destroy -var-file="customer.auto.tfvars"

# Clean up working directory
rm -rf .terraform/
rm .terraform.lock.hcl

# Restore from backup if needed
terraform init
```

## Test Execution Log

### Test Run: [DATE]
**Tester**: [NAME]
**Environment**: [TEST/STAGING/PRODUCTION]
**Duration**: [START] - [END]

#### Phase 1 Results
- [ ] Environment validation: PASS/FAIL
- [ ] State documentation: PASS/FAIL
- [ ] Configuration validation: PASS/FAIL

#### Phase 2 Results
- [ ] Destroy plan generation: PASS/FAIL
- [ ] Infrastructure destruction: PASS/FAIL
- [ ] Post-destroy validation: PASS/FAIL

#### Phase 3 Results
- [ ] Deploy plan generation: PASS/FAIL
- [ ] Infrastructure deployment: PASS/FAIL
- [ ] Post-deploy validation: PASS/FAIL
- [ ] Functional testing: PASS/FAIL

#### Issues Encountered
- [Issue 1]: [Description] - [Resolution]
- [Issue 2]: [Description] - [Resolution]

#### Recommendations
- [Recommendation 1]
- [Recommendation 2]

---

**Next Steps**: Document test results and update procedures based on findings.
