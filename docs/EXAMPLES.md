# Advanced Examples

This document provides real-world scenarios and advanced configurations for the Citrix Published Applications Terraform module.

## Table of Contents

- [Bulk Application Deployment](#bulk-application-deployment)
- [Multi-Environment Deployment](#multi-environment-deployment)
- [Application Visibility Management](#application-visibility-management)
- [Custom Icons and Branding](#custom-icons-and-branding)
- [Advanced Command Line Arguments](#advanced-command-line-arguments)
- [Working with Application Groups](#working-with-application-groups)

---

## Bulk Application Deployment

Deploy multiple applications simultaneously using Terraform's module reusability.

### Scenario: Deploy 10 Microsoft Office Applications

```hcl
# main.tf
locals {
  office_apps = {
    word = {
      name           = "word"
      published_name = "Microsoft Word"
      executable     = "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
      description    = "Word Processing Application"
    }
    excel = {
      name           = "excel"
      published_name = "Microsoft Excel"
      executable     = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
      description    = "Spreadsheet Application"
    }
    powerpoint = {
      name           = "powerpoint"
      published_name = "Microsoft PowerPoint"
      executable     = "C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE"
      description    = "Presentation Application"
    }
    outlook = {
      name           = "outlook"
      published_name = "Microsoft Outlook"
      executable     = "C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE"
      description    = "Email and Calendar Application"
    }
    teams = {
      name           = "teams"
      published_name = "Microsoft Teams"
      executable     = "C:\\Program Files\\Microsoft\\Teams\\current\\Teams.exe"
      description    = "Collaboration Platform"
    }
  }
}

module "office_applications" {
  source   = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version  = "~> 0.6"
  for_each = local.office_apps

  citrix_application_name                    = each.value.name
  citrix_application_published_name          = each.value.published_name
  citrix_application_description             = each.value.description
  citrix_application_command_line_executable = each.value.executable
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Microsoft Office"
  citrix_deliverygroup_name                  = "Production-DG"
}

output "office_apps_deployed" {
  value = {
    for app_key, app_module in module.office_applications :
    app_key => app_module.citrix_published_application_name
  }
}
```

**Result**: All 5 applications deployed with a single `terraform apply` command.

**Time Savings**:
- Manual (GUI): 5 apps × 5 minutes = 25 minutes
- Terraform: ~2 minutes total

---

## Multi-Environment Deployment

Deploy the same application across Dev, Test, and Production environments.

### Scenario: Separate Environments with Workspaces

```hcl
# environments.tf
locals {
  environment = terraform.workspace

  env_config = {
    dev = {
      delivery_group = "Dev-DG"
      folder_path    = "Development"
    }
    test = {
      delivery_group = "Test-DG"
      folder_path    = "Testing"
    }
    prod = {
      delivery_group = "Production-DG"
      folder_path    = "Production"
    }
  }

  current_env = local.env_config[local.environment]
}

module "calculator" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "calculator-${local.environment}"
  citrix_application_published_name          = "Calculator (${upper(local.environment)})"
  citrix_application_description             = "Windows Calculator - ${upper(local.environment)} Environment"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = local.current_env.folder_path
  citrix_deliverygroup_name                  = local.current_env.delivery_group
}
```

**Usage**:
```bash
# Deploy to Dev
terraform workspace select dev
terraform apply

# Deploy to Test
terraform workspace select test
terraform apply

# Deploy to Production
terraform workspace select prod
terraform apply
```

---

## Application Visibility Management

Control application access using Active Directory groups and users.

### Scenario 1: Department-Based Access

```hcl
# Finance applications only for Finance team
module "sap_finance" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "sap-finance"
  citrix_application_published_name          = "SAP Finance Module"
  citrix_application_description             = "SAP Financial Management"
  citrix_application_command_line_executable = "C:\\Program Files\\SAP\\FrontEnd\\SAPgui\\saplogon.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Finance"
  citrix_deliverygroup_name                  = "Production-DG"

  citrix_application_visibility = [
    "CONTOSO\\Finance-Department",
    "CONTOSO\\CFO",
    "CONTOSO\\Finance-Managers"
  ]
}
```

### Scenario 2: Role-Based Access with Multiple Groups

```hcl
locals {
  # Define AD groups for different roles
  admin_users = [
    "CONTOSO\\IT-Admins",
    "CONTOSO\\System-Administrators"
  ]

  power_users = [
    "CONTOSO\\Power-Users",
    "CONTOSO\\Department-Heads"
  ]

  # Combine groups for specific applications
  privileged_users = concat(local.admin_users, local.power_users)
}

module "admin_tools" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "admin-tools"
  citrix_application_published_name          = "Administrative Tools"
  citrix_application_description             = "System Administration Console"
  citrix_application_command_line_executable = "C:\\Windows\\System32\\mmc.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Administration"
  citrix_deliverygroup_name                  = "Production-DG"

  citrix_application_visibility = local.privileged_users
}
```

### Scenario 3: Individual User Access

```hcl
module "executive_app" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "executive-dashboard"
  citrix_application_published_name          = "Executive Dashboard"
  citrix_application_description             = "C-Level Analytics Dashboard"
  citrix_application_command_line_executable = "C:\\Program Files\\BusinessIntel\\Dashboard.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Executive"
  citrix_deliverygroup_name                  = "Production-DG"

  citrix_application_visibility = [
    "CONTOSO\\john.smith",      # CEO
    "CONTOSO\\jane.doe",        # CFO
    "CONTOSO\\bob.johnson",     # CTO
    "CONTOSO\\C-Level-Admins"   # Support staff
  ]
}
```

---

## Custom Icons and Branding

Add custom icons to published applications for better user experience.

### Scenario 1: Single Custom Icon

```hcl
resource "citrix_application_icon" "company_app_icon" {
  raw_data = filebase64("${path.module}/icons/company-logo.ico")
}

module "company_portal" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "company-portal"
  citrix_application_published_name          = "Company Portal"
  citrix_application_description             = "Internal Company Portal"
  citrix_application_command_line_executable = "C:\\Program Files\\CompanyApps\\Portal.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Company Apps"
  citrix_deliverygroup_name                  = "Production-DG"

  citrix_application_icon = citrix_application_icon.company_app_icon.id
}
```

### Scenario 2: Multiple Icons for Different Applications

```hcl
# Define icons
locals {
  app_icons = {
    crm    = "${path.module}/icons/crm.ico"
    erp    = "${path.module}/icons/erp.ico"
    hr     = "${path.module}/icons/hr.ico"
  }
}

resource "citrix_application_icon" "app_icons" {
  for_each = local.app_icons
  raw_data = filebase64(each.value)
}

# CRM Application with custom icon
module "crm_app" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "crm-salesforce"
  citrix_application_published_name          = "Salesforce CRM"
  citrix_application_description             = "Customer Relationship Management"
  citrix_application_command_line_executable = "C:\\Program Files\\Salesforce\\salesforce.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Business Apps"
  citrix_deliverygroup_name                  = "Production-DG"

  citrix_application_icon = citrix_application_icon.app_icons["crm"].id
}
```

**Icon Requirements**:
- Format: `.ico` file
- Recommended size: 256x256 pixels
- Color depth: 32-bit (with transparency)

---

## Advanced Command Line Arguments

Configure applications with specific command line parameters.

### Scenario 1: Open Specific Document

```hcl
module "word_template" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "word-invoice-template"
  citrix_application_published_name          = "Invoice Template (Word)"
  citrix_application_description             = "Pre-configured Invoice Template"
  citrix_application_command_line_executable = "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
  citrix_application_command_line_arguments  = "\\\\fileserver\\templates\\invoice.dotx"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%\\Documents"
  citrix_application_folder_path             = "Templates"
  citrix_deliverygroup_name                  = "Production-DG"
}
```

### Scenario 2: User-Specified Parameters

Allow users to pass parameters from Citrix Workspace:

```hcl
module "cmd_with_params" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "cmd-advanced"
  citrix_application_published_name          = "Command Prompt (Advanced)"
  citrix_application_description             = "Command Prompt with User Parameters"
  citrix_application_command_line_executable = "C:\\Windows\\System32\\cmd.exe"
  citrix_application_command_line_arguments  = "/c %%**"
  # %%** allows users to specify parameters from Workspace
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Tools"
  citrix_deliverygroup_name                  = "Production-DG"
}
```

### Scenario 3: Application with Configuration File

```hcl
module "app_with_config" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "custom-app-prod"
  citrix_application_published_name          = "Custom Application (Production)"
  citrix_application_description             = "Custom App with Production Config"
  citrix_application_command_line_executable = "C:\\Program Files\\CustomApp\\app.exe"
  citrix_application_command_line_arguments  = "--config=\\\\fileserver\\configs\\prod.xml --mode=production"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Custom Apps"
  citrix_deliverygroup_name                  = "Production-DG"
}
```

---

## Working with Application Groups

Organize related applications into logical groups using folder structures.

### Scenario: Departmental Application Structure

```hcl
locals {
  departments = {
    finance = {
      folder = "Finance Applications"
      apps = {
        sap = {
          name           = "sap-finance"
          published_name = "SAP Finance"
          executable     = "C:\\Program Files\\SAP\\FrontEnd\\SAPgui\\saplogon.exe"
          visibility     = ["CONTOSO\\Finance-Department"]
        }
        excel = {
          name           = "excel-finance"
          published_name = "Excel (Finance)"
          executable     = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
          visibility     = ["CONTOSO\\Finance-Department"]
        }
      }
    }
    hr = {
      folder = "HR Applications"
      apps = {
        workday = {
          name           = "workday-hr"
          published_name = "Workday HCM"
          executable     = "C:\\Program Files\\Workday\\workday.exe"
          visibility     = ["CONTOSO\\HR-Department"]
        }
      }
    }
  }
}

module "department_apps" {
  source   = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version  = "~> 0.6"

  for_each = merge([
    for dept_key, dept in local.departments : {
      for app_key, app in dept.apps :
      "${dept_key}-${app_key}" => merge(app, { folder = dept.folder })
    }
  ]...)

  citrix_application_name                    = each.value.name
  citrix_application_published_name          = each.value.published_name
  citrix_application_description             = "Department Application for ${each.value.published_name}"
  citrix_application_command_line_executable = each.value.executable
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = each.value.folder
  citrix_deliverygroup_name                  = "Production-DG"
  citrix_application_visibility              = each.value.visibility
}
```

---

## Complete End-to-End Example

Combining multiple features for a real-world deployment:

```hcl
# icons.tf
locals {
  icon_files = {
    word   = "icons/word.ico"
    excel  = "icons/excel.ico"
    custom = "icons/company-logo.ico"
  }
}

resource "citrix_application_icon" "icons" {
  for_each = local.icon_files
  raw_data = filebase64("${path.module}/${each.value}")
}

# applications.tf
locals {
  applications = {
    word-finance = {
      name           = "word-finance"
      published_name = "Microsoft Word (Finance)"
      description    = "Word Processing for Finance Department"
      executable     = "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
      arguments      = ""
      folder         = "Finance/Microsoft Office"
      delivery_group = "Production-DG"
      visibility     = ["CONTOSO\\Finance-Users"]
      icon_key       = "word"
    }
    excel-finance = {
      name           = "excel-finance"
      published_name = "Microsoft Excel (Finance)"
      description    = "Spreadsheet Application for Finance"
      executable     = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
      arguments      = ""
      folder         = "Finance/Microsoft Office"
      delivery_group = "Production-DG"
      visibility     = ["CONTOSO\\Finance-Users", "CONTOSO\\Finance-Managers"]
      icon_key       = "excel"
    }
    custom-portal = {
      name           = "finance-portal"
      published_name = "Finance Portal"
      description    = "Internal Finance Portal"
      executable     = "C:\\Program Files\\CompanyApps\\FinancePortal.exe"
      arguments      = "--department=finance"
      folder         = "Finance/Custom Apps"
      delivery_group = "Production-DG"
      visibility     = ["CONTOSO\\Finance-Department"]
      icon_key       = "custom"
    }
  }
}

module "applications" {
  source   = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version  = "~> 0.6"
  for_each = local.applications

  citrix_application_name                    = each.value.name
  citrix_application_published_name          = each.value.published_name
  citrix_application_description             = each.value.description
  citrix_application_command_line_executable = each.value.executable
  citrix_application_command_line_arguments  = each.value.arguments
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = each.value.folder
  citrix_deliverygroup_name                  = each.value.delivery_group
  citrix_application_visibility              = each.value.visibility
  citrix_application_icon                    = citrix_application_icon.icons[each.value.icon_key].id
}

# outputs.tf
output "deployed_applications" {
  description = "Summary of all deployed applications"
  value = {
    for app_key, app in module.applications :
    app_key => {
      id             = app.application_id
      published_name = app.application_published_name
      folder         = app.application_folder_path
      delivery_group = app.delivery_group_name
    }
  }
}
```

**Deploy**:
```bash
terraform init
terraform plan
terraform apply
```

**Result**: 3 applications deployed with custom icons, folder organization, and visibility restrictions—all from a single Terraform configuration.

---

## Best Practices

1. **Use Locals for Reusability**: Define application configurations in `locals` blocks for easier maintenance
2. **Leverage `for_each`**: Deploy multiple similar applications efficiently
3. **Organize with Folders**: Use Citrix folder paths to group related applications
4. **Manage Visibility**: Use AD groups instead of individual users for easier access management
5. **Version Control**: Store all configurations in Git for change tracking
6. **Environment Separation**: Use Terraform workspaces or separate configurations for Dev/Test/Prod
7. **Custom Icons**: Brand applications for better user experience
8. **Document Arguments**: Add comments explaining command line arguments

---

## Additional Resources

- [Main README](../README.md)
- [Getting Started Guide for Citrix Admins](GETTING_STARTED_FOR_CITRIX_ADMINS.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Citrix Provider Documentation](https://registry.terraform.io/providers/citrix/citrix/latest/docs)
