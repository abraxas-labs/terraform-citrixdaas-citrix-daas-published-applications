# terraform.tf
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
    customer_id   = var.citrix_customer_id      # ← Uses environment variable TF_VAR_customer_id
    client_id     = var.citrix_client_id        # ← Uses environment variable TF_VAR_client_id
    client_secret = var.citrix_client_secret    # ← Uses environment variable TF_VAR_client_secret
  }
}