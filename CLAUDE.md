# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ CRITICAL TERRAFORM SAFETY RULES

**BEFORE ANY OPERATIONS:**
1. **ALWAYS run `terraform plan` first** - NEVER apply without reviewing
2. **Multi-File Awareness**: Changes to one `.tf` file affect other resources
3. **State File Protection**: NEVER manually edit `.tfstate` files
4. **Resource Dependencies**: Understand dependencies before changes
5. **Provider Versions**: Test provider upgrades in non-production first

**MANDATORY WORKFLOW:**
1. **READ** → Always read existing files before changes
2. **VALIDATE** → Run validation sequence before modifications
3. **PLAN** → Review terraform plan output thoroughly
4. **APPLY** → Only after plan approval

**Validation Sequence:**
```bash
terraform fmt -check -recursive    # Format check
terraform validate                 # Syntax validation
tflint                            # Linting
terraform plan                    # Plan review
```

## Project Overview

**Type**: Terraform Module for Citrix Published Applications
**Purpose**: Simplify deployment of Citrix Published Applications via IaC
**Status**: Published module (abraxas-labs/citrix-daas-published-applications)
**Version**: 0.5.7

This is a **reusable Terraform module** that creates and manages Citrix Published Applications. It is NOT a standalone infrastructure deployment but a module consumed by other Terraform configurations.

## Repository Architecture

### Core Files
- `main.tf` - Module resources (citrix_application, data sources)
- `variables.tf` - Module input variables (11 variables)
- `outputs.tf` - Module outputs (application name, delivery group)
- `versions.tf` - Provider version constraints (terraform >= 1.2, citrix provider)
- `examples/` - Usage examples with sample configurations

### Module Structure
```
.
├── main.tf                    # citrix_application resource + data source
├── variables.tf               # Input variables for module
├── outputs.tf                 # Output values
├── versions.tf                # Provider requirements
├── examples/
│   ├── main.tf               # Complete example implementation
│   └── customer.tfvars       # Sample variable values
└── .pre-commit-config.yaml   # Quality gates
```

## Development Commands

**Module Development Workflow:**
```bash
# Format and validate
terraform fmt -recursive
terraform validate

# Run pre-commit hooks (comprehensive validation)
pre-commit run --all-files

# Test module in examples/
cd examples/
terraform init
terraform plan -var-file="customer.tfvars"
```

**Pre-commit Quality Gates:**
- `terraform_fmt` - Auto-format code
- `terraform_validate` - Syntax validation
- `terraform_docs` - Auto-generate module documentation in README.md
- `terraform_tflint` - 15+ linting rules
- `terraform_trivy` - Security scanning
- `terraform_checkov` - Security policy checks
- `conventional-pre-commit` - Commit message validation

## Module Usage Pattern

**Consumers of this module should:**
```hcl
module "citrix-daas-published-applications" {
  source  = "abraxas-labs/citrix-daas-published-applications/citrixdaas"
  version = "0.5.7"

  # Required inputs
  citrix_application_name                    = "MyApp"
  citrix_application_description             = "Description"
  citrix_application_published_name          = "PublishedName"
  citrix_application_command_line_executable = "C:\\path\\app.exe"
  citrix_application_command_line_arguments  = ""
  citrix_application_working_directory       = "%HOMEDRIVE%%HOMEPATH%"
  citrix_application_folder_path             = "path/to/folder"
  citrix_deliverygroup_name                  = "DG-Name"

  # Optional
  citrix_application_visibility              = ["domain\\GroupName"]
  citrix_application_icon                    = citrix_application_icon.example.id
}
```

## Key Module Functionality

**What this module does:**
1. Creates a `citrix_application` resource with published application settings
2. Queries existing Citrix Delivery Group via data source
3. Configures application visibility (optional user/group restrictions)
4. Assigns application icon (optional)

**What this module does NOT do:**
- Create Delivery Groups (must exist)
- Create Machine Catalogs
- Manage Azure infrastructure
- Create Application Folders (must be created separately)

## User Preferences (dima@lejkin.de)

### Communication & Code Style
- **Language**: German for communication, English for code/comments
- **Response Style**: Direct, concise - no lengthy explanations unless requested
- **AI-Tools**: Claude Code + GitHub Copilot

### Development Workflow
1. **Planning First**: Detailed plans before implementation
2. **Todo Management**: TodoWrite/TodoRead for complex tasks
3. **Modular Implementation**: Break tasks into manageable steps
4. **Testing**: Always validate with `terraform plan`
5. **Documentation**: Keep README.md current (auto-generated via terraform_docs)

### Git Preferences
- **Commit Style**: Concise, descriptive German messages (conventional format)
- **No AI Branding**: Do NOT include "Generated with Claude Code" or Co-Authored-By
- **Tagging**: Semantic versioning for releases
- **Branch Strategy**: Feature branches, never direct on main

### Code Standards
- Run `terraform validate` and `terraform fmt` before commits
- Descriptive variable naming
- Pre-commit hooks must pass before commits

## Claude Code Integration

**Available Commands (29 ultra-focused):**

**Terraform Core (10):**
- `/tf-validate` - Comprehensive validation workflow
- `/tf-deploy` - Safe deployment with confirmations
- `/tf-destroy` - Controlled destruction
- `/tf-pre-commit` - Git integration & quality gates
- `/tf-security-scan` - Security & compliance
- `/tf-docs` - Documentation generation
- `/tf-generate` - Code generation
- `/tf-modules` - Module management
- `/tf-research` - Terraform research
- `/tf-gen-resource` - Resource generation

**GitLab Integration (6):**
- `/gitlab-workflow`, `/gitlab-mr`, `/gitlab-commit`, `/gitlab-issue`, `/gitlab-repo`, `/gitlab-sync`

**Task Management (5):**
- `/task-create`, `/task-update`, `/task-list`, `/task-show`, `/task-search`

**AI Research (3):**
- `/per-research`, `/per-ask`, `/per-reason`

**DevOps Automation (5):**
- `/plan`, `/think`, `/changelog`, `/gitops-sync`, `/pipeline-optimize`

## Security Guidelines

**Module Security:**
- No hardcoded secrets in variables
- Use `sensitive = true` for sensitive variables (e.g., client_secret)
- Security scanning via Trivy/Checkov in pre-commit
- Application visibility restrictions via AD groups

## Quality Assurance

**Pre-commit Enforcement:**
- Code formatting (terraform_fmt)
- Syntax validation (terraform_validate)
- Documentation updates (terraform_docs - auto-updates README.md)
- Linting (15+ tflint rules)
- Security scanning (trivy + checkov)
- Conventional commit messages
- No commits to main/master branches
- Private key detection

## Important Instructions

Do what has been asked; nothing more, nothing less.
NEVER create files unless absolutely necessary.
ALWAYS prefer editing existing files to creating new ones.
NEVER proactively create documentation files (*.md) unless explicitly requested - terraform_docs maintains README.md automatically.
