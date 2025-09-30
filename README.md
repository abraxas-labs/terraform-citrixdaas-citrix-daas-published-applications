# Terraform Module for Citrix Published Applications

**Note**: This project is intended for testing purposes only. Please do not use it for deploying production infrastructure.

Welcome to the Terraform module for creating and managing Citrix Published Applications! This module is designed to simplify the deployment and management of Citrix Published Applications using Terraform. Whether you're a seasoned Terraform user or just getting started, our module makes it easy to integrate Citrix into your infrastructure as code (IaC) workflow.

**Feedback**: If you enjoyed this tutorial, please give this repo a star by clicking the star button at the top right of this page.

**Error Handling and General Questions**:
If you encounter an error during module execution or have a general question, please create a new issue at the following link: [GitHub Issues](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/issues).


## Features

- **Easy to Use**: Simple and intuitive configuration for quick setup.
- **Flexible**: Supports a wide range of Citrix configurations and use cases.
- **Automated**: Streamlines the deployment and management of Citrix Published Applications.
- **Scalable**: Handles small to large Citrix environments with ease.

## Getting Started

To get started with this module, follow these steps:

1. **Prerequisites**: Ensure you have the following prerequisites in place:
   - **Terraform installed** (we recommend installing Terraform on Linux or WSL)
   - **Citrix Cloud account**
   - **Delivery Group**
2. **Configuration**: Configure the module with the necessary Citrix parameters. Refer to the **Usage** section below for an example.
3. **Initialization**: Run `terraform init` to initialize the module.
4. **Apply Changes**: Run `terraform apply` to deploy the Citrix Published Applications.

## Configuration

1. **Install Terraform**: Download and install Terraform from the official Terraform website.
2. **Configure Citrix API Access**: You’ll need API access to Citrix Cloud. Follow the steps in Step 2: Create an API Client and Set Environment Variables.
3. **Set Environment Variables**: Set up these variables in your shell to enable Terraform access to Citrix resources.
4. **Find Your Delivery Group Name**:
   - Log into the Citrix Cloud Console and go to **DaaS > Manage > Delivery Groups**.
   - Identify the Delivery Group name that will publish applications. Note this name exactly as it appears in Citrix, as it will be used in the `TF_VAR_citrix_deliverygroup_name` variable.
5. **Choose Application Visibility Settings**:
   - The `citrix_application_visibility` variable specifies who can access the application.
   - By default, this is set to all users within the delivery group.
   - To restrict access, you can specify particular users or Active Directory groups by their domain names. For example:
     ```sh
     export TF_VAR_citrix_application_visibility='["domain\\UserOrGroupName"]'
     ```
6. **Set All Required Variables in the Shell**:
   - After confirming the delivery group name and visibility settings, set the environment variables in your shell as follows:
     ```sh
     export TF_VAR_client_id="your_client_id"
     export TF_VAR_client_secret="your_client_secret"
     export TF_VAR_customer_id="your_customer_id"
     export TF_VAR_citrix_deliverygroup_name='["YourDeliveryGroupName"]'
     export TF_VAR_citrix_application_visibility='["domain\\UserOrGroupName"]' # Adjust as needed
     ```

## Usage

Create TF Files
Create two files: `main.tf` and `customer.auto.tfvars`. In the `customer.auto.tfvars` file, you can adjust the values as needed.

<details>
<summary>Create TF Files</summary>
<br>
This is how you dropdown.


**main.tf**:
```hcl
terraform {
  required_version = ">=1.2"
  required_providers {
    citrix = {
      source  = "citrix/citrix"
      version = "=1.0.7"
    }
  }
}

# This block specifies the Citrix Provider configuration.
provider "citrix" {
  cvad_config = {
    customer_id   = var.customer_id
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}

###############################################################################
# Data Sources
###############################################################################

data "citrix_delivery_group" "example_delivery_group" {
  name = var.citrix_deliverygroup_name[0]
}

resource "citrix_admin_folder" "example_admin_folder_1" {
  name = var.mandant_prefix
  type = ["ContainsApplications"]
}

###############################################################################
# Resources
###############################################################################

module "citrix-daas-published-applications" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "0.5.7"
  citrix_application_name                    = var.citrix_application_name
  citrix_application_description             = var.citrix_application_description
  citrix_application_published_name          = var.citrix_application_published_name
  citrix_application_command_line_arguments  = "“%**”"
  citrix_application_command_line_executable = var.citrix_application_command_line_executable
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = citrix_admin_folder.example_admin_folder_1.path
  citrix_deliverygroup_name                  = data.citrix_delivery_group.example_delivery_group.name
  # Optional parameters
  #citrix_application_visibility              = var.citrix_application_visibility
  #citrix_application_icon                    = citrix_application_icon.example_application_icon.id

}


resource "citrix_application_icon" "example_application_icon" {
  raw_data = filebase64("${path.module}/${var.icon_path}")
}

###############################################################################
# Variables
###############################################################################

variable "client_id" {
  description = <<-EOF
  Please enter the The Citrix Cloud Client id. Example: 12345678-1234-1234-1234-123456789012
  Link https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html
  EOF
  type        = string
}

variable "client_secret" {
  description = <<-EOF
  Please enter the The Citrix Cloud Client secret. Example: xxxxxxx-xxxxxxx==
  Link https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html
  EOF
  type        = string
  sensitive   = true
}

variable "customer_id" {
  description = <<-EOF
  Please enter The Citrix Cloud customer id. Example: xxxxxxxx
  Link https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html
  EOF
  type        = string
}

variable "citrix_application_visibility" {
  description = <<-EOF
  Please enter Users or group . Example: ["domain\\UserOrGroupName"]
  By default, the application is visible to all users within a delivery group. However, you can restrict its visibility to only certain users by specifying them in the limit_visibility_to_users list.
  EOF
  type        = list(string)
  default     = []
}

variable "citrix_deliverygroup_name" {
  description = <<-EOF
  Please enter the Name of the delivery group. Example: ["DG-A-Test"]
  EOF
  type        = list(string)
}

variable "citrix_application_name" {
  description = "The name of the application"
  type        = string
}

variable "citrix_application_description" {
  description = "Application Description"
  type        = string
}

variable "citrix_application_published_name" {
  description = "The name of the application"
  type        = string
}

variable "citrix_application_command_line_executable" {
  description = "The command line executable"
  type        = string
}

variable "icon_path" {
  description = "Please enter the Path to the icon"
  type        = string
  default     = "/icons/citrix.ico"
}

variable "mandant_prefix" {
  description = "please enter the Customer name"
  type        = string
}
```


customer.auto.tfvars
```hcl
mandant_prefix                             = "Customer A"
citrix_application_name                    = "Calc Citrix Terraform 💡 Innovator 🎬 Showcase"
citrix_application_published_name          = "Calc Citrix-Terraform_Showcase"
citrix_application_description             = "Experience the future of application delivery with our innovative demo that combines the power of Citrix and Terraform. These showcase apps demonstrate how you can create and manage Citrix environments efficiently and automatically with Terraform."
citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
icon_path                                  = "icons/citrix.ico"
```

</details>


## Next Steps
### Initialize Terraform: Run
```hcl
terraform init.
```

### Plan and Apply Terraform Configuration:
```hcl
terraform plan
```

```hcl
terraform apply -auto-approve
```

## Destroy Terraform Resources:

```hcl
terraform destroy -auto-approve
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
