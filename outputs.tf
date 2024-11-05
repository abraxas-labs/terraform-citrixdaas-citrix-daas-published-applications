output "citrix_published_apllication_name" {
  value       = citrix_application.published_application.name
  description = "Citrix Published Application Name"
}


output "delivery_group_name" {
  value       = data.citrix_delivery_group.example_delivery_group.name
  description = "Citrix Delivery Group Name"
}
