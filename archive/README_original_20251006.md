# Terraform Module: Citrix DaaS Published Applications

[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/abraxas-labs/citrix-daas-published-applications/citrixdaas)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A production-ready Terraform module for creating and managing Citrix Published Applications in Citrix DaaS (Desktop as a Service).

This module simplifies the deployment and management of Citrix Published Applications using Infrastructure as Code. Whether you're a seasoned Terraform user or just getting started, this module makes it easy to integrate Citrix into your IaC workflow.

**Feedback**: If you enjoyed this module, please give this repo a star by clicking the star button at the top right of this page.

**Error Handling and General Questions**:
If you encounter an error during module execution or have a general question, please create a new issue at the following link: [GitHub Issues](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/issues).


## Features

- 🚀 **Simple, declarative application publishing** - Minimal configuration required
- 🔒 **Optional user/group visibility restrictions** - Control who sees the application
- 🎨 **Custom application icon support** - Brand your applications
- ✅ **Production-ready** - Used in enterprise environments
- 📦 **Validated inputs** - Comprehensive validation rules prevent errors
- 🔄 **Composable outputs** - Chain with other modules

## Prerequisites

Before using this module, ensure you have:

- **Terraform** >= 1.2 (we recommend installing on Linux or WSL)
- **Citrix Cloud account** with DaaS service enabled
- **Existing Citrix Delivery Group** where applications will be published
- **Citrix Cloud API credentials**:
  - Customer ID
  - Client ID
  - Client Secret
  - [How to get API credentials](https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html)
- **Application folder** in Citrix Cloud (e.g., "Production", "Applications")

## Quick Start

### 1. Configure Citrix Provider

Create a `terraform.tf` file:

```hcl
terraform {
  required_version = ">= 1.2"
  required_providers {
    citrix = {
      source  = "citrix/citrix"
      version = "~> 1.0.7"
    }
  }
}

provider "citrix" {
  cvad_config = {
    customer_id   = var.citrix_customer_id
    client_id     = var.citrix_client_id
    client_secret = var.citrix_client_secret
  }
}
```

### 2. Use the Module

Create a `main.tf` file:

```hcl
module "calculator" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "calculator-app"
  citrix_application_published_name          = "Calculator"
  citrix_application_description             = "Windows Calculator Application"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"
}

output "application_name" {
  value = module.calculator.citrix_published_application_name
}
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Advanced Configuration

### Restricting Application Visibility

By default, applications are visible to all users in the delivery group. To restrict access to specific AD users or groups:

```hcl
module "excel_restricted" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "excel-app"
  citrix_application_published_name          = "Microsoft Excel"
  citrix_application_description             = "Excel for Finance Team"
  citrix_application_command_line_executable = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"

  # Restrict to specific AD groups and users
  citrix_application_visibility = [
    "CONTOSO\\Finance-Users",
    "CONTOSO\\john.doe"
  ]
}
```

### Adding Custom Application Icon

```hcl
# Create the icon resource
resource "citrix_application_icon" "custom_icon" {
  raw_data = filebase64("${path.module}/icons/app.ico")
}

