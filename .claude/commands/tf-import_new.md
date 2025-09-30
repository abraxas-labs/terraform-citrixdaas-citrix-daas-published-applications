# /tf-import_new - Advanced Terraform Import and Configuration Generator v2.0

## COMMAND SYNTAX

**Usage**: `/tf-import_new <provider> <resource_url_or_type> <resource_name> [resource_id]`

**Arguments**:
- `$ARG1` (required): Terraform provider name (e.g., "citrix", "azurerm", "aws", "google")
- `$ARG2` (required): Resource type OR full provider documentation URL
- `$ARG3` (required): Local Terraform resource identifier
- `$ARG4` (optional): Existing resource ID (if known)

### Enhanced Parameter Handling

#### **Auto-Detection from URLs**
```bash
# URL-based resource type detection
/tf-import_new citrix https://registry.terraform.io/providers/citrix/citrix/latest/docs/resources/machine_catalog catalog_022

# Traditional type specification
/tf-import_new citrix citrix_machine_catalog catalog_022 "fc074a32-bd79-4942-9b0d-46a7c1f1cb48"
```

#### **Provider-Specific Examples**
- **Citrix**: `/tf-import_new citrix citrix_delivery_group my_dg`
- **Azure**: `/tf-import_new azurerm azurerm_resource_group main_rg "/subscriptions/.../resourceGroups/my-rg"`
- **AWS**: `/tf-import_new aws aws_instance web_server "i-1234567890abcdef0"`

---

## ENHANCED WORKFLOW IMPLEMENTATION

As an expert Terraform Engineer, execute this comprehensive import workflow with advanced error handling and recovery capabilities.

## PHASE 1: Pre-Import Analysis & Preparation

### **Step 1.1: Environment Validation**
```bash
# Validate current directory and Terraform setup
pwd  # Ensure working in terraform/ directory
terraform version  # Verify Terraform installation
terraform providers  # Check provider availability
```

### **Step 1.2: State Lock Management**
```bash
# Check for existing state locks BEFORE import attempts
terraform plan -lock=false -detailed-exitcode || echo "State lock detected"

# If state lock exists, provide guided unlock with confirmation
if [lock_detected]; then
  echo "⚠️  State Lock Detected - Providing unlock guidance"
  terraform force-unlock [LOCK_ID] # Only after user confirmation
fi
```

### **Step 1.3: Configuration Backup Strategy**
```bash
# Create comprehensive backup before import
mkdir -p .backup/$(date +%Y%m%d_%H%M%S)
cp terraform.tfstate* .backup/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
cp *.tf .backup/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
```

## PHASE 2: Enhanced Resource Discovery & Analysis

### **Step 2.1: MCP Provider Documentation Integration**
Use the Terraform MCP server for accurate provider documentation:

1. **Resolve Provider Documentation**:
   ```bash
   # Use MCP to get exact resource documentation
   resolveProviderDocID(provider_name, provider_namespace, resource_slug)
   getProviderDocs(provider_doc_id)
   ```

2. **Extract Critical Import Requirements**:
   - Resource ID format and discovery methods
   - Required vs optional attributes for import
   - Provider-specific authentication requirements
   - Dependency relationships and prerequisites

### **Step 2.2: Resource ID Discovery Automation**

#### **Citrix Cloud Resources - Automated Discovery**

**Option 1: PowerShell Script (Windows)**
```powershell
# Automated Machine Catalog ID discovery
./scripts/Get-CitrixMachineCatalogId.ps1 -CatalogName "${resource_name}" -CustomerId "${CITRIX_CUSTOMER_ID}" -SiteId "${CITRIX_SITE_ID}" -BearerToken "${CITRIX_BEARER_TOKEN}"
```

**Option 2: Bash Script (Linux/macOS)**
```bash
# Automated ID discovery via REST API
./scripts/get-citrix-catalog-id.sh "${resource_name}" "${CITRIX_CUSTOMER_ID}" "${CITRIX_SITE_ID}" "${CITRIX_BEARER_TOKEN}"
```

**Option 3: Python with Terraform Integration**
```bash
# Automated discovery with direct import.tf update
python3 scripts/citrix_catalog_discovery.py --catalog-name "${resource_name}" --customer-id "${CITRIX_CUSTOMER_ID}" --site-id "${CITRIX_SITE_ID}" --bearer-token "${CITRIX_BEARER_TOKEN}" --update-terraform
```

**Fallback: Manual Console Access**
```hcl
/*
MANUAL CITRIX RESOURCE ID DISCOVERY (if automation fails):
1. Access Citrix Cloud Console: https://citrix.cloud.com
2. Navigate: DaaS > [Resource Type] (e.g., Machine Catalogs)
3. Locate resource: ${resource_name}
4. Copy GUID from resource properties
5. Format: Standard UUID (e.g., "12345678-1234-5678-9abc-123456789012")
*/
```

