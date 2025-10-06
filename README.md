# Terraform Module: Citrix Published Applications Made Simple

[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/abraxas-labs/citrix-daas-published-applications/citrixdaas)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> **For Citrix Administrators**: This module automates the creation of Citrix Published Applications using code instead of clicks. Same result as Citrix Studio, but faster, repeatable, and error-free.

---

## What Is This? (GUI vs. Code Comparison)

If you're a Citrix Administrator used to clicking through Citrix Studio, this module does the same thing—but with code.

### The Traditional Way (Citrix Studio):
1. Log into Citrix Cloud
2. Open Citrix Studio
3. Navigate to Applications → Create Application
4. Fill out the form (15-20 clicks):
   - Application Name
   - Published Name
   - Executable Path
   - Working Directory
   - Select Delivery Group
   - Set Folder
   - Configure Visibility (optional)
   - Add Icon (optional)
5. Click "Finish"
6. **Time**: ~5 minutes per application

<!-- SCREENSHOT PLACEHOLDER: Citrix Studio "Create Application" wizard -->

### The Automated Way (This Module):
1. Write a configuration file describing your application (see example below)
2. Run `terraform apply`
3. **Time**: ~30 seconds per application (plus, you can deploy 100 apps as easily as 1)

```hcl
module "calculator" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "calculator-app"
  citrix_application_published_name          = "Calculator"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  citrix_deliverygroup_name                  = "Production-DG"
  citrix_application_folder_path             = "Production"
}
```

**Result**: Same published application, same user experience—just created with code.

---

## Why Should You Use This?

### Time Savings
| Task | Citrix Studio (Manual) | This Module (Automated) |
|------|------------------------|-------------------------|
| 1 Published App | 5 minutes (15-20 clicks) | 30 seconds |
| 10 Published Apps | 50 minutes | 5 minutes |
| 100 Published Apps | 8+ hours | 15 minutes |

### Additional Benefits
- ✅ **No Click Errors**: Configuration is validated before deployment
- ✅ **Repeatable**: Deploy the same app to Dev/Test/Prod environments
- ✅ **Version Control**: Track changes over time (who changed what, when)
- ✅ **Documentation**: Your code IS your documentation
- ✅ **Team Collaboration**: Share configurations, peer review changes
- ✅ **Rollback**: Easily revert to previous configurations

---

## Prerequisites: What You Need Before Starting

### 1. Existing Citrix Infrastructure

You must already have the following in Citrix Cloud:

