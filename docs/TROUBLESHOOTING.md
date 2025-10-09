# Troubleshooting Guide

This guide helps you resolve common issues when using the Citrix Published Applications Terraform module.

## Table of Contents

- [Common Errors](#common-errors)
- [Terraform Errors](#terraform-errors)
- [Citrix-Specific Errors](#citrix-specific-errors)
- [FAQ](#faq)
- [Getting Help](#getting-help)

---

## Common Errors

### Error: Delivery Group Not Found

**Error Message**:
```
Error: Delivery Group "Production-DG" not found
```

**Causes**:
1. Delivery Group doesn't exist in Citrix Cloud
2. Delivery Group name is misspelled
3. API credentials don't have access to the Delivery Group

**Solutions**:

1. **Verify Delivery Group exists**:
   - Log into Citrix Cloud → Studio
   - Navigate to Delivery Groups
   - Confirm the exact name (case-sensitive)

2. **Check name spelling**:
   ```hcl
   # Ensure exact match (case-sensitive)
   citrix_deliverygroup_name = "Production-DG"  # ✅ Correct
   citrix_deliverygroup_name = "production-dg"  # ❌ Wrong case
   citrix_deliverygroup_name = "ProductionDG"   # ❌ Missing hyphen
   ```

3. **Test with Terraform data source**:
   ```hcl
   data "citrix_delivery_group" "test" {
     name = "Production-DG"
   }

   output "dg_id" {
     value = data.citrix_delivery_group.test.id
   }
   ```
   Run `terraform plan` to verify access.

---

### Error: Invalid API Credentials

**Error Message**:
```
Error: Invalid API credentials
Error: Authentication failed
Error: 401 Unauthorized
```

**Causes**:
1. Customer ID, Client ID, or Client Secret is incorrect
2. API credentials have expired
3. Credentials are not set as environment variables

**Solutions**:

1. **Verify credentials are set**:
   ```bash
   # Linux/WSL
   echo $TF_VAR_customer_id
   echo $TF_VAR_client_id
   echo $TF_VAR_client_secret

   # PowerShell
   echo $env:TF_VAR_customer_id
   echo $env:TF_VAR_client_id
   echo $env:TF_VAR_client_secret
   ```

2. **Re-create API credentials**:
   - Log into Citrix Cloud
   - Go to Identity and Access Management → API Access
   - Delete old credentials
   - Create new Secure Client
   - Update environment variables with new values

3. **Test credentials manually**:
   ```bash
   # Use curl to test (Linux/WSL)
   curl -X POST "https://api.cloud.com/cws/auth/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=client_credentials&client_id=$TF_VAR_client_id&client_secret=$TF_VAR_client_secret"
   ```

---

### Error: Application Folder Path Not Found

**Error Message**:
```
Error: Application folder path "Production" not found
Error: Admin folder does not exist
```

**Causes**:
1. Folder doesn't exist in Citrix Cloud
2. Folder path format is incorrect (leading/trailing slashes)
3. Nested folder path doesn't match structure

**Solutions**:

1. **Create folder in Citrix Studio**:
   - Log into Citrix Cloud → Studio
   - Navigate to Applications
   - Right-click → Create Folder → Name it "Production"

2. **Check folder path format**:
   ```hcl
   # ✅ Correct formats
   citrix_application_folder_path = "Production"
   citrix_application_folder_path = "Production/Microsoft Office"

   # ❌ Incorrect formats
   citrix_application_folder_path = "/Production"        # No leading slash
   citrix_application_folder_path = "Production/"        # No trailing slash
   citrix_application_folder_path = "/Production/"       # No slashes
   ```

3. **Create folder with Terraform** (before creating applications):
   ```hcl
   resource "citrix_admin_folder" "production" {
     name = "Production"
     type = ["ContainsApplications"]
   }

   module "app" {
     source = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
     # ...
     citrix_application_folder_path = citrix_admin_folder.production.path
     # This ensures folder exists before app creation
   }
   ```

---

### Error: Invalid Executable Path

**Error Message**:
```
Error: citrix_application_command_line_executable: invalid value
Error: Invalid Windows path format
```

**Causes**:
1. Single backslash instead of double backslash
2. Path doesn't exist on VDA
3. Incorrect quoting

**Solutions**:

1. **Use double backslashes**:
   ```hcl
   # ✅ Correct
   citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"

   # ❌ Incorrect
   citrix_application_command_line_executable = "C:\Windows\system32\calc.exe"
   ```

2. **Verify path exists on VDA**:
   - RDP into one of your VDA machines
   - Navigate to the executable path
   - Confirm exact path and spelling

3. **Common executable paths**:
   ```hcl
   # Windows built-in apps
   calc.exe      = "C:\\Windows\\system32\\calc.exe"
   notepad.exe   = "C:\\Windows\\system32\\notepad.exe"
   cmd.exe       = "C:\\Windows\\System32\\cmd.exe"

   # Microsoft Office (64-bit)
   word          = "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
   excel         = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
   powerpoint    = "C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE"

   # Microsoft Office (32-bit on 64-bit Windows)
   word          = "C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
   ```

---

### Error: User/Group Not Found (Visibility)

**Error Message**:
```
Error: User or group "CONTOSO\Finance-Users" not found
Error: Invalid visibility setting
```

**Causes**:
1. User/group doesn't exist in Active Directory
2. Domain name is incorrect
3. Incorrect backslash format (single vs. double)
4. User/group not synced to Citrix Cloud

**Solutions**:

1. **Verify AD user/group exists**:
   - Open Active Directory Users and Computers
   - Search for the user or group
   - Confirm exact name and domain

2. **Use double backslashes in Terraform**:
   ```hcl
   # ✅ Correct
   citrix_application_visibility = ["CONTOSO\\Finance-Users"]

   # ❌ Incorrect
   citrix_application_visibility = ["CONTOSO\Finance-Users"]
   ```

3. **Check domain name**:
   ```hcl
   # Use NetBIOS domain name (short form), not FQDN
   citrix_application_visibility = ["CONTOSO\\Users"]        # ✅ Correct
   citrix_application_visibility = ["contoso.com\\Users"]    # ❌ Wrong
   ```

4. **Ensure AD sync to Citrix Cloud**:
   - Citrix Cloud → Identity and Access Management
   - Verify Azure AD/AD sync is active
   - Wait for sync cycle to complete (15-30 minutes)

---

## Terraform Errors

### Error: Module Not Found

**Error Message**:
```
Error: Module not found
Error: Failed to download module
```

**Solution**:
```bash
# Re-initialize Terraform
terraform init -upgrade

# If behind a proxy, configure:
export HTTPS_PROXY=http://proxy.company.com:8080
terraform init
```

---

### Error: State Lock

**Error Message**:
```
Error: Error locking state
Error: state is already locked
```

**Causes**:
- Previous `terraform apply` was interrupted
- Multiple users running Terraform simultaneously

**Solutions**:

1. **Wait and retry** (if someone else is running Terraform)

2. **Force unlock** (only if you're sure no one else is running Terraform):
   ```bash
   terraform force-unlock <LOCK_ID>
   # Get LOCK_ID from error message
   ```

---

### Error: Variable Not Set

**Error Message**:
```
Error: No value for required variable
Error: var.citrix_customer_id is required
```

**Causes**:
- Environment variables not set
- Terraform restarted without re-setting variables

**Solutions**:

1. **Check environment variables**:
   ```bash
   # Linux/WSL
   env | grep TF_VAR

   # PowerShell
   Get-ChildItem Env:TF_VAR_*
   ```

2. **Re-set environment variables**:
   ```bash
   # Linux/WSL
   export TF_VAR_client_id="your-client-id"
   export TF_VAR_client_secret="your-client-secret"
   export TF_VAR_customer_id="your-customer-id"

   # PowerShell
   $env:TF_VAR_client_id="your-client-id"
   $env:TF_VAR_client_secret="your-client-secret"
   $env:TF_VAR_customer_id="your-customer-id"
   ```

---

## Citrix-Specific Errors

### Application Already Exists

**Error Message**:
```
Error: Application with name "calculator-app" already exists
Error: Duplicate application name
```

**Causes**:
- Application with the same `citrix_application_name` already exists
- Previous Terraform run created the app, but state was lost

**Solutions**:

1. **Import existing application**:
   ```bash
   terraform import module.calculator.citrix_application.published_application <application-id>
   ```
   Get `<application-id>` from Citrix Studio or Citrix Cloud API.

2. **Rename application**:
   ```hcl
   citrix_application_name = "calculator-app-v2"
   ```

3. **Delete old application manually** (if safe to do so):
   - Citrix Cloud → Studio → Applications
   - Delete the duplicate application
   - Re-run `terraform apply`

---

### VDA Not Available

**Error Message**:
```
Error: No VDAs available in Delivery Group
Error: Delivery Group has no active machines
```

**Causes**:
- No VDAs are registered with the Delivery Group
- All VDAs are in maintenance mode or powered off

**Solutions**:

1. **Check VDA status**:
   - Citrix Cloud → Studio → Machine Catalogs
   - Verify VDAs are powered on and registered

2. **Verify Delivery Group assignment**:
   - Citrix Cloud → Studio → Delivery Groups
   - Confirm machines are assigned

3. **Check VDA registration**:
   - RDP into VDA
   - Open Services → Citrix Desktop Service → Verify "Running"
   - Check Event Viewer for Citrix-related errors

---

## FAQ

### Q: How do I find the Application ID for import?

**A**: Use Citrix Cloud API or PowerShell:

```powershell
# PowerShell with Citrix SDK
Add-PSSnapin Citrix.*
Get-BrokerApplication -Name "calculator-app" | Select-Object Name, Uid
```

Or use the Citrix Cloud UI:
- Citrix Cloud → Studio → Applications
- Right-click application → Properties → Note the UID

---

### Q: Can I create the same application in multiple Delivery Groups?

**A**: Yes, but each must have a unique `citrix_application_name`:

```hcl
module "calc_dg1" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name       = "calculator-dg1"  # Unique name
  citrix_application_published_name = "Calculator"
  citrix_deliverygroup_name     = "DG-1"
  # ...
}

module "calc_dg2" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name       = "calculator-dg2"  # Different unique name
  citrix_application_published_name = "Calculator"  # Same published name OK
  citrix_deliverygroup_name     = "DG-2"
  # ...
}
```

---

### Q: What happens if I change `citrix_application_name`?

**A**: Terraform will **destroy the old application** and **create a new one**. To rename:

1. Use `terraform state mv` to rename in state:
   ```bash
   terraform state mv \
     module.old_name.citrix_application.published_application \
     module.new_name.citrix_application.published_application
   ```

2. Or use `terraform import` after manual rename in Citrix Studio.

---

### Q: How do I debug Citrix provider issues?

**A**: Enable Terraform debug logging:

```bash
# Linux/WSL
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log
terraform apply

# PowerShell
$env:TF_LOG="DEBUG"
$env:TF_LOG_PATH=".\terraform-debug.log"
terraform apply
```

Check `terraform-debug.log` for detailed API calls and responses.

---

### Q: Can I use environment variables for other inputs (not just API credentials)?

**A**: Yes! Any variable can use `TF_VAR_` prefix:

```bash
# Set via environment
export TF_VAR_delivery_group_name="Production-DG"
export TF_VAR_app_folder="Production"

# Use in Terraform
variable "delivery_group_name" {
  type = string
}

module "app" {
  # ...
  citrix_deliverygroup_name = var.delivery_group_name
}
```

---

### Q: How do I handle Terraform state for multiple users?

**A**: Use remote state backend (e.g., Azure Storage, AWS S3):

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "terraformstate"
    container_name       = "citrix-apps"
    key                  = "citrix-published-apps.tfstate"
  }
}
```

Initialize:
```bash
terraform init -backend-config="access_key=<storage-key>"
```

---

### Q: What if `terraform destroy` fails to delete an application?

**A**:

1. **Check Citrix Cloud** — Application may be manually deleted
2. **Remove from state**:
   ```bash
   terraform state rm module.app_name.citrix_application.published_application
   ```
3. **Re-run destroy**:
   ```bash
   terraform destroy
   ```

---

## Validation Workflow

To avoid errors, always follow this sequence:

```bash
# 1. Format code
terraform fmt -recursive

# 2. Validate syntax
terraform validate

# 3. Preview changes (no modifications)
terraform plan

# 4. Apply only after reviewing plan
terraform apply

# 5. Verify in Citrix Cloud
# Log into Citrix Cloud → Studio → Applications
```

---

## Getting Help

### Debug Checklist

Before asking for help, provide:

1. **Terraform version**:
   ```bash
   terraform version
   ```

2. **Citrix provider version**:
   ```bash
   terraform version | grep citrix
   ```

3. **Error message** (full output)

4. **Terraform configuration** (sanitized, without credentials)

5. **Debug log** (if applicable):
   ```bash
   TF_LOG=DEBUG terraform apply 2>&1 | tee debug.log
   ```

---

### Support Channels

- **GitHub Issues**: [Report bugs or request features](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/discussions)
- **Citrix Provider Docs**: [Official documentation](https://registry.terraform.io/providers/citrix/citrix/latest/docs)
- **Citrix Developer Portal**: [API documentation](https://developer-docs.citrix.com/)

---

## Additional Resources

- [Main README](../README.md)
- [Getting Started Guide](GETTING_STARTED_FOR_CITRIX_ADMINS.md)
- [Advanced Examples](EXAMPLES.md)
- [Terraform Debugging Guide](https://www.terraform.io/docs/internals/debugging.html)
