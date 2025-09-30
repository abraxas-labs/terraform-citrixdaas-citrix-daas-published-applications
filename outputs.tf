# Application Outputs
output "citrix_published_application_name" {
  value       = citrix_application.published_application.name
  description = "The internal name of the published Citrix application"
}

output "application_id" {
  value       = citrix_application.published_application.id
  description = "The unique identifier of the published application"
}

output "application_published_name" {
  value       = citrix_application.published_application.published_name
  description = "The display name shown to end users in Citrix Workspace"
}

output "application_folder_path" {
  value       = citrix_application.published_application.application_folder_path
  description = "The folder path where the application is organized in Citrix Cloud"
}

# Delivery Group Outputs
output "delivery_group_name" {
  value       = data.citrix_delivery_group.this.name
  description = "The name of the delivery group hosting the application"
}

output "delivery_group_id" {
  value       = data.citrix_delivery_group.this.id
  description = "The unique identifier of the delivery group"
}
