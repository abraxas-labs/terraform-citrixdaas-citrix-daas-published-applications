# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2024-09-30

### Added
- **LICENSE file** (MIT License) for open source compliance
- **Comprehensive input validations** for all variables
  - Application name: 1-64 chars, alphanumeric with hyphens/underscores
  - Description: 1-512 chars
  - Published name: 1-128 chars
  - Executable path: Valid Windows path format, must end with .exe
  - Folder path: No leading/trailing slashes
  - Visibility: Proper DOMAIN\\username format
- **Enhanced variable descriptions** with examples and use cases
- **Additional outputs** for better composability:
  - `application_id`: Unique application identifier
  - `application_published_name`: Display name for users
  - `application_folder_path`: Organization folder path
  - `delivery_group_id`: Delivery group identifier
- **Restructured examples** with three comprehensive scenarios:
  - `examples/basic/`: Minimal configuration example
  - `examples/with-icon/`: Custom application icon example
  - `examples/restricted/`: User/group visibility restrictions example
- **Detailed README files** for each example with troubleshooting guides
- **terraform.tfvars.example** files for easy configuration

### Changed
- **Improved variable structure** with detailed descriptions and validation rules
- **Updated examples/main.tf**:
  - Fixed type mismatch: `citrix_deliverygroup_name` from list(string) to string
  - Updated provider version constraint to `>= 1.0`
  - Fixed hardcoded command line arguments
  - Removed array access for delivery group name

### Fixed
- Type inconsistency in examples between module and consumer
- Hardcoded values in example configuration

## [0.5.8] - 2024-09-30

### Fixed
- **BREAKING CHANGE**: Fixed typo in output name `citrix_published_apllication_name` → `citrix_published_application_name`
- Improved resource naming: `example_delivery_group` → `this` (follows Terraform best practices)
- Removed commented code from main.tf for cleaner codebase

### Added
- CHANGELOG.md file following Keep a Changelog format
- MODULE_ANALYSIS.md with comprehensive best practices analysis
- Provider version constraint `>= 1.0` in versions.tf following Terraform module best practices
  - Uses minimum version constraint to allow root module full control over provider versions
  - Prevents breaking changes from major version updates (2.0+)
  - Current tested version: 1.0.28

### Changed
- Improved project documentation structure
- Enhanced code quality following Terraform best practices

### Migration Guide
If you are using version 0.5.7, you need to update your output references:
```hcl
# Before (v0.5.7)
output "app_name" {
  value = module.my_app.citrix_published_apllication_name
}

# After (v0.5.8)
output "app_name" {
  value = module.my_app.citrix_published_application_name
}
```

## [0.5.7] - 2024-09-21

### Added
- Initial release of Citrix DaaS Published Applications Terraform module
- Support for creating published applications in Citrix Cloud
- Optional application icon support via `citrix_application_icon` variable
- Optional user/group visibility restrictions via `citrix_application_visibility` variable
- Data source for querying existing Citrix Delivery Groups
- Comprehensive example in `examples/` directory
- Pre-commit hooks configuration for code quality
- Automated documentation generation via terraform-docs
- Security scanning with Trivy and Checkov

### Resources
- `citrix_application` resource for published applications
- `citrix_delivery_group` data source for existing delivery groups

### Outputs
- `citrix_published_apllication_name` - Published application name (note: contains typo)
- `delivery_group_name` - Delivery group name

[Unreleased]: https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/compare/0.6.0...HEAD
[0.6.0]: https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/compare/0.5.8...0.6.0
[0.5.8]: https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/compare/0.5.7...0.5.8
[0.5.7]: https://github.com/abraxas-labs/terraform-citrixdaas-citrix-daas-published-applications/releases/tag/0.5.7
