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

# Publish Notepad Application
# NOTE: To use custom icon, uncomment the citrix_application_icon resource below
#       and add an icon file to icons/notepad.ico
module "notepad" {
  source = "../.."

  citrix_application_name                    = "notepad-app"
  citrix_application_published_name          = "Notepad"
  citrix_application_description             = "Windows Notepad Text Editor"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\notepad.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = data.citrix_admin_folder.apps.path
  citrix_deliverygroup_name                  = data.citrix_delivery_group.production.name
  # citrix_application_icon                  = citrix_application_icon.notepad_icon.id  # Uncomment if using icon
}

# Optional: Uncomment to use custom application icon
# resource "citrix_application_icon" "notepad_icon" {
#   raw_data = filebase64("${path.module}/icons/notepad.ico")
# }

output "notepad_name" {
  value       = module.notepad.citrix_published_application_name
  description = "The name of the published Notepad application"
}

# Optional: Uncomment if using custom icon
# output "notepad_icon_id" {
#   value       = citrix_application_icon.notepad_icon.id
#   description = "The ID of the custom icon"
# }
