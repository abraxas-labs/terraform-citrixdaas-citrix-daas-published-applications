variable "citrix_customer_id" {
  description = "Citrix Cloud Customer ID"
  type        = string
  sensitive   = true
}

variable "citrix_client_id" {
  description = "Citrix Cloud Client ID"
  type        = string
  sensitive   = true
}

variable "citrix_client_secret" {
  description = "Citrix Cloud Client Secret"
  type        = string
  sensitive   = true
}

variable "citrix_deliverygroup_name" {
  description = "Name of the existing Citrix Delivery Group"
  type        = string
}