#### **Azure Resource Discovery**
```bash
# Auto-generate Azure CLI commands for resource discovery
az resource list --name ${resource_name} --query "[].id" --output tsv
az resource show --ids ${resource_id} --query "id" --output tsv
```

#### **AWS Resource Discovery**
```bash
# Generate AWS CLI discovery commands
aws ec2 describe-instances --filters "Name=tag:Name,Values=${resource_name}" --query "Reservations[].Instances[].InstanceId" --output text
```

## PHASE 3: Advanced Import Block Creation

### **Step 3.1: Intelligent Import Block Generation**
Create `import.tf` with comprehensive error handling:

```hcl
# Terraform Import Configuration - Auto-generated $(date)
# Resource: ${provider}_${resource_type}.${resource_name}
# Provider: ${provider} (${provider_version})

# IMPORT BLOCK - Update resource_id with actual value
import {
  to = ${provider}_${resource_type}.${resource_name}
  id = "${resource_id_placeholder}"  # REPLACE WITH ACTUAL RESOURCE ID
}

# RESOURCE ID DISCOVERY INSTRUCTIONS:
# ${provider_specific_discovery_instructions}

# ROLLBACK COMMAND (if import fails):
# terraform state rm ${provider}_${resource_type}.${resource_name}
```

### **Step 3.2: Template Configuration Generation**
Generate defensive template configuration:

```hcl
# Template Configuration - ${resource_name}
# This serves as a fallback if auto-generation fails

resource "${provider}_${resource_type}" "${resource_name}" {
  # Core attributes (populated from provider documentation)
  ${core_attributes}

  # Security placeholders for sensitive values
  ${sensitive_attribute_placeholders}

  # Integration with existing infrastructure
  ${existing_infrastructure_references}
}
```

## PHASE 4: Enhanced Configuration Generation & Validation

### **Step 4.1: Multi-Strategy Configuration Generation**

#### **Primary Strategy: Auto-Generation**
```bash
# Attempt Terraform auto-generation with error handling
terraform plan -generate-config-out="generated_${resource_name}.tf" -var-file="customer.auto.tfvars" 2>&1 | tee import_log.txt

# Check for common errors and provide solutions
if grep -q "machine_account_creation_rules can only be updated when adding machines" import_log.txt; then
  echo "🔧 Detected immutable attribute conflict - removing template configuration"
  mv generated_${resource_name}_template.tf .backup/
fi
```

#### **Secondary Strategy: Template-Based Fallback**
```bash
# If auto-generation fails, use enhanced template approach
if [[ ! -f "generated_${resource_name}.tf" ]]; then
  echo "⚠️  Auto-generation failed - using enhanced template"
  cp generated_${resource_name}_template.tf generated_${resource_name}.tf
fi
```

### **Step 4.2: Advanced Variable Integration**

#### **Secure Variable Management Hierarchy**
```hcl
# OPTION 1: GitLab Integration (if available)
data "gitlab_project" "gitlab_project_path" {
  path_with_namespace = var.target_project_path
}

data "gitlab_project_variable" "secure_password" {
  project = data.gitlab_project.gitlab_project_path.id
  key     = "service_account_password_${var.mandant_prefix}"
}

# OPTION 2: Azure Key Vault Integration
data "azurerm_key_vault" "main" {
  name                = "kv-${var.mandant_prefix}-secrets"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "service_account_password" {
  name         = "service-account-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

# OPTION 3: Secure Placeholder (Fallback)
variable "service_account_password" {
  description = "Service account password - Use secure variable source"
  type        = string
  sensitive   = true
}
```

### **Step 4.3: Configuration Optimization & Security Review**

#### **Security Hardening**
- Mark all sensitive attributes with `sensitive = true`
- Replace hardcoded values with variable references
- Add security warnings for placeholder values
- Validate no secrets are exposed in configuration

#### **Integration Optimization**
- Reference existing data sources and modules
- Maintain naming convention consistency
- Add proper resource tagging
- Include appropriate timeouts for long-running operations

## PHASE 5: Comprehensive Testing & Validation

### **Step 5.1: Multi-Level Validation**
```bash
# Level 1: Syntax Validation
terraform fmt -check -recursive
terraform validate

# Level 2: Plan Validation
terraform plan -var-file="customer.auto.tfvars" -out=import.tfplan

# Level 3: State Consistency Check
terraform show -json import.tfplan | jq '.resource_changes[] | select(.change.actions[] == "create" or .change.actions[] == "update")'
```

### **Step 5.2: Import Execution with Safeguards**
```bash
# Execute import with comprehensive logging
terraform apply -var-file="customer.auto.tfvars" -auto-approve 2>&1 | tee apply_log.txt

# Verify successful import
if terraform state show ${provider}_${resource_type}.${resource_name} >/dev/null 2>&1; then
  echo "✅ Import successful: ${provider}_${resource_type}.${resource_name}"
else
  echo "❌ Import failed - initiating rollback procedures"
  # Execute rollback procedures
fi
```

