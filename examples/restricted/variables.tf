variable "citrix_customer_id" {
  description = "Citrix Cloud Customer ID"
  type        = string
  sensitive   = true
}

variable "citrix_client_id" {
  description = "Citrix Cloud API Client ID"
  type        = string
  sensitive   = true
}

variable "citrix_client_secret" {
  description = "Citrix Cloud API Client Secret"
  type        = string
  sensitive   = true
}

variable "citrix_deliverygroup_name" {
  description = "Name of the existing Citrix Delivery Group"
  type        = string
  default     = "Production-DG"
}

variable "citrix_application_folder" {
  description = "Citrix application folder name"
  type        = string
  default     = "Production"
}

variable "citrix_application_visibility" {
  description = <<-EOT
    List of Active Directory users or groups that can access this application.
    Format: ["DOMAIN\\GroupName", "DOMAIN\\UserName"]
    Example: ["CONTOSO\\Finance-Users", "CONTOSO\\john.doe"]
  EOT
  type        = list(string)
  default     = []
}
