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

variable "citrix_application_command_line_arguments" {
  description = "cmd arguments"
  type        = string
}

variable "citrix_application_command_line_executable" {
  description = "The command line executable"
  type        = string
}

variable "citrix_application_working_directory" {
  description = "The working directory"
  type        = string
}

variable "citrix_deliverygroup_name" {
  description = "Delivery group"
  type        = string #list(string)
}

variable "citrix_application_visibility" {
  description = "The visibility of the application"
  type        = list(string)
}

variable "citrix_application_folder_path" {
  description = "Citrix Application folder path"
  type        = string
}

variable "citrix_application_icon" {
  description = "Path of Icon"
  type        = string
}
