# Terraform Module: Citrix DaaS Published Applications

[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/abraxas-labs/citrix-daas-published-applications/citrixdaas)
[![GitHub release](https://img.shields.io/github/v/release/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications)](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications)](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/issues)
[![GitHub stars](https://img.shields.io/github/stars/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications?style=social)](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications)

Terraform module for creating and managing Citrix Published Applications in Citrix DaaS (Desktop as a Service).

**Feedback**: If you enjoyed this module, please give this repo a star by clicking the star button at the top right of this page.

**Error Handling and General Questions**: If you encounter an error during module execution or have a general question, please create a new issue at the following link: [GitHub Issues](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/issues).

> **New to Terraform?** Check out our [Getting Started Guide for Citrix Administrators](docs/GETTING_STARTED_FOR_CITRIX_ADMINS.md) — a complete tutorial with step-by-step instructions, screenshots, and GUI comparisons. Additional resources including advanced examples and troubleshooting can be found in the [Documentation](#documentation) section below.

## Usage

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
```

## Features

- 🚀 **Simple, declarative application publishing** — Minimal configuration required
- 🔒 **User/group visibility restrictions** — Control access via Active Directory
- 🎨 **Custom application icons** — Brand your applications
- ✅ **Production-ready** — Used in enterprise environments
- 📦 **Validated inputs** — Comprehensive validation prevents errors
- 🔄 **Composable outputs** — Chain with other Terraform modules

## Prerequisites

Before using this module, ensure you have:

- **Terraform** >= 1.2 ([Installation Guide](https://developer.hashicorp.com/terraform/install))
- **Citrix Cloud account** with DaaS service enabled
- **Existing Citrix Delivery Group** (this module does NOT create Delivery Groups)
- **Citrix Cloud API credentials** ([How to create](docs/GETTING_STARTED_FOR_CITRIX_ADMINS.md#2-citrix-cloud-api-credentials))
- **Application folder** in Citrix Cloud (e.g., "Production")

### API Credentials Setup

Set your Citrix Cloud API credentials as environment variables:

**Linux/WSL:**
```bash
export TF_VAR_client_id="your-client-id"
export TF_VAR_client_secret="your-client-secret"
export TF_VAR_customer_id="your-customer-id"
```

**Windows PowerShell:**
```powershell
$env:TF_VAR_client_id="your-client-id"
$env:TF_VAR_client_secret="your-client-secret"
$env:TF_VAR_customer_id="your-customer-id"
```

Then configure the Citrix provider in your `terraform.tf`:

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

## Examples

### Basic Application

```hcl
module "notepad" {
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
}
```

For more examples including visibility restrictions, custom icons, and bulk deployments, see:
- [examples/](examples/) directory
- [Advanced Examples Documentation](docs/EXAMPLES.md)

## Outputs

This module provides the following outputs:

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

## Documentation

- **[Getting Started for Citrix Admins](docs/GETTING_STARTED_FOR_CITRIX_ADMINS.md)** — Complete tutorial with GUI comparisons, installation guide, and step-by-step instructions
- **[Advanced Examples](docs/EXAMPLES.md)** — Real-world scenarios and complex configurations
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** — Common errors, solutions, and FAQ

### Quick Troubleshooting

| Error | Solution |
|-------|----------|
| `Delivery Group not found` | Ensure the Delivery Group exists in Citrix Cloud and the name matches exactly |
| `Invalid API credentials` | Verify Customer ID, Client ID, and Secret; create new credentials if needed |
| `Application folder path not found` | Create the folder in Citrix Studio before running `terraform apply` |

## Contributing

Thank you to all contributors:
- @cedfont
- @abraxas-citrix-bot

Contributions are welcome! Please open an issue or pull request.

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Module Reference

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