## PHASE 6: Post-Import Documentation & Cleanup

### **Step 6.1: Comprehensive Documentation Generation**
Generate detailed import documentation:

```markdown
# Import Process Documentation - ${resource_name}

## Import Summary
- **Resource**: ${provider}_${resource_type}.${resource_name}
- **Resource ID**: ${actual_resource_id}
- **Import Date**: $(date)
- **Status**: ✅ Success

## Configuration Files Generated
- \`import.tf\` - Import block (can be removed post-import)
- \`generated_${resource_name}.tf\` - Resource configuration
- \`import_documentation.md\` - This documentation

## Security Considerations
- Sensitive attributes secured with variable references
- No hardcoded secrets in configuration
- Proper attribute sensitivity markings applied

## Integration Notes
- Integrated with existing modules: ${existing_modules}
- Variable references: ${variable_references}
- Data source dependencies: ${data_sources}

## Rollback Procedures
If rollback is needed:
\`\`\`bash
terraform state rm ${provider}_${resource_type}.${resource_name}
rm generated_${resource_name}.tf import.tf
# Restore from backup if needed
\`\`\`
```

### **Step 6.2: Final Cleanup & Optimization**
```bash
# Remove import block after successful import (optional)
# rm import.tf  # Uncomment after confirming successful import

# Format all Terraform files
terraform fmt -recursive

# Final validation
terraform validate
terraform plan -var-file="customer.auto.tfvars" | grep "No changes"
```

## ADVANCED ERROR HANDLING & RECOVERY

### **Common Error Scenarios & Solutions**

#### **State Lock Issues**
```bash
# Detection and resolution
if terraform plan 2>&1 | grep -q "state lock"; then
  echo "State lock detected - providing guided resolution"
  LOCK_ID=$(terraform plan 2>&1 | grep -oP 'ID:\s+\K[a-f0-9-]+')
  echo "Lock ID: $LOCK_ID"
  echo "Run: terraform force-unlock $LOCK_ID"
  echo "Confirm with: yes"
fi
```

#### **GitLab Integration Failures**
```bash
# Fallback to secure placeholders
if ! terraform plan -var-file="customer.auto.tfvars" 2>&1 | grep -q "gitlab_project"; then
  echo "GitLab integration unavailable - using secure placeholders"
  sed -i 's/data.gitlab_project_variable.*\.value/"REPLACE_WITH_SECURE_VALUE"/g' generated_${resource_name}.tf
fi
```

#### **Provider Authentication Issues**
```bash
# Validate provider authentication before import
terraform providers schema -json | jq -r '.provider_schemas | keys[]' | grep ${provider}
if [[ $? -ne 0 ]]; then
  echo "❌ Provider ${provider} not properly configured"
  echo "Check: terraform init && terraform providers"
fi
```

## DELIVERABLES & OUTPUTS

Upon successful completion, the following artifacts are generated:

### **Required Files**
- ✅ `import.tf` - Import block configuration
- ✅ `generated_${resource_name}.tf` - Complete resource configuration
- ✅ `import_documentation.md` - Comprehensive process documentation
- ✅ `.backup/[timestamp]/` - Complete configuration backup

### **Validation Reports**
- ✅ Terraform syntax validation results
- ✅ Security review with sensitive data handling
- ✅ Integration compatibility assessment
- ✅ Provider-specific best practices compliance

### **Operational Procedures**
- ✅ Step-by-step import execution log
- ✅ Rollback procedures and commands
- ✅ Troubleshooting guide for common issues
- ✅ Post-import optimization recommendations

## PROVIDER-SPECIFIC OPTIMIZATIONS

### **Citrix Cloud Integration**
- **Authentication**: Citrix Cloud API credentials validation
- **Site Context**: Automatic site detection and configuration
- **Resource Discovery**: Console navigation guidance with screenshots
- **Dependencies**: Hypervisor, Zone, and Folder relationship mapping

### **Azure Resource Manager**
- **Subscription Context**: Automatic subscription and tenant detection
- **Resource Groups**: Dependency analysis and reference generation
- **Managed Identity**: Integration with existing Azure AD configurations
- **Key Vault**: Automatic secret management integration

### **AWS Integration**
- **Region Context**: Automatic region detection and configuration
- **IAM Integration**: Role and policy dependency analysis
- **VPC Context**: Subnet and security group relationship mapping
- **Tags**: Consistent tagging strategy application

This enhanced version of `/tf-import_new` provides production-ready import capabilities with comprehensive error handling, security considerations, and provider-specific optimizations based on real-world implementation experience.
