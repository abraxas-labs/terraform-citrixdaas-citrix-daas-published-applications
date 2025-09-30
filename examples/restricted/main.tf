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

# Publish Excel Application with restricted visibility
module "excel" {
  source = "../.."

  citrix_application_name                    = "excel-app"
  citrix_application_published_name          = "Microsoft Excel"
  citrix_application_description             = "Microsoft Excel Spreadsheet Application (Finance Team Only)"
  citrix_application_command_line_executable = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%\\Documents"
  citrix_application_folder_path             = data.citrix_admin_folder.apps.path
  citrix_deliverygroup_name                  = data.citrix_delivery_group.production.name

  # Restrict visibility to specific AD groups
  citrix_application_visibility = var.citrix_application_visibility
}

output "excel_name" {
  value       = module.excel.citrix_published_application_name
  description = "The name of the published Excel application"
}

output "restricted_to" {
  value       = var.citrix_application_visibility
  description = "Users/groups with access to the application"
}
