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

# Query existing Delivery Group
data "citrix_delivery_group" "production" {
  name = var.citrix_deliverygroup_name
}

# Query existing Application Folder
data "citrix_admin_folder" "apps" {
  path = var.citrix_application_folder
}

# Publish Calculator Application
module "calculator" {
  source = "../.."

  citrix_application_name                    = "calculator-app"
  citrix_application_published_name          = "Calculator"
  citrix_application_description             = "Windows Calculator Application"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = data.citrix_admin_folder.apps.path
  citrix_deliverygroup_name                  = data.citrix_delivery_group.production.name
}

output "calculator_name" {
  value       = module.calculator.citrix_published_application_name
  description = "The name of the published Calculator application"
}

output "delivery_group" {
  value       = module.calculator.delivery_group_name
  description = "The delivery group hosting the application"
}
