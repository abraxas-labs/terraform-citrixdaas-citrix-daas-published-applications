terraform {
  required_version = ">= 1.2"
  required_providers {
    citrix = {
      source  = "citrix/citrix"
      version = ">= 1.0"
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

# Example: Publishing application in ROOT folder (no subfolder)
# This is useful when you don't want to organize apps into folders
# or when you want to keep the folder structure simple

module "calculator" {
  source = "../.."

  citrix_application_name                    = "calculator-root"
  citrix_application_published_name          = "Calculator (Root)"
  citrix_application_description             = "Calculator in root folder - no subfolder organization"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = var.citrix_deliverygroup_name

  # OPTION 1: Omit the folder path entirely (recommended)
  # citrix_application_folder_path is not specified → app goes to root

  # OPTION 2: Explicitly set to null
  # citrix_application_folder_path = null
}

output "calculator_name" {
  value       = module.calculator.citrix_published_application_name
  description = "The name of the published Calculator application"
}

output "delivery_group" {
  value       = module.calculator.delivery_group_name
  description = "The delivery group hosting the application"
}