# Use the icon in your application
module "app_with_icon" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "notepad-app"
  citrix_application_published_name          = "Notepad"
  citrix_application_description             = "Text Editor"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\notepad.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"

  # Use custom icon
  citrix_application_icon = citrix_application_icon.custom_icon.id
}
```

## Examples

See the [examples/](examples/) directory for complete working examples:

- **[basic/](examples/basic/)** - Minimal configuration (Calculator app)
- **[with-icon/](examples/with-icon/)** - Custom application icon (Notepad)
- **[restricted/](examples/restricted/)** - AD user/group restrictions (Excel)

## Outputs

This module provides several outputs for integration with other modules:

```hcl
output "application_info" {
  value = {
    id             = module.calculator.application_id
    name           = module.calculator.citrix_published_application_name
    published_name = module.calculator.application_published_name
    folder_path    = module.calculator.application_folder_path
    delivery_group = module.calculator.delivery_group_name
  }
}
```

## Contributing
Thank you to all the people who have contributed to this project!

@cedfont
@abraxas-citrix-bot

## License
This module is licensed under the MIT License. See the LICENSE file for details.



# terraform-docs

[![Build Status](https://github.com/terraform-docs/terraform-docs/workflows/ci/badge.svg)](https://github.com/terraform-docs/terraform-docs/actions) [![GoDoc](https://pkg.go.dev/badge/github.com/terraform-docs/terraform-docs)](https://pkg.go.dev/github.com/terraform-docs/terraform-docs) [![Go Report Card](https://goreportcard.com/badge/github.com/terraform-docs/terraform-docs)](https://goreportcard.com/report/github.com/terraform-docs/terraform-docs) [![Codecov Report](https://codecov.io/gh/terraform-docs/terraform-docs/branch/master/graph/badge.svg)](https://codecov.io/gh/terraform-docs/terraform-docs) [![License](https://img.shields.io/github/license/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/blob/master/LICENSE) [![Latest release](https://img.shields.io/github/v/release/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/releases)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_citrix"></a> [citrix](#requirement\_citrix) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_citrix"></a> [citrix](#provider\_citrix) | 1.0.28 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [citrix_application.published_application](https://registry.terraform.io/providers/citrix/citrix/latest/docs/resources/application) | resource |
| [citrix_delivery_group.this](https://registry.terraform.io/providers/citrix/citrix/latest/docs/data-sources/delivery_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_citrix_application_command_line_arguments"></a> [citrix\_application\_command\_line\_arguments](#input\_citrix\_application\_command\_line\_arguments) | Command line arguments passed to the executable when launched. Use empty string if no arguments needed.<br>Special patterns supported by Citrix:<br>  - "" (empty string): No arguments<br>  - "%%**": Pass user-specified parameters from Citrix Workspace<br>  - "/c %%**": Command interpreter with user parameters<br>  - "-file document.docx": Static arguments<br>Example: "" or "%%**" or "-openfile" | `string` | `""` | no |
| <a name="input_citrix_application_command_line_executable"></a> [citrix\_application\_command\_line\_executable](#input\_citrix\_application\_command\_line\_executable) | The full Windows path to the application executable on the VDA (Virtual Delivery Agent).<br>Must be a valid Windows path format with backslashes.<br>Examples:<br>  - "C:\\Windows\\system32\\calc.exe"<br>  - "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"<br>  - "C:\\Program Files (x86)\\Application\\app.exe" | `string` | n/a | yes |
| <a name="input_citrix_application_description"></a> [citrix\_application\_description](#input\_citrix\_application\_description) | A detailed description of the application. This is displayed to users in Citrix Workspace.<br>Example: "Microsoft Word 2021 - Document editing and creation" | `string` | n/a | yes |
| <a name="input_citrix_application_folder_path"></a> [citrix\_application\_folder\_path](#input\_citrix\_application\_folder\_path) | Citrix admin folder path where the application will be organized.<br>The folder must exist in Citrix Cloud before creating the application.<br>Use folder name without leading/trailing slashes.<br>Examples:<br>  - "Production" (single level)<br>  - "Production/Microsoft Office" (nested)<br>  - "Test/Utilities" (nested) | `string` | n/a | yes |
| <a name="input_citrix_application_icon"></a> [citrix\_application\_icon](#input\_citrix\_application\_icon) | Optional: The ID of a citrix\_application\_icon resource to use as the application icon.<br>If not provided (empty string), Citrix will use a default icon.<br>Example: citrix\_application\_icon.my\_icon.id<br>Note: Create the icon resource separately using citrix\_application\_icon. | `string` | `""` | no |
| <a name="input_citrix_application_name"></a> [citrix\_application\_name](#input\_citrix\_application\_name) | The internal name of the Citrix application. This name is used for identification<br>within Citrix Cloud and must be unique within your environment.<br>Example: "microsoft-word-2021" or "calculator-app" | `string` | n/a | yes |
| <a name="input_citrix_application_published_name"></a> [citrix\_application\_published\_name](#input\_citrix\_application\_published\_name) | The display name shown to end users in Citrix Workspace. This can be different<br>from the internal application name and can contain spaces and special characters.<br>Example: "Microsoft Word 2021" or "Calculator" | `string` | n/a | yes |
| <a name="input_citrix_application_visibility"></a> [citrix\_application\_visibility](#input\_citrix\_application\_visibility) | Optional list of Active Directory users or groups that can see this application.<br>If empty (default), the application is visible to all users in the delivery group.<br>Format: Use domain\\username or domain\\groupname with double backslashes.<br>Examples:<br>  - [] (visible to all users - default)<br>  - ["CONTOSO\\Finance-Users"] (single AD group)<br>  - ["CONTOSO\\Finance-Users", "CONTOSO\\john.doe"] (multiple entries)<br>Note: Users/groups must exist in Active Directory and be synced to Citrix Cloud. | `list(string)` | `[]` | no |
| <a name="input_citrix_application_working_directory"></a> [citrix\_application\_working\_directory](#input\_citrix\_application\_working\_directory) | The working directory for the application. Can use Windows environment variables.<br>Common values:<br>  - "%%HOMEDRIVE%%%%HOMEPATH%%" (recommended): User's home directory<br>  - "%%USERPROFILE%%": User's profile directory<br>  - "%%USERPROFILE%%\\Documents": User's Documents folder<br>  - "%%USERPROFILE%%\\Desktop": User's Desktop<br>  - "C:\\Temp": Fixed location<br>Example: "%%HOMEDRIVE%%%%HOMEPATH%%" | `string` | `"%HOMEDRIVE%%HOMEPATH%"` | no |
| <a name="input_citrix_deliverygroup_name"></a> [citrix\_deliverygroup\_name](#input\_citrix\_deliverygroup\_name) | Name of an existing Citrix Delivery Group that will host this application.<br>The delivery group must exist before creating the application.<br>Example: "Production-Windows-DG" or "Test-Delivery-Group" | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_folder_path"></a> [application\_folder\_path](#output\_application\_folder\_path) | The folder path where the application is organized in Citrix Cloud |
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The unique identifier of the published application |
| <a name="output_application_published_name"></a> [application\_published\_name](#output\_application\_published\_name) | The display name shown to end users in Citrix Workspace |
| <a name="output_citrix_published_application_name"></a> [citrix\_published\_application\_name](#output\_citrix\_published\_application\_name) | The internal name of the published Citrix application |
| <a name="output_delivery_group_id"></a> [delivery\_group\_id](#output\_delivery\_group\_id) | The unique identifier of the delivery group |
| <a name="output_delivery_group_name"></a> [delivery\_group\_name](#output\_delivery\_group\_name) | The name of the delivery group hosting the application |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
