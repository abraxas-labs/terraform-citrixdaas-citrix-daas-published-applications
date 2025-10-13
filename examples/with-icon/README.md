# Example: Custom Application Icon

This example demonstrates how to publish a Citrix application with a custom icon.

## What This Example Does

- Creates a custom application icon from an ICO file
- Publishes Windows Notepad with the custom icon
- Shows how to use the `citrix_application_icon` variable

## Prerequisites

- Terraform >= 1.2
- Citrix Cloud account with DaaS service enabled
- Existing Citrix Delivery Group
- Existing Application Folder
- Citrix Cloud API credentials
- Custom icon file in ICO format (Windows icon format)

## Icon Requirements

The icon file must be:
- **Format**: ICO (Windows Icon)
- **Size**: Recommended 256x256 pixels or smaller
- **Location**: Place in `icons/` subdirectory

## Usage

1. **Prepare your icon file**:
   ```bash
   mkdir -p icons/
   # Copy your .ico file to icons/notepad.ico
   ```

2. **Copy the example tfvars file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit `terraform.tfvars`** with your credentials:
   ```hcl
   citrix_customer_id        = "your-actual-customer-id"
   citrix_client_id          = "your-actual-client-id"
   citrix_client_secret      = "your-actual-client-secret"
   ```

4. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Creating ICO Files

### From PNG/JPG (Linux/macOS)
```bash
# Using ImageMagick
convert source.png -define icon:auto-resize=256,128,64,48,32,16 output.ico
```

### From PNG/JPG (Windows)
Use online converters like:
- https://convertio.co/png-ico/
- https://www.icoconverter.com/

### Extract from EXE
```bash
# Using wrestool (Linux)
wrestool -x --output=. -t14 app.exe
```

## Example Icon Structure

```
examples/with-icon/
├── icons/
│   └── notepad.ico       # Your custom icon
├── main.tf
├── variables.tf
├── terraform.tfvars.example
└── README.md
```

## Clean Up

```bash
terraform destroy
```

## Troubleshooting

### Error: Invalid icon format
```
Error: icon file must be in ICO format
```
**Solution**: Convert your image to ICO format using the methods above.

### Icon doesn't appear in Citrix Workspace
**Solution**:
1. Clear Citrix Workspace cache
2. Wait a few minutes for icon to propagate
3. Re-login to Citrix Workspace

## Next Steps

- See [basic example](../basic/) for simple usage without icons
- See [restricted example](../restricted/) for user/group restrictions<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_notepad"></a> [notepad](#module\_notepad) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [citrix_admin_folder.apps](https://registry.terraform.io/providers/citrix/citrix/latest/docs/data-sources/admin_folder) | data source |
| [citrix_delivery_group.production](https://registry.terraform.io/providers/citrix/citrix/latest/docs/data-sources/delivery_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_citrix_application_folder"></a> [citrix\_application\_folder](#input\_citrix\_application\_folder) | Citrix application folder name | `string` | `"Production"` | no |
| <a name="input_citrix_client_id"></a> [citrix\_client\_id](#input\_citrix\_client\_id) | Citrix Cloud API Client ID | `string` | n/a | yes |
| <a name="input_citrix_client_secret"></a> [citrix\_client\_secret](#input\_citrix\_client\_secret) | Citrix Cloud API Client Secret | `string` | n/a | yes |
| <a name="input_citrix_customer_id"></a> [citrix\_customer\_id](#input\_citrix\_customer\_id) | Citrix Cloud Customer ID | `string` | n/a | yes |
| <a name="input_citrix_deliverygroup_name"></a> [citrix\_deliverygroup\_name](#input\_citrix\_deliverygroup\_name) | Name of the existing Citrix Delivery Group | `string` | `"Production-DG"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_notepad_name"></a> [notepad\_name](#output\_notepad\_name) | The name of the published Notepad application |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