- ✓ **Citrix Cloud Account** ([Sign up here](https://citrix.cloud.com))
- ✓ **Citrix DaaS Service** enabled
  <!-- SCREENSHOT PLACEHOLDER: Citrix Cloud dashboard showing DaaS enabled -->
- ✓ **At least one Delivery Group** (e.g., "Production-DG")
  - How to check: Citrix Cloud → Studio → Delivery Groups
  <!-- SCREENSHOT PLACEHOLDER: Citrix Studio Delivery Groups list -->
- ✓ **Machine Catalog with VDAs** (Virtual Delivery Agents) assigned to the Delivery Group
  - How to check: Citrix Cloud → Studio → Machine Catalogs
- ✓ **Application Folder** created (e.g., "Production", "Applications")
  - How to check: Citrix Cloud → Studio → Applications → Folders
  <!-- SCREENSHOT PLACEHOLDER: Citrix Studio Application Folders -->

> **Note**: This module creates **Published Applications** only. It does NOT create Delivery Groups, Machine Catalogs, or VDAs—those must exist beforehand.

---

### 2. Citrix Cloud API Credentials

You need API credentials to allow Terraform to connect to Citrix Cloud.

**Step-by-Step: Creating API Credentials**

1. **Log into Citrix Cloud**: [https://citrix.cloud.com](https://citrix.cloud.com)
2. **Navigate to API Access**:
   - Click "Identity and Access Management" (hamburger menu, top-left)
   - Select "API Access"
   <!-- SCREENSHOT PLACEHOLDER: Citrix Cloud → Identity and Access Management → API Access -->
3. **Create Secure Client**:
   - Click "Create Client"
   - Give it a name (e.g., "Terraform Automation")
   - Click "Create"
4. **Save Your Credentials** (⚠️ Important!):
   - **Customer ID**: Copy this (example: `abc123xyz`)
   - **Client ID**: Copy this (example: `12345678-1234-1234-1234-123456789012`)
   - **Client Secret**: Copy this immediately—it's only shown once! (example: `xxxxxxx-xxxxxxx==`)
   <!-- SCREENSHOT PLACEHOLDER: API credentials screen with redacted values highlighted -->

> **⚠️ Security Warning**: The Client Secret is only displayed once. If you lose it, you'll need to create new credentials.

**Detailed Documentation**: [Citrix Cloud API - Getting Started](https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html)

---

**Step 5: Securely Store Credentials (DO NOT commit to Git!)**

After creating your API credentials in Citrix Cloud, store them securely using **environment variables** instead of hardcoding them in files.

**⚠️ Critical Security Practice**: Never store credentials in Git repositories or code files!

**For Linux/WSL Users** (Recommended):

Open your terminal and set the credentials as environment variables:

```bash
# Set Citrix API credentials as environment variables
export TF_VAR_client_id="your-client-id-here"
export TF_VAR_client_secret="your-client-secret-here"
export TF_VAR_customer_id="your-customer-id-here"

# Verify they're set (optional)
echo $TF_VAR_client_id
```

**For Windows PowerShell Users**:

Open PowerShell and set the credentials:

```powershell
# Set Citrix API credentials as environment variables
$env:TF_VAR_client_id="your-client-id-here"
$env:TF_VAR_client_secret="your-client-secret-here"
$env:TF_VAR_customer_id="your-customer-id-here"

# Verify they're set (optional)
echo $env:TF_VAR_client_id
```

> **Note**: These environment variables are temporary and only last for the current terminal session. For permanent storage, you can add them to:
> - **Linux/WSL**: `~/.bashrc` or `~/.zshrc`
> - **Windows**: System Environment Variables (Start → "Environment Variables")

**Why use environment variables?**
- ✅ Credentials never appear in code or Git history
- ✅ Easy to rotate/update without changing code
- ✅ Different credentials per environment (Dev/Test/Prod)
- ✅ Industry standard security practice

---

### 3. Install Terraform

Terraform is the tool that reads your configuration files and creates resources in Citrix Cloud.

**For Windows Users** (Most Citrix Admins):

We **strongly recommend** using **WSL2** (Windows Subsystem for Linux) instead of Windows-native Terraform:
- ✅ Better compatibility with Terraform tools
- ✅ Easier to follow documentation/examples
- ✅ Works seamlessly with Git and other DevOps tools

**Option A: Install WSL2 + Terraform (Recommended)**

1. **Install WSL2**:
   ```powershell
   # Run in PowerShell (as Administrator)
   wsl --install
   # Restart your computer when prompted
   ```
   [Official Microsoft WSL2 Installation Guide](https://docs.microsoft.com/en-us/windows/wsl/install)

2. **Install Terraform in WSL2** (Latest Version: 1.13.3):
   ```bash
   # Open Ubuntu terminal (search "Ubuntu" in Start Menu)

   # Download Terraform 1.13.3
   wget https://releases.hashicorp.com/terraform/1.13.3/terraform_1.13.3_linux_amd64.zip

   # Unzip and install
   unzip terraform_1.13.3_linux_amd64.zip
   sudo mv terraform /usr/local/bin/

   # Verify installation
   terraform --version
   # Should output: Terraform v1.13.3
   ```

**Option B: Windows Native (Alternative)**

Using [Chocolatey](https://chocolatey.org/):
```powershell
# Run in PowerShell (as Administrator)
choco install terraform
```

Or download manually from the official HashiCorp website:
- [Terraform Installation Guide](https://developer.hashicorp.com/terraform/install)
- [Direct Downloads](https://releases.hashicorp.com/terraform/1.13.3/)

---

## Getting Started: Your First Published Application

Let's create your first Citrix Published Application using Terraform. We'll publish the **Windows Calculator** as an example (just like you would in Citrix Studio).

### Step 1: Create Your Project Folder

```bash
# Create a directory for your Citrix automation project
mkdir my-citrix-apps
cd my-citrix-apps
```

---

### Step 2: Configure Citrix Connection

Create a file named `terraform.tf`:

**What does this file do?**
This file establishes the connection to Citrix Cloud (like logging into Citrix Studio).

**GUI Equivalent**: Logging into Citrix Cloud with your credentials.

```hcl
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
```

**Create a file named `variables.tf`:**

```hcl
# variables.tf
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
```

**How it works**:
- Terraform automatically reads environment variables starting with `TF_VAR_`
- You set `export TF_VAR_client_id="..."` (Linux/WSL) or `$env:TF_VAR_client_id="..."` (PowerShell)
- Terraform uses these values without storing them in code

**✅ Security Best Practice**: Credentials are now stored in environment variables (set in Step 5 of Prerequisites), NOT in your code files!

---

### Step 3: Define Your Application

Create a file named `main.tf`:

**What does this file do?**
This file describes the Published Application you want to create (like filling out the "Create Application" form in Citrix Studio).

**GUI Equivalent**: The "Create Application" wizard in Citrix Studio.

```hcl
# main.tf
module "calculator" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  # ============================================
  # Application Identity
  # ============================================
  citrix_application_name           = "calculator-app"
  # ↑ Internal name (not visible to users)
  # GUI: "Application Name" field

  citrix_application_published_name = "Calculator"
  # ↑ Display name users see in Citrix Workspace
  # GUI: "Published Name" field

  citrix_application_description = "Windows Calculator Application"
  # ↑ Description shown to users
  # GUI: "Description" field

  # ============================================
  # Executable Configuration
  # ============================================
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  # ↑ Path to the .exe file on the VDA (Virtual Delivery Agent)
  # GUI: "Application Path" field

  citrix_application_command_line_arguments = ""
  # ↑ Command line arguments (empty for Calculator)
  # GUI: "Command Line Arguments" field

  citrix_application_working_directory = "%HOMEDRIVE%%HOMEPATH%"
  # ↑ Starting directory (user's home directory)
  # GUI: "Working Directory" field

  # ============================================
  # Citrix Organization
  # ============================================
  citrix_application_folder_path = "Production"
  # ↑ Folder in Citrix Studio where app appears
  # GUI: "Folder" dropdown
  # ⚠️ This folder MUST exist in Citrix Cloud before running terraform apply

  citrix_deliverygroup_name = "YOUR-DELIVERY-GROUP-NAME"
  # ↑ Replace with your actual Delivery Group name (e.g., "Production-DG")
  # GUI: "Delivery Group" dropdown
  # ⚠️ This Delivery Group MUST exist in Citrix Cloud
}
```

---

### Step 4: Field Mapping Reference

Here's how Terraform variables map to Citrix Studio fields:

| Citrix Studio Field | Terraform Variable | Example Value |
|---------------------|-------------------|---------------|
| Application Name | `citrix_application_name` | `"calculator-app"` |
| Published Name | `citrix_application_published_name` | `"Calculator"` |
| Description | `citrix_application_description` | `"Windows Calculator"` |
| Application Path | `citrix_application_command_line_executable` | `"C:\\Windows\\system32\\calc.exe"` |
| Command Line Arguments | `citrix_application_command_line_arguments` | `""` |
| Working Directory | `citrix_application_working_directory` | `"%HOMEDRIVE%%HOMEPATH%"` |
| Folder | `citrix_application_folder_path` | `"Production"` |
| Delivery Group | `citrix_deliverygroup_name` | `"Production-DG"` |

---

### Step 5: Deploy Your Application

Now let's create the application in Citrix Cloud.

```bash
# 1. Initialize Terraform (downloads the Citrix module)
terraform init
```
**What happens?** Terraform downloads the Citrix provider and this module from the Terraform Registry.
**Output**: You'll see "Terraform has been successfully initialized!"

```bash
# 2. Preview Changes (NOTHING is created yet!)
terraform plan
```
**What happens?** Terraform shows you exactly what will be created—like a "preview" or "dry run".
**Output**: You'll see something like:
```
Plan: 1 to add, 0 to change, 0 to destroy.
```
**Read this output carefully!** It shows you what Terraform will create.

<!-- SCREENSHOT PLACEHOLDER: terraform plan output showing the application to be created -->

```bash
# 3. Apply Changes (Creates the application in Citrix Cloud)
terraform apply
```
**What happens?** Terraform creates the Published Application in Citrix Cloud.
**Confirmation Required**: Terraform asks: `Do you want to perform these actions?`
- Type `yes` and press Enter

**⚠️ Important**: Only after you type `yes` will Terraform make changes to Citrix Cloud.

<!-- SCREENSHOT PLACEHOLDER: terraform apply confirmation prompt -->

---

### Step 6: Verify in Citrix Cloud

1. Log into **Citrix Cloud**: [https://citrix.cloud.com](https://citrix.cloud.com)
2. Navigate to: **Studio → Applications → Production** (your folder)
3. ✅ You should see **"Calculator"** in the list

<!-- SCREENSHOT PLACEHOLDER: Citrix Studio showing the newly created Calculator application -->

**Congratulations!** 🎉 You've just created your first Published Application using Terraform.

---

## Common Scenarios: Real-World Examples

### Scenario A: Restrict Application Visibility to Specific Users/Groups

**Use Case**: You want to publish Microsoft Excel, but only the Finance team should see it.

**GUI Equivalent**: Application Properties → Limit Visibility → Add Users/Groups

<!-- SCREENSHOT PLACEHOLDER: Citrix Studio "Limit Visibility to Users" dialog -->

**Code**:
```hcl
module "excel_finance" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "excel-finance"
  citrix_application_published_name          = "Microsoft Excel"
  citrix_application_description             = "Excel for Finance Team Only"
  citrix_application_command_line_executable = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"

  # 🔒 Restrict visibility to specific AD groups/users
  citrix_application_visibility = [
    "CONTOSO\\Finance-Users",      # AD Group
    "CONTOSO\\john.doe"            # Individual User
  ]
}
```

**Format Rules**:
- Use `DOMAIN\\Username` or `DOMAIN\\GroupName`
- Double backslash (`\\`) is required
- Users/groups must exist in Active Directory and be synced to Citrix Cloud

---

### Scenario B: Add a Custom Application Icon

**Use Case**: You want to brand your application with a custom icon.

**GUI Equivalent**: Application Properties → Icon → Upload Icon

<!-- SCREENSHOT PLACEHOLDER: Citrix Studio "Change Icon" dialog -->

**Prerequisites**:
- You have a `.ico` file (e.g., `app-icon.ico`)
- Place the icon in your project folder

**Code**:
```hcl
# Step 1: Create the icon resource
resource "citrix_application_icon" "custom_icon" {
  raw_data = filebase64("${path.module}/icons/app-icon.ico")
  # ↑ Reads the .ico file and converts it to base64
}

# Step 2: Reference the icon in your application
module "notepad_custom_icon" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "notepad-app"
  citrix_application_published_name          = "Notepad"
  citrix_application_description             = "Text Editor with Custom Icon"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\notepad.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"

  # 🎨 Use the custom icon
  citrix_application_icon = citrix_application_icon.custom_icon.id
}
```

**Project Structure**:
```
my-citrix-apps/
├── terraform.tf
├── main.tf
└── icons/
    └── app-icon.ico    ← Your custom icon file
```

---

### Scenario C: Deploy 10 Applications at Once

**Use Case**: You need to publish 10 different applications (Word, Excel, PowerPoint, etc.)

**GUI**: Fill out the "Create Application" form 10 times (~50 minutes)

**Code**: Copy-paste the module block 10 times, change the values (~5 minutes)

**Example** (`main.tf`):
```hcl
# Application 1: Calculator
module "calculator" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "calculator"
  citrix_application_published_name          = "Calculator"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\calc.exe"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"
}

# Application 2: Notepad
module "notepad" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "notepad"
  citrix_application_published_name          = "Notepad"
  citrix_application_command_line_executable = "C:\\Windows\\system32\\notepad.exe"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"
}

# Application 3: Microsoft Word
module "word" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "~> 0.6"

  citrix_application_name                    = "word"
  citrix_application_published_name          = "Microsoft Word"
  citrix_application_command_line_executable = "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
  citrix_application_folder_path             = "Production"
  citrix_deliverygroup_name                  = "Production-DG"
}

# ... repeat for Excel, PowerPoint, etc.
```

**Result**: Run `terraform apply` once → all 10 applications created simultaneously.

---

## Securing Your Credentials

**⚠️ Never commit API credentials to Git or share them publicly!**

### Method 1: Environment Variables (Recommended)

**Step 1**: Remove credentials from `terraform.tf`:
```hcl
# terraform.tf
provider "citrix" {
  cvad_config = {
    customer_id   = var.citrix_customer_id
    client_id     = var.citrix_client_id
    client_secret = var.citrix_client_secret
  }
}
```

**Step 2**: Create `variables.tf`:
```hcl
# variables.tf
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
```

**Step 3**: Create `terraform.tfvars` (local file, NOT committed to Git):
```hcl
# terraform.tfvars
citrix_customer_id   = "your-customer-id"
citrix_client_id     = "your-client-id"
citrix_client_secret = "your-client-secret"
```

**Step 4**: Add to `.gitignore`:
```
# .gitignore
*.tfvars
.terraform/
terraform.tfstate*
```

---

## Troubleshooting for Beginners

### Common Errors and Solutions

| Error Message | What It Means | Solution |
|---------------|---------------|----------|
| `Error: Delivery Group "Production-DG" not found` | The Delivery Group doesn't exist in Citrix Cloud | 1. Log into Citrix Studio<br>2. Check Delivery Groups list<br>3. Update `citrix_deliverygroup_name` with the correct name |
| `Error: Invalid API credentials` | Customer ID, Client ID, or Secret is incorrect | 1. Go to Citrix Cloud → API Access<br>2. Create new credentials<br>3. Update `terraform.tf` |
| `Error: Application folder path "Production" not found` | The folder doesn't exist in Citrix Studio | 1. Open Citrix Studio → Applications<br>2. Create the folder "Production"<br>3. Re-run `terraform apply` |
| `Error: Failed to query provider` | Citrix provider version issue | Run `terraform init -upgrade` |
| `Error: citrix_application_command_line_executable: invalid value` | Executable path has invalid format | Use double backslashes: `C:\\Windows\\system32\\calc.exe` |

<!-- SCREENSHOT PLACEHOLDER: Example error output in terminal with solution highlighted -->

---

### Validation Workflow (Before Deploying)

Always run these commands in order:

```bash
# 1. Format your code (fixes indentation/spacing)
terraform fmt

# 2. Validate syntax (checks for errors)
terraform validate

# 3. Preview changes (see what will be created)
terraform plan

# 4. Only then: Apply changes
terraform apply
```

---

## Next Steps: Becoming More Advanced

### 1. Learn Git Basics (Version Control)
Track your Terraform configurations over time:
- [Git for Beginners](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control)
- Why? Rollback changes, collaborate with team, audit trail

### 2. Explore the Examples Folder
See more complex scenarios:
- [examples/](examples/) directory in this repository
- Each example includes detailed comments

### 3. Best Practices for Citrix Admins
- **Naming Conventions**: Use consistent naming (e.g., `app-name-environment`)
- **Folder Structure**: Organize by environment (Dev/Test/Prod) or department
- **Testing**: Always test in a non-production Delivery Group first
- **Documentation**: Comment your code (future you will thank you!)

### 4. Advanced Terraform Concepts (Optional)
- **Workspaces**: Manage multiple environments (Dev/Test/Prod)
- **Modules**: Create reusable configurations for your organization
- **Remote State**: Store Terraform state in Azure Storage or AWS S3

---

## FAQ for Citrix Administrators

### Q: Does this replace Citrix Studio?
**A**: No. Citrix Studio is still essential for:
- Monitoring sessions
- Troubleshooting user issues
- Viewing real-time performance
- Managing VDAs and Machine Catalogs

This module automates **application creation/management only**—it doesn't replace Studio.

---

### Q: Can I manage existing applications created in Studio?
**A**: Yes, but you need to **import** them into Terraform first:
```bash
terraform import module.calculator.citrix_application.published_application <application-id>
```
[Terraform Import Documentation](https://www.terraform.io/docs/cli/import/index.html)

---

### Q: What happens if I change an app in Studio after creating it with Terraform?
**A**: Terraform detects "drift" (differences between your code and reality).
When you run `terraform plan`, it shows:
- What you have in Studio (actual state)
- What your code defines (desired state)
- What changes Terraform will make to reconcile them

**Best Practice**: Make all changes in Terraform code, not in Studio (to avoid drift).

---

### Q: Can I delete applications with Terraform?
**A**: Yes. Remove the `module` block from `main.tf`, then run:
```bash
terraform apply
```
Terraform will ask: `Do you want to destroy these resources?`

---

### Q: What if I make a mistake in my code?
**A**:
1. **Before `terraform apply`**: Just fix the code and re-run `terraform plan`
2. **After `terraform apply`**: Fix the code and run `terraform apply` again (Terraform updates the resource)
3. **Worst case**: Delete the application in Studio, fix the code, re-apply

---

### Q: Is this safe to use in production?
**A**: Yes, if you follow the validation workflow:
1. Always run `terraform plan` first
2. Review the output carefully
3. Test in a non-production environment first
4. Use version control (Git) to track changes

---

### Q: Do I need to be a developer to use this?
**A**: No! If you can:
- Fill out forms in Citrix Studio
- Copy/paste text
- Follow step-by-step instructions

...you can use this module. The examples are designed for Citrix Admins, not developers.

---

### Q: Where can I get help?
**A**:
- **Issues/Bugs**: [GitHub Issues](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/issues)
- **Questions**: Open a [GitHub Discussion](https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/discussions)
- **Citrix Provider Docs**: [Terraform Citrix Provider](https://registry.terraform.io/providers/citrix/citrix/latest/docs)

---

## Additional Resources

### For Citrix Administrators New to Terraform
- [Terraform Tutorial for Beginners](https://learn.hashicorp.com/collections/terraform/aws-get-started)
- [Infrastructure as Code Explained](https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac)

### Citrix-Specific Documentation
- [Citrix Cloud API Documentation](https://developer-docs.citrix.com/)
- [Citrix Terraform Provider](https://registry.terraform.io/providers/citrix/citrix/latest/docs)

### Example Configurations
- See [examples/](examples/) for complete working examples:
  - Basic application deployment
  - Applications with custom icons
  - Applications with visibility restrictions

---

## Contributing

Contributions are welcome! If you're a Citrix Admin who found this module useful (or confusing), please:
- Open an issue with feedback
- Suggest improvements to documentation
- Share your use cases/examples

**Contributors**:
- @cedfont
- @abraxas-citrix-bot

---

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Feedback

**If this module helped you**, please:
- ⭐ Star this repository (click the star button at the top-right)
- Share with other Citrix Administrators
- Open an issue if you have questions or suggestions

---

# Technical Reference (Auto-Generated)

> **Note**: The section below is auto-generated documentation for advanced users. If you're new to Terraform, you can safely skip this section.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_citrix"></a> [citrix](#requirement\_citrix) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_citrix"></a> [citrix](#provider\_citrix) | 1.0.28 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [citrix_application.published_application](https://registry.terraform.io/providers/citrix/citrix/latest/docs/resources/application) | resource |
| [citrix_delivery_group.this](https://registry.terraform.io/providers/citrix/citrix/latest/docs/data-sources/delivery_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_citrix_application_command_line_arguments"></a> [citrix\_application\_command\_line\_arguments](#input\_citrix\_application\_command\_line\_arguments) | Command line arguments passed to the executable when launched. Use empty string if no arguments needed.<br>Special patterns supported by Citrix:<br>  - "" (empty string): No arguments<br>  - "%%**": Pass user-specified parameters from Citrix Workspace<br>  - "/c %%**": Command interpreter with user parameters<br>  - "-file document.docx": Static arguments<br>Example: "" or "%%**" or "-openfile" | `string` | `""` | no |
| <a name="input_citrix_application_command_line_executable"></a> [citrix\_application\_command\_line\_executable](#input\_citrix\_application\_command\_line\_executable) | The full Windows path to the application executable on the VDA (Virtual Delivery Agent).<br>Must be a valid Windows path format with backslashes.<br>Examples:<br>  - "C:\\Windows\\system32\\calc.exe"<br>  - "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"<br>  - "C:\\Program Files (x86)\\Application\\app.exe" | `string` | n/a | yes |
| <a name="input_citrix_application_description"></a> [citrix\_application\_description](#input\_citrix\_application\_description) | A detailed description of the application. This is displayed to users in Citrix Workspace.<br>Example: "Microsoft Word 2021 - Document editing and creation" | `string` | n/a | yes |
| <a name="input_citrix_application_folder_path"></a> [citrix\_application\_folder\_path](#input\_citrix\_application\_folder\_path) | Citrix admin folder path where the application will be organized.<br>The folder must exist in Citrix Cloud before creating the application.<br>Use folder name without leading/trailing slashes.<br>Examples:<br>  - "Production" (single level)<br>  - "Production/Microsoft Office" (nested)<br>  - "Test/Utilities" (nested) | `string` | n/a | yes |
| <a name="input_citrix_application_icon"></a> [citrix\_application\_icon](#input\_citrix\_application\_icon) | Optional: The ID of a citrix\_application\_icon resource to use as the application icon.<br>If not provided (empty string), Citrix will use a default icon.<br>Example: citrix\_application\_icon.my\_icon.id<br>Note: Create the icon resource separately using citrix\_application\_icon. | `string` | `""` | no |
| <a name="input_citrix_application_name"></a> [citrix\_application\_name](#input\_citrix\_application\_name) | The internal name of the Citrix application. This name is used for identification<br>within Citrix Cloud and must be unique within your environment.<br>Example: "microsoft-word-2021" or "calculator-app" | `string` | n/a | yes |
| <a name="input_citrix_application_published_name"></a> [citrix\_application\_published\_name](#input\_citrix\_application\_published\_name) | The display name shown to end users in Citrix Workspace. This can be different<br>from the internal application name and can contain spaces and special characters.<br>Example: "Microsoft Word 2021" or "Calculator" | `string` | n/a | yes |
| <a name="input_citrix_application_visibility"></a> [citrix\_application\_visibility](#input\_citrix\_application\_visibility) | Optional list of Active Directory users or groups that can see this application.<br>If empty (default), the application is visible to all users in the delivery group.<br>Format: Use domain\\username or domain\\groupname with double backslashes.<br>Examples:<br>  - [] (visible to all users - default)<br>  - ["CONTOSO\\Finance-Users"] (single AD group)<br>  - ["CONTOSO\\Finance-Users", "CONTOSO\\john.doe"] (multiple entries)<br>Note: Users/groups must exist in Active Directory and be synced to Citrix Cloud. | `list(string)` | `[]` | no |
| <a name="input_citrix_application_working_directory"></a> [citrix\_application\_working\_directory](#input\_citrix\_application\_working\_directory) | The working directory for the application. Can use Windows environment variables.<br>Common values:<br>  - "%%HOMEDRIVE%%%%HOMEPATH%%" (recommended): User's home directory<br>  - "%%USERPROFILE%%": User's profile directory<br>  - "%%USERPROFILE%%\\Documents": User's Documents folder<br>  - "%%USERPROFILE%%\\Desktop": User's Desktop<br>  - "C:\\Temp": Fixed location<br>Example: "%%HOMEDRIVE%%%%HOMEPATH%%" | `string` | `"%HOMEDRIVE%%HOMEPATH%"` | no |
| <a name="input_citrix_deliverygroup_name"></a> [citrix\_deliverygroup\_name](#input\_citrix\_deliverygroup\_name) | Name of an existing Citrix Delivery Group that will host this application.<br>The delivery group must exist before creating the application.<br>Example: "Production-Windows-DG" or "Test-Delivery-Group" | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_folder_path"></a> [application\_folder\_path](#output\_application\_folder\_path) | The folder path where the application is organized in Citrix Cloud |
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The unique identifier of the published application |
| <a name="output_application_published_name"></a> [application\_published\_name](#output\_application\_published\_name) | The display name shown to end users in Citrix Workspace |
| <a name="output_citrix_published_application_name"></a> [citrix\_published\_application\_name](#output\_citrix\_published\_application\_name) | The internal name of the published Citrix application |
| <a name="output_delivery_group_id"></a> [delivery\_group\_id](#output\_delivery\_group\_id) | The unique identifier of the delivery group |
| <a name="output_delivery_group_name"></a> [delivery\_group\_name](#output\_delivery\_group\_name) | The name of the delivery group hosting the application |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
