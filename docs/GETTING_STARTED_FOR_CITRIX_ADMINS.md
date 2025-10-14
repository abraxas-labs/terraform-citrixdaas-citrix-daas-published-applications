# Getting Started: Citrix Published Applications with Terraform

> **Complete Guide for Citrix Administrators New to Terraform**
>
> This tutorial is designed for Citrix Administrators who are familiar with Citrix Studio (GUI) but have no prior experience with Terraform or Infrastructure as Code. You'll learn how to automate Citrix Published Application creation using code instead of clicks.
>
> **Already know Terraform?** Skip to the [Quick Start Guide](../README.md#usage) in the main README.

---

## Table of Contents

- [What Is This? (GUI vs. Code Comparison)](#what-is-this-gui-vs-code-comparison)
- [Why Should You Use This?](#why-should-you-use-this)
- [Prerequisites: What You Need Before Starting](#prerequisites-what-you-need-before-starting)
  - [1. Existing Citrix Infrastructure](#1-existing-citrix-infrastructure)
  - [2. Citrix Cloud API Credentials](#2-citrix-cloud-api-credentials)
  - [3. Install Terraform](#3-install-terraform)
- [Getting Started: Your First Published Application](#getting-started-your-first-published-application)
  - [Step 1: Create Your Project Folder](#step-1-create-your-project-folder)
  - [Step 2: Configure Citrix Connection](#step-2-configure-citrix-connection)
  - [Step 3: Field Mapping Reference](#step-3-field-mapping-reference)
  - [Step 4: Set API Credentials](#step-4-set-api-credentials)
  - [Step 5: Deploy Your Application](#step-5-deploy-your-application)
  - [Step 6: Verify in Citrix Cloud](#step-6-verify-in-citrix-cloud)
- [Troubleshooting for Beginners](#troubleshooting-for-beginners)
- [Next Steps: Becoming More Advanced](#next-steps-becoming-more-advanced)
- [FAQ for Citrix Administrators](#faq-for-citrix-administrators)
- [Additional Resources](#additional-resources)

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
1. Write a configuration file describing your application
2. Run `terraform apply`
3. **Time**: ~30 seconds per application (plus, you can deploy 100 apps as easily as 1)

**Result**: Same published application, same user experience—just created with code.

**📖 See detailed step-by-step instructions below**, starting with [Prerequisites](#prerequisites-what-you-need-before-starting).

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
- **Application Folder** (optional) - If you want to organize apps into folders
  - How to check: Citrix Cloud → Studio → Applications → Folders
  - **Note**: Folders are optional! Apps can be created in the root folder without any folder structure
  <!-- SCREENSHOT PLACEHOLDER: Citrix Studio Application Folders -->

> **Note**: This module creates **Published Applications** only. It does NOT create Delivery Groups, Machine Catalogs, or VDAs—those must exist beforehand. Application folders are optional.

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

### 3. Install Terraform

Terraform is the tool that reads your configuration files and creates resources in Citrix Cloud.

**⚡ Quick Start Guide (Most Common Setups):**

| You are a... | Recommended Installation | Jump to Instructions |
|--------------|-------------------------|----------------------|
| Windows Citrix Admin | Manual Installation | [→ Windows Manual](#windows-manual) |
| Windows Developer/DevOps | Chocolatey or WSL2 | [→ Windows Options](#windows-options) |
| macOS User | Homebrew | [→ macOS Homebrew](#macos-homebrew) |
| Linux Admin | wget/apt | [→ Linux](#linux-installation) |

**Not sure which option to choose?** Expand your platform below to see all available installation methods.

---

**Choose your operating system to see installation instructions:**

<details id="windows-options">
<summary><strong>🪟 Windows Users (Click to expand)</strong></summary>

#### Choose Your Installation Method

<details id="windows-manual">
<summary><strong>Option A: Manual Installation (Recommended for Windows Admins)</strong></summary>

**Best for:** Traditional Windows administrators who prefer standard installations.

**Installation Steps:**

1. **Download Terraform:**
   - Go to [HashiCorp Terraform Downloads](https://releases.hashicorp.com/terraform/1.13.3/)
   - Download: `terraform_1.13.3_windows_amd64.zip`

2. **Extract and Install:**
   - Extract the ZIP file to a folder (e.g., `C:\terraform\`)
   - Add the folder to your system PATH:
     - Right-click "This PC" → Properties → Advanced System Settings
     - Click "Environment Variables"
     - Under "System Variables", find "Path" and click "Edit"
     - Click "New" and add the path (e.g., `C:\terraform\`)
     - Click "OK" to save

3. **Verify Installation:**
   ```powershell
   # Open a NEW PowerShell window
   terraform --version
   # Should output: Terraform v1.13.3
   ```

**⚠️ Common Mistakes:**
- **"terraform: command not found"** → You forgot to restart your PowerShell/Command Prompt window! Close and reopen it.
- **"The system cannot find the path specified"** → Check if you added the correct path to the PATH environment variable (e.g., `C:\terraform\`).
- **Permission errors** → Make sure you extracted the file to a folder where you have write permissions.

**Proxy Configuration (if needed):**
If your network requires a proxy server, set these environment variables:
```powershell
# Set proxy (replace x.x.x.x:8080 with your actual proxy)
$env:HTTP_PROXY="http://x.x.x.x:8080"
$env:HTTPS_PROXY="http://x.x.x.x:8080"

# If proxy requires authentication
$env:HTTP_PROXY="http://username:password@x.x.x.x:8080"
$env:HTTPS_PROXY="http://username:password@x.x.x.x:8080"
```

</details>

<details>
<summary><strong>Option B: Chocolatey (Package Manager)</strong></summary>

**Best for:** Windows admins who already use Chocolatey for software management.

**Installation Steps:**

1. **Install with Chocolatey:**
   ```powershell
   # Run in PowerShell (as Administrator)
   choco install terraform
   ```

2. **Verify Installation:**
   ```powershell
   terraform --version
   # Should output: Terraform v1.13.3
   ```

**⚠️ Common Mistakes:**
- **"terraform: command not found"** → Chocolatey installation incomplete. Try closing and reopening PowerShell as Administrator.
- **"choco: command not found"** → Chocolatey is not installed. Install it first from [chocolatey.org/install](https://chocolatey.org/install).

**Proxy Configuration (if needed):**
If your network requires a proxy server, set these environment variables:
```powershell
# Set proxy (replace x.x.x.x:8080 with your actual proxy)
$env:HTTP_PROXY="http://x.x.x.x:8080"
$env:HTTPS_PROXY="http://x.x.x.x:8080"
```

**Additional Resources:**
- [Chocolatey Installation](https://chocolatey.org/install)

</details>

<details>
<summary><strong>Option C: WSL2 (For Advanced Users)</strong></summary>

**Best for:** Developers and power users who need Linux compatibility.

**Why WSL2?**
- Better compatibility with some Terraform tools
- Easier to follow Linux-based documentation
- Works seamlessly with Git and DevOps tools

**Installation Steps:**

1. **Install WSL2:**
   ```powershell
   # Run in PowerShell (as Administrator)
   wsl --install
   # Restart your computer when prompted
   ```
   [Official Microsoft WSL2 Installation Guide](https://docs.microsoft.com/en-us/windows/wsl/install)

2. **Install Terraform in WSL2:**
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

**⚠️ Common Mistakes:**
- **"bash: terraform: command not found"** → The binary is not in your PATH. Did you run `sudo mv terraform /usr/local/bin/`?
- **"Permission denied"** → You forgot to use `sudo` when moving the file. Re-run: `sudo mv terraform /usr/local/bin/`
- **WSL-specific:** If you're in WSL but terraform doesn't work, make sure you installed it inside WSL, not in Windows.

**Proxy Configuration (if needed):**
If your network requires a proxy server, set these environment variables:
```bash
# Set proxy (replace x.x.x.x:8080 with your actual proxy)
export HTTP_PROXY="http://x.x.x.x:8080"
export HTTPS_PROXY="http://x.x.x.x:8080"

# If proxy requires authentication
export HTTP_PROXY="http://username:password@x.x.x.x:8080"
export HTTPS_PROXY="http://username:password@x.x.x.x:8080"
```

</details>

**Additional Resources:**
- [Terraform Installation Guide](https://developer.hashicorp.com/terraform/install)

</details>

<details id="macos-installation">
<summary><strong>🍎 macOS Users (Click to expand)</strong></summary>

#### Choose Your Installation Method

<details id="macos-homebrew">
<summary><strong>Option A: Homebrew (Recommended)</strong></summary>

**Best for:** Most macOS users (industry standard package manager).

**Installation Steps:**

1. **Install Homebrew (if not already installed):**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Terraform:**
   ```bash
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform

   # Verify installation
   terraform --version
   # Should output: Terraform v1.13.3
   ```

**⚠️ Common Mistakes:**
- **"command not found: terraform"** → Homebrew didn't add Terraform to PATH. Try: `brew link hashicorp/tap/terraform`
- **"brew: command not found"** → Homebrew is not installed. Install it first from [brew.sh](https://brew.sh)
- **Apple Silicon users:** Make sure you're using the correct Homebrew version (arm64, not x86_64).

**Proxy Configuration (if needed):**
If your network requires a proxy server, set these environment variables:
```bash
# Set proxy (replace x.x.x.x:8080 with your actual proxy)
export HTTP_PROXY="http://x.x.x.x:8080"
export HTTPS_PROXY="http://x.x.x.x:8080"

# If proxy requires authentication
export HTTP_PROXY="http://username:password@x.x.x.x:8080"
export HTTPS_PROXY="http://username:password@x.x.x.x:8080"
```

</details>

<details>
<summary><strong>Option B: Manual Installation</strong></summary>

**Installation Steps:**

1. **Download Terraform:**
   - Download from [HashiCorp Downloads](https://releases.hashicorp.com/terraform/1.13.3/)
   - Choose: `terraform_1.13.3_darwin_amd64.zip` (Intel) or `terraform_1.13.3_darwin_arm64.zip` (Apple Silicon)

2. **Install:**
   ```bash
   unzip terraform_1.13.3_darwin_*.zip
   sudo mv terraform /usr/local/bin/

   # Verify installation
   terraform --version
   # Should output: Terraform v1.13.3
   ```

**⚠️ Common Mistakes:**
- **"command not found: terraform"** → The binary is not in your PATH. Did you run `sudo mv terraform /usr/local/bin/`?
- **"Permission denied"** → You forgot to use `sudo` when moving the file.
- **Wrong architecture:** Intel Macs need `darwin_amd64.zip`, Apple Silicon needs `darwin_arm64.zip`.

**Proxy Configuration (if needed):**
Same as Option A above.

</details>

**Additional Resources:**
- [HashiCorp Terraform CLI Installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

</details>

<details id="linux-installation">
<summary><strong>🐧 Linux Users (Click to expand)</strong></summary>

**Installation Steps:**

```bash
# Download Terraform 1.13.3
wget https://releases.hashicorp.com/terraform/1.13.3/terraform_1.13.3_linux_amd64.zip

# Unzip and install
unzip terraform_1.13.3_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform --version
# Should output: Terraform v1.13.3
```

**⚠️ Common Mistakes:**
- **"bash: terraform: command not found"** → The binary is not in your PATH. Did you run `sudo mv terraform /usr/local/bin/`?
- **"Permission denied"** → You forgot to use `sudo` when moving the file. Re-run: `sudo mv terraform /usr/local/bin/`
- **"No such file or directory"** → Make sure you downloaded the correct version for your Linux distribution (amd64 for most systems).

**Proxy Configuration (if needed):**
If your network requires a proxy server, set these environment variables:
```bash
# Set proxy (replace x.x.x.x:8080 with your actual proxy)
export HTTP_PROXY="http://x.x.x.x:8080"
export HTTPS_PROXY="http://x.x.x.x:8080"

# If proxy requires authentication
export HTTP_PROXY="http://username:password@x.x.x.x:8080"
export HTTPS_PROXY="http://username:password@x.x.x.x:8080"
```

</details>

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

In this step, you'll create 3 files: `terraform.tf`, `variables.tf`, and `main.tf`.

**How to create files**:
- Open your favorite editor: **Notepad** (Windows), **nano** (Linux/WSL), **vi/vim**, or **VS Code**
- Copy the code blocks below and paste them into the corresponding files
- Save each file in your `my-citrix-apps` directory

---

#### File 1: `terraform.tf`

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
      version = "~> 1.0.13"
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

---

#### File 2: `variables.tf`

**What does this file do?**
Defines the input variables for API credentials (without storing the actual values).

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

---

#### File 3: `main.tf`

**What does this file do?**
This file describes the Published Application you want to create (like filling out the "Create Application" form in Citrix Studio).

**GUI Equivalent**: The "Create Application" wizard in Citrix Studio.

```hcl
# main.tf
module "calculator" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "=0.5.8"

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

  citrix_application_command_line_arguments = "C:\\Windows\\system32\\"
  # ↑ Command line arguments (empty for Calculator)
  # GUI: "Command Line Arguments" field

  citrix_application_working_directory = "%HOMEDRIVE%%HOMEPATH%"
  # ↑ Starting directory (user's home directory)
  # GUI: "Working Directory" field

  # ============================================
  # Citrix Organization
  # ============================================
  # citrix_application_folder_path = "Production"
  # ↑ OPTIONAL: Folder in Citrix Studio where app appears
  # GUI: "Folder" dropdown
  # - If specified: Folder MUST exist in Citrix Cloud
  # - If omitted (or set to null): App will be created in root folder
  # Example: citrix_application_folder_path = null  # creates in root

  citrix_deliverygroup_name = "YOUR-DELIVERY-GROUP-NAME"
  # ↑ ⚠️⚠️⚠️ CRITICAL: You MUST change this value! ⚠️⚠️⚠️
  #
  # BEFORE running terraform plan/apply:
  # 1. Open Citrix Cloud → Studio → Delivery Groups
  # 2. Copy the EXACT name (case-sensitive!) from the list
  # 3. Replace "YOUR-DELIVERY-GROUP-NAME" with that exact name
  #
  # Examples of CORRECT format:
  #   ✅ "Production-DG"
  #   ✅ "Test-Windows-DG"
  #
  # Common mistakes to AVOID:
  #   ❌ Typos: "Production-DG" vs. "Produktion-DG"
  #   ❌ Wrong case: "production-dg" vs. "Production-DG"
  #   ❌ Forgetting to change: "YOUR-DELIVERY-GROUP-NAME"
  #
  # GUI: "Delivery Group" dropdown
  # ⚠️ This Delivery Group MUST exist in Citrix Cloud
}
```

**✅ File Creation Summary**:

You should now have 3 files in your `my-citrix-apps` directory:
```
my-citrix-apps/
├── terraform.tf     (Citrix provider configuration)
├── variables.tf     (Variable definitions)
└── main.tf          (Application definition)
```

**How Terraform reads credentials**:
- Terraform automatically reads environment variables starting with `TF_VAR_`
- You'll set these credentials in **Step 4** before deploying your application
- This keeps credentials secure and out of your code

---

### Step 3: Field Mapping Reference

Here's how Terraform variables map to Citrix Studio fields:

| Citrix Studio Field | Terraform Variable | Example Value |
|---------------------|-------------------|---------------|
| Application Name | `citrix_application_name` | `"calculator-app"` |
| Published Name | `citrix_application_published_name` | `"Calculator"` |
| Description | `citrix_application_description` | `"Windows Calculator"` |
| Application Path | `citrix_application_command_line_executable` | `"C:\\Windows\\system32\\calc.exe"` |
| Command Line Arguments | `citrix_application_command_line_arguments` | `""` |
| Working Directory | `citrix_application_working_directory` | `"%HOMEDRIVE%%HOMEPATH%"` |
| Folder (Optional) | `citrix_application_folder_path` | `"Production"` or `null` (root) |
| Delivery Group | `citrix_deliverygroup_name` | `"Production-DG"` |

---

### Step 4: Set API Credentials

**⚠️ IMPORTANT: Set credentials BEFORE running Terraform commands!**

After creating your API credentials in Citrix Cloud (Prerequisites Step 2), you must store them securely as **environment variables**. Terraform will automatically read these variables when you run `terraform plan` or `terraform apply`.

**Why use environment variables?**
- ✅ Credentials never appear in code or Git history
- ✅ Easy to rotate/update without changing code
- ✅ Different credentials per environment (Dev/Test/Prod)
- ✅ Industry standard security practice

---

**For Linux/WSL Users**:

Open your terminal and set the credentials as environment variables:

```bash
# Set Citrix API credentials as environment variables
export TF_VAR_citrix_customer_id="your-customer-id-here"
export TF_VAR_citrix_client_id="your-client-id-here"
export TF_VAR_citrix_client_secret="your-client-secret-here"

# Verify they're set (optional)
echo $TF_VAR_citrix_customer_id
```

---

**For Windows PowerShell Users**:

Open PowerShell and set the credentials:

```powershell
# Set Citrix API credentials as environment variables
$env:TF_VAR_citrix_customer_id="your-customer-id-here"
$env:TF_VAR_citrix_client_id="your-client-id-here"
$env:TF_VAR_citrix_client_secret="your-client-secret-here"

# Verify they're set (optional)
echo $env:TF_VAR_citrix_customer_id
```

---

**For macOS Users**:

```bash
# Set Citrix API credentials as environment variables (same as Linux)
export TF_VAR_citrix_customer_id="your-customer-id-here"
export TF_VAR_citrix_client_id="your-client-id-here"
export TF_VAR_citrix_client_secret="your-client-secret-here"

# Verify they're set (optional)
echo $TF_VAR_citrix_customer_id
```

---

> **Note**: These environment variables are temporary and only last for the current terminal session. For permanent storage, you can add them to:
> - **Linux/WSL/macOS**: `~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`
> - **Windows**: System Environment Variables (Start → "Environment Variables")

**✅ Credentials are now set!** You can proceed to deploy your application.

---

### Step 4.5: Avoid the #1 Beginner Mistake!

**⚠️ BEFORE running `terraform plan` - Complete this checkpoint!**

The most common error for Terraform beginners is using an incorrect Delivery Group name. Let's prevent this before it happens:

#### Checkpoint: Delivery Group Name Verification

**Follow these steps IN ORDER:**

1. **Open Citrix Cloud in your browser:**
   - Go to [https://citrix.cloud.com](https://citrix.cloud.com)
   - Navigate to: **Studio → Delivery Groups**

<!-- SCREENSHOT PLACEHOLDER: Citrix Studio showing Delivery Groups list with names highlighted -->

2. **Find your Delivery Group:**
   - Look at the list of Delivery Groups
   - Choose the one you want to use for this application
   - **Copy the name EXACTLY** (right-click → Copy, or select and Ctrl+C)

3. **Update your `main.tf` file:**
   - Open `main.tf` in your text editor
   - Find line 391: `citrix_deliverygroup_name = "YOUR-DELIVERY-GROUP-NAME"`
   - **Paste** the exact name you just copied (replace `"YOUR-DELIVERY-GROUP-NAME"`)
   - **Save the file** (Ctrl+S)

4. **Double-check (IMPORTANT!):**
   ```bash
   # View the line to verify it's correct
   grep citrix_deliverygroup_name main.tf

   # Expected output example:
   #   citrix_deliverygroup_name = "Production-Windows-DG"
   ```

#### Common Mistakes to Avoid

| ❌ WRONG | ✅ CORRECT | Why It Fails |
|---------|-----------|--------------|
| `"production-dg"` | `"Production-DG"` | Case mismatch (lowercase vs. uppercase) |
| `"Production-DG "` | `"Production-DG"` | Extra space at the end |
| `"YOUR-DELIVERY-GROUP-NAME"` | `"Production-DG"` | Forgot to replace placeholder |
| `"Prod-DG"` | `"Production-DG"` | Typo/abbreviation doesn't match |

#### What Happens If You Skip This?

You'll see this error when running `terraform plan`:

```
Error: Delivery Group "YOUR-DELIVERY-GROUP-NAME" not found

  with data.citrix_delivery_group.this,
  on main.tf line 17, in data "citrix_delivery_group" "this":
  17: data "citrix_delivery_group" "this" {
```

**To fix:** Come back to this checkpoint and follow the steps above.

---

### Step 5: Deploy Your Application

Now let's deploy the application to Citrix Cloud using the command line.

**Open your terminal/command line** (use the SAME terminal where you set environment variables in Step 4):
- **Windows (WSL)**: Open "Ubuntu" from Start Menu
- **Windows (Native)**: Open "Command Prompt" or "PowerShell"
- **macOS**: Open "Terminal" (Applications → Utilities → Terminal)
- **Linux**: Open your terminal application

**Navigate to your project folder**:
```bash
cd my-citrix-apps
```

**Run the following Terraform commands**:

#### Command 1: Initialize Terraform
```bash
terraform init
```
**What happens?** Terraform downloads the Citrix provider and this module from the Terraform Registry.

**Expected Output**:
```
Initializing modules...
Downloading abraxas-labs/citrix-daas-published-applications/citrixdaas...

Terraform has been successfully initialized!
```

<!-- SCREENSHOT PLACEHOLDER: terraform init output -->

---

#### Command 2: Preview Changes (Dry Run)
```bash
terraform plan
```
**What happens?** Terraform shows you exactly what will be created—like a "preview" or "dry run". **NOTHING is created yet!**

**Expected Output**:
```
Plan: 1 to add, 0 to change, 0 to destroy.
```

**⚠️ Read this output carefully!** It shows you what Terraform will create.

<!-- SCREENSHOT PLACEHOLDER: terraform plan output showing the application to be created -->

---

#### Command 3: Apply Changes (Deploy to Citrix Cloud)
```bash
terraform apply
```
**What happens?** Terraform creates the Published Application in Citrix Cloud.

**Confirmation Required**: Terraform asks: `Do you want to perform these actions?`
- Type **`yes`** and press **Enter**

**⚠️ Important**: Only after you type `yes` will Terraform make changes to Citrix Cloud.

<!-- SCREENSHOT PLACEHOLDER: terraform apply confirmation prompt -->

---

#### Command 4: Destroy Application (Optional)

**⚠️ Use this only if you want to delete the application from Citrix Cloud**

```bash
terraform destroy
```

**What happens?** Terraform deletes the Published Application from Citrix Cloud.

**Confirmation Required**: Terraform asks: `Do you really want to destroy all resources?`
- Type **`yes`** and press **Enter** to confirm deletion
- Type **`no`** or press **Ctrl+C** to cancel

**Expected Output**:
```
Destroy complete! Resources: 1 destroyed.
```

**When to use this**:
- Testing: Clean up test applications after learning
- Mistakes: Remove incorrectly configured applications
- Cleanup: Delete applications you no longer need

**⚠️ Warning**: This permanently deletes the application. Make sure you selected the correct application before confirming!

---

### Step 6: Verify in Citrix Cloud

1. Log into **Citrix Cloud**: [https://citrix.cloud.com](https://citrix.cloud.com)
2. Navigate to: **Studio → Applications → Production** (your folder)
3. ✅ You should see **"Calculator"** in the list

<!-- SCREENSHOT PLACEHOLDER: Citrix Studio showing the newly created Calculator application -->

**Congratulations!** 🎉 You've just created your first Published Application using Terraform.

---

## Troubleshooting for Beginners

### Common Errors and Solutions

| Error Message | What It Means | Solution |
|---------------|---------------|----------|
| `Error: Error reading Delivery Group YOUR-DELIVERY-GROUP-NAME`<br>or<br>`Error: Object does not exist` | **MOST COMMON ERROR #1:** You forgot to replace `"YOUR-DELIVERY-GROUP-NAME"` with your actual Delivery Group name | **Quick fix:**<br>1. Open Citrix Cloud → Studio → Delivery Groups<br>2. Copy the EXACT name from the list<br>3. Open your `main.tf` file<br>4. Find the line with `citrix_deliverygroup_name = "YOUR-DELIVERY-GROUP-NAME"`<br>5. Replace with your copied name: `citrix_deliverygroup_name = "Production-DG"`<br>6. Save and re-run `terraform plan`<br><br>**See Step 4.5 for detailed instructions** |
| `Error: Error reading Delivery Group [YourName]`<br>(with actual name) | **MOST COMMON ERROR #2:** The Delivery Group name has a typo or wrong case | **Step-by-step fix:**<br>1. Check the error message - what name did Terraform try?<br>2. Open Citrix Cloud → Studio → Delivery Groups<br>3. Compare: Is your name EXACTLY the same? (case-sensitive!)<br>4. Copy the correct name from Studio<br>5. Update `citrix_deliverygroup_name` in your module call<br>6. Save and re-run `terraform plan`<br><br>**Example:**<br>❌ WRONG: `"production-dg"` vs. `"Production-DG"`<br>✅ CORRECT: Exact copy from Studio |
| `Error: Invalid API credentials` / `Unknown Citrix API Client Id` | Customer ID, Client ID, or Secret is incorrect or not set | 1. Verify environment variables are set (Step 4)<br>2. Check Citrix Cloud → API Access<br>3. Create new credentials if needed |
| `Error: Application folder path "Production" not found` | The specified folder doesn't exist in Citrix Studio | **Option 1 - Create folder:**<br>1. Open Citrix Studio → Applications<br>2. Create the folder "Production"<br>3. Re-run `terraform apply`<br><br>**Option 2 - Use root folder:**<br>1. Remove the line `citrix_application_folder_path = "Production"`<br>2. Or set it to `null`<br>3. Re-run `terraform apply` |
| `Error: Failed to query provider` | Citrix provider version issue | Run `terraform init -upgrade` |
| `Error: citrix_application_command_line_executable: invalid value` | Executable path has invalid format | Use double backslashes: `C:\\Windows\\system32\\calc.exe` |

<!-- SCREENSHOT PLACEHOLDER: Example error output in terminal with solution highlighted -->

**For detailed troubleshooting**, see [Troubleshooting Guide](TROUBLESHOOTING.md).

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

### 1. Explore Advanced Examples

See real-world scenarios including:
- **Visibility Restrictions**: Limit apps to specific AD groups/users
- **Custom Icons**: Brand applications with company logos
- **Bulk Deployment**: Deploy 10+ applications simultaneously
- **Multi-Environment**: Manage Dev/Test/Prod with workspaces

**👉 [View Advanced Examples](EXAMPLES.md)**

---

### 2. Learn Git Basics (Version Control)
Track your Terraform configurations over time:
- [Git for Beginners](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control)
- Why? Rollback changes, collaborate with team, audit trail

---

### 3. Best Practices for Citrix Admins
- **Naming Conventions**: Use consistent naming (e.g., `app-name-environment`)
- **Folder Structure**: Organize by environment (Dev/Test/Prod) or department
- **Testing**: Always test in a non-production Delivery Group first
- **Documentation**: Comment your code (future you will thank you!)

---

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

### Related Documentation
- **[Main README](../README.md)** — Quick start and module reference
- **[Advanced Examples](EXAMPLES.md)** — Real-world scenarios (visibility, icons, bulk deployment)
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** — Detailed error solutions and debugging

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

This module is licensed under the MIT License. See [LICENSE](../LICENSE) for details.

---

## Feedback

**If this module helped you**, please:
- ⭐ Star this repository (click the star button at the top-right)
- Share with other Citrix Administrators
- Open an issue if you have questions or suggestions
