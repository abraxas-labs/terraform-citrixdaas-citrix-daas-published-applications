# Citrix Provider Issue Documentation

## Problem Summary

**Issue**: Citrix Provider performs aggressive validation during `terraform plan` phase that prevents proper dependency resolution.

**Error Message**:
```
Error: Missing Attribute Configuration
│
│   with module.citrix_machine_catalog_hsd_test[0].citrix_machine_catalog.hsd,
│   on modules/citrix-machine-catalog-hsd/main.tf line 2, in resource "citrix_machine_catalog" "hsd":
│    2: resource "citrix_machine_catalog" "hsd" {
│
│ Expected domain to be configured when identity_type is Active Directory.
```

## Root Cause Analysis

### Provider Validation Logic Issue

The Citrix Provider validates `identity_type = "ActiveDirectory"` during the **plan phase** and expects:
- `machine_domain_identity.domain` to be configured
- This validation happens **before** Terraform can resolve dependencies

### Configuration Details

**Working Configuration (before issue)**:
```hcl
resource "citrix_machine_catalog" "hsd" {
  provisioning_scheme = {
    identity_type = "ActiveDirectory"
    machine_domain_identity = {
      domain             = var.domain_name              # ← Value IS available!
      service_account_id = var.service_account_id       # ← Depends on service account
    }
  }
}
```

**The domain value IS configured**: `domain_name = "m020.abxcloud.ch"` (from locals)

### Issue Details

1. **Provider validates too early**: During `terraform plan`, not `terraform apply`
2. **Misleading error message**: Claims domain is missing when it's actually configured
3. **Dependency resolution**: Provider doesn't wait for dependency resolution
4. **Workaround required**: Must use conditional logic to bypass validation

## Workaround Implementation

**Solution**: Conditional `identity_type` based on service account availability:

```hcl
provisioning_scheme = {
  identity_type = var.service_account_id != null ? "ActiveDirectory" : "None"

  machine_domain_identity = var.service_account_id != null ? {
    domain             = var.domain_name
    service_account_id = var.service_account_id
  } : null
}
```

## Expected Behavior

The provider should:
1. **Validate during apply phase**, not plan phase
2. **Respect Terraform dependencies** - wait for `service_account_id` to be available
3. **Provide accurate error messages** - the domain IS configured

## Impact

- **Breaks clean infrastructure deployment** - requires complex workarounds
- **Forces conditional logic** where none should be needed
- **Misleading error messages** confuse troubleshooting

## Environment

- **Terraform Version**: 1.5+
- **Citrix Provider Version**: Latest
- **Resource**: `citrix_machine_catalog`
- **Authentication**: Service Account based

## Suggested Fix

Modify provider validation to:
1. Skip validation during plan phase when dependencies are unresolved
2. Perform validation during apply phase when all values are available
3. Improve error message accuracy

## GitHub Issue Template

```
**Provider Version**: [version]
**Terraform Version**: [version]

**Problem**: citrix_machine_catalog validation occurs too early during plan phase

**Error**: "Expected domain to be configured when identity_type is Active Directory" even when domain is properly configured

**Expected**: Provider should wait for dependency resolution before validation

**Workaround**: Use conditional identity_type logic

**Impact**: Breaks clean single-phase infrastructure deployment
```
