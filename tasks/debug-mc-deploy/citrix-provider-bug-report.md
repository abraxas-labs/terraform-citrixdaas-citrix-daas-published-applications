# [Bug] citrix_machine_catalog validation occurs too early during plan phase, preventing dependency resolution

<!-- Thanks for taking the time to fill out this bug report! Before submitting this issue please check the [open bugs](https://github.com/citrix/terraform-provider-citrix/issues?q=is%3Aissue+is%3Aopen+label%3Abug) to ensure the bug has not already been reported. If it has been reported give it a 👍 -->

## Describe the bug

The Citrix Terraform provider performs validation during the `terraform plan` phase that prevents proper dependency resolution for `citrix_machine_catalog` resources. When `identity_type = "ActiveDirectory"` is configured, the provider validates that domain configuration is present before Terraform can resolve dependencies, resulting in a misleading error message claiming the domain is missing when it is actually properly configured.

**Terraform command (import, apply, etc):** `terraform plan`
**Resource impacted:** `citrix_machine_catalog`
**Issue reproducible outside of Terraform:** No - This is specifically a provider validation timing issue

## Versions

**Terraform:** 1.5.7
**citrix/citrix provider:** 0.5.10
**Operation system:** Linux Ubuntu 22.04

**Environment type:** Cloud
**Hypervisor type (if applicable):** Azure

**CVAD (DDC, VDA, etc):** Citrix DaaS (Cloud)
**Storefront:** N/A (Cloud)

## Terraform configuration files

```hcl
# main.tf
resource "citrix_service_account" "example_service_account" {
  display_name                 = "example-service-account"
  account_id                   = "EXAMPLE\\serviceaccount"
  account_secret               = var.service_account_password
  account_secret_format        = "PlainText"
  identity_provider_type       = "ActiveDirectory"
  identity_provider_identifier = "example.domain.com"
}

# machine-catalog.tf
module "example_machine_catalog" {
  source = "./modules/citrix-machine-catalog"

  machine_catalog_name = "EXAMPLE-HSD-CATALOG"
  domain_name         = "example.domain.com"
  service_account_id  = citrix_service_account.example_service_account.id

  depends_on = [citrix_service_account.example_service_account]
}

# modules/citrix-machine-catalog/main.tf
resource "citrix_machine_catalog" "example" {
  name = var.machine_catalog_name

  provisioning_scheme = {
    identity_type = "ActiveDirectory"

    machine_domain_identity = {
      domain             = var.domain_name          # ← Value IS configured!
      service_account_id = var.service_account_id   # ← Depends on service account
    }

    # ... other configuration
  }
}

# modules/citrix-machine-catalog/variables.tf
variable "domain_name" {
  description = "Active Directory Domain Name"
  type        = string
}

variable "service_account_id" {
  description = "Citrix Service Account ID for domain join"
  type        = string
}
```

## Terraform console output

```
Error: Missing Attribute Configuration
│
│   with module.example_machine_catalog.citrix_machine_catalog.example,
│   on modules/citrix-machine-catalog/main.tf line 2, in resource "citrix_machine_catalog" "example":
│    2: resource "citrix_machine_catalog" "example" {
│
│ Expected domain to be configured when identity_type is Active Directory.

Planning failed. Terraform encountered an error while generating this plan.
```

## Expected Behavior

The provider should:
1. **Respect Terraform dependencies** - Wait for `service_account_id` to be available before validation
2. **Validate during apply phase** - Not during plan phase when dependencies are unresolved
3. **Provide accurate error messages** - The domain IS configured (`domain_name = "example.domain.com"`)

## Actual Behavior

- Provider validates `identity_type = "ActiveDirectory"` during `terraform plan`
- Validation occurs before Terraform can resolve the `service_account_id` dependency
- Error message claims domain is "missing" when it's actually properly configured
- Prevents clean single-phase infrastructure deployment

## Workaround

Currently using conditional logic to bypass the premature validation:

```hcl
resource "citrix_machine_catalog" "example" {
  provisioning_scheme = {
    identity_type = var.service_account_id != null ? "ActiveDirectory" : "None"

    machine_domain_identity = var.service_account_id != null ? {
      domain             = var.domain_name
      service_account_id = var.service_account_id
    } : null
  }
}
```

## Impact

- **Breaks clean infrastructure deployment** - Requires complex workarounds where none should be needed
- **Forces unnecessary conditional logic** - Should work with standard Terraform dependency patterns
- **Misleading error messages** - Confuses troubleshooting efforts

## Terraform log file

The issue can be reproduced by enabling debug logging:

```bash
export TF_LOG="DEBUG"
export TF_LOG_PATH="./citrix-provider-issue.txt"
terraform plan
```

The logs will show the validation occurring during the plan phase before dependency resolution.
