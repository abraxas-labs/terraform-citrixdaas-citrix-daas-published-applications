module "calculator" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "calculator-app"
  citrix_application_published_name          = "Calculator"
  citrix_application_description             = "Windows Calculator Application"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "notepad" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "notepad-app"
  citrix_application_published_name          = "Notepad"
  citrix_application_description             = "Windows Notepad Text Editor"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\notepad.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "paint" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "paint-app"
  citrix_application_published_name          = "Paint"
  citrix_application_description             = "Windows Paint Application"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\mspaint.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "wordpad" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "wordpad-app"
  citrix_application_published_name          = "WordPad"
  citrix_application_description             = "Windows WordPad Rich Text Editor"
  citrix_application_command_line_executable = "C:\\Program Files\\Windows NT\\Accessories\\wordpad.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "snipping_tool" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "snipping-tool-app"
  citrix_application_published_name          = "Snipping Tool"
  citrix_application_description             = "Windows Snipping Tool Screenshot Utility"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\SnippingTool.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "character_map" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "charmap-app"
  citrix_application_published_name          = "Character Map"
  citrix_application_description             = "Windows Character Map Utility"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\charmap.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "control_panel" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "control-panel-app"
  citrix_application_published_name          = "Control Panel"
  citrix_application_description             = "Windows Control Panel"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\control.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "registry_editor" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "regedit-app"
  citrix_application_published_name          = "Registry Editor"
  citrix_application_description             = "Windows Registry Editor"
  citrix_application_command_line_executable = "C:\\Windows\\regedit.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "task_manager" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "taskmgr-app"
  citrix_application_published_name          = "Task Manager"
  citrix_application_description             = "Windows Task Manager"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\taskmgr.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "command_prompt" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "cmd-app"
  citrix_application_published_name          = "Command Prompt"
  citrix_application_description             = "Windows Command Prompt"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\cmd.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "powershell" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "powershell-app"
  citrix_application_published_name          = "PowerShell"
  citrix_application_description             = "Windows PowerShell"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}

module "file_explorer" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.5.0"

  citrix_application_name                    = "explorer-app"
  citrix_application_published_name          = "File Explorer"
  citrix_application_description             = "Windows File Explorer"
  citrix_application_command_line_executable = "C:\\Windows\\explorer.exe"
  citrix_application_command_line_arguments  = "C:\\Windows\\system32\\"
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
   citrix_deliverygroup_name                  = "YOUR-DELIVERY-GROUP-NAME"
}