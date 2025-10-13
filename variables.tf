# Application Configuration
variable "citrix_application_name" {
  description = <<-EOT
    The internal name of the Citrix application. This name is used for identification
    within Citrix Cloud and must be unique within your environment.
    Example: "microsoft-word-2021" or "calculator-app"
  EOT
  type        = string

  validation {
    condition     = length(var.citrix_application_name) > 0 && length(var.citrix_application_name) <= 64
    error_message = "Application name must be between 1 and 64 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*$", var.citrix_application_name))
    error_message = "Application name must start with a letter or number and contain only letters, numbers, hyphens, and underscores."
  }
}

variable "citrix_application_description" {
  description = <<-EOT
    A detailed description of the application. This is displayed to users in Citrix Workspace.
    Example: "Microsoft Word 2021 - Document editing and creation"
  EOT
  type        = string

  validation {
    condition     = length(var.citrix_application_description) > 0 && length(var.citrix_application_description) <= 512
    error_message = "Application description must be between 1 and 512 characters."
  }
}

variable "citrix_application_published_name" {
  description = <<-EOT
    The display name shown to end users in Citrix Workspace. This can be different
    from the internal application name and can contain spaces and special characters.
    Example: "Microsoft Word 2021" or "Calculator"
  EOT
  type        = string

  validation {
    condition     = length(var.citrix_application_published_name) > 0 && length(var.citrix_application_published_name) <= 128
    error_message = "Published name must be between 1 and 128 characters."
  }
}

variable "citrix_application_command_line_executable" {
  description = <<-EOT
    The full Windows path to the application executable on the VDA (Virtual Delivery Agent).
    Must be a valid Windows path format with backslashes.
    Examples:
      - "C:\\Windows\\system32\\calc.exe"
      - "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
      - "C:\\Program Files (x86)\\Application\\app.exe"
  EOT
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z]:\\\\", var.citrix_application_command_line_executable))
    error_message = "Executable path must be a valid Windows path starting with a drive letter (e.g., C:\\\\path\\\\to\\\\app.exe)."
  }

  validation {
    condition     = can(regex("(?i)\\.exe$", var.citrix_application_command_line_executable))
    error_message = "Executable path must end with .exe or .EXE"
  }
}

variable "citrix_application_command_line_arguments" {
  description = <<-EOT
    Command line arguments passed to the executable when launched. Use empty string if no arguments needed.
    Special patterns supported by Citrix:
      - "" (empty string): No arguments
      - "%%**": Pass user-specified parameters from Citrix Workspace
      - "/c %%**": Command interpreter with user parameters
      - "-file document.docx": Static arguments
    Example: "" or "%%**" or "-openfile"
  EOT
  type        = string
  default     = ""
}

variable "citrix_application_working_directory" {
  description = <<-EOT
    The working directory for the application. Can use Windows environment variables.
    Common values:
      - "%%HOMEDRIVE%%%%HOMEPATH%%" (recommended): User's home directory
      - "%%USERPROFILE%%": User's profile directory
      - "%%USERPROFILE%%\\Documents": User's Documents folder
      - "%%USERPROFILE%%\\Desktop": User's Desktop
      - "C:\\Temp": Fixed location
    Example: "%%HOMEDRIVE%%%%HOMEPATH%%"
  EOT
  type        = string
  default     = "%HOMEDRIVE%%HOMEPATH%"

  validation {
    condition     = length(var.citrix_application_working_directory) > 0
    error_message = "Working directory cannot be empty."
  }
}

# Citrix Infrastructure
variable "citrix_deliverygroup_name" {
  description = <<-EOT
    Name of an existing Citrix Delivery Group that will host this application.
    The delivery group MUST exist before creating the application.

    IMPORTANT BEFORE DEPLOYMENT:
    1. Open Citrix Cloud -> Studio -> Delivery Groups
    2. Copy the EXACT name (case-sensitive!)
    3. Paste it here

    Examples: "Production-Windows-DG", "Test-Delivery-Group"

    Documentation: docs/GETTING_STARTED_FOR_CITRIX_ADMINS.md
  EOT
  type        = string

  validation {
    condition     = length(var.citrix_deliverygroup_name) > 0
    error_message = "Delivery group name cannot be empty. Please copy the exact name from Citrix Studio -> Delivery Groups."
  }
}

variable "citrix_application_folder_path" {
  description = <<-EOT
    Citrix admin folder path where the application will be organized.
    The folder must exist in Citrix Cloud before creating the application.
    Use folder name without leading/trailing slashes.
    Examples:
      - "Production" (single level)
      - "Production/Microsoft Office" (nested)
      - "Test/Utilities" (nested)
  EOT
  type        = string

  validation {
    condition     = length(var.citrix_application_folder_path) > 0
    error_message = "Application folder path cannot be empty."
  }

  validation {
    condition     = !can(regex("^/|/$", var.citrix_application_folder_path))
    error_message = "Application folder path should not start or end with a slash."
  }
}

# Optional Configuration
variable "citrix_application_visibility" {
  description = <<-EOT
    Optional list of Active Directory users or groups that can see this application.
    If empty (default), the application is visible to all users in the delivery group.
    Format: Use domain\\username or domain\\groupname with double backslashes.
    Examples:
      - [] (visible to all users - default)
      - ["CONTOSO\\Finance-Users"] (single AD group)
      - ["CONTOSO\\Finance-Users", "CONTOSO\\john.doe"] (multiple entries)
    Note: Users/groups must exist in Active Directory and be synced to Citrix Cloud.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for user in var.citrix_application_visibility : can(regex("^[^\\\\]+\\\\[^\\\\]+$", user))
    ])
    error_message = "Each entry must be in format 'DOMAIN\\\\username' or 'DOMAIN\\\\groupname' with double backslashes."
  }
}

variable "citrix_application_icon" {
  description = <<-EOT
    Optional: The ID of a citrix_application_icon resource to use as the application icon.
    If not provided (empty string), Citrix will use a default icon.
    Example: citrix_application_icon.my_icon.id
    Note: Create the icon resource separately using citrix_application_icon.
  EOT
  type        = string
  default     = ""
}
