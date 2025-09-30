# Basic Example

This example demonstrates the minimal configuration required to publish a Citrix application using this module.

## What This Example Does

- Publishes the Windows Calculator application to Citrix Cloud
- Uses an existing Delivery Group and Application Folder
- Demonstrates the simplest possible module usage

## Prerequisites

- Terraform >= 1.2
- Citrix Cloud account with DaaS service enabled
- Existing Citrix Delivery Group (e.g., "Production-DG")
- Existing Application Folder (e.g., "Production")
- Citrix Cloud API credentials (Customer ID, Client ID, Client Secret)

## Usage

1. **Copy the example tfvars file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your Citrix Cloud credentials:
   ```hcl
   citrix_customer_id        = "your-actual-customer-id"
   citrix_client_id          = "your-actual-client-id"
   citrix_client_secret      = "your-actual-client-secret"
   citrix_deliverygroup_name = "Your-Delivery-Group-Name"
   citrix_application_folder = "Your-Folder-Name"
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Verify in Citrix Cloud Console**:
   - Navigate to **DaaS > Manage > Applications**
   - You should see "Calculator" application published

## Clean Up

To remove the published application:

```bash
terraform destroy
```

## Expected Output

```
calculator_name = "calculator-app"
delivery_group  = "Production-DG"
```

## Troubleshooting

### Error: Delivery Group not found
```
Error: data.citrix_delivery_group.production: delivery group "Production-DG" not found
```
**Solution**: Verify the delivery group name matches exactly in Citrix Cloud Console.

### Error: Application Folder not found
```
Error: data.citrix_admin_folder.apps: folder "Production" not found
```
**Solution**: Create the folder in Citrix Cloud Console or use an existing folder name.

## Next Steps

- See [with-icon example](../with-icon/) to add custom application icons
- See [restricted example](../restricted/) to restrict application visibility to specific users/groups<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| <a name="module_calculator"></a> [calculator](#module\_calculator) | ../.. | n/a |

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
| <a name="output_calculator_name"></a> [calculator\_name](#output\_calculator\_name) | The name of the published Calculator application |
| <a name="output_delivery_group"></a> [delivery\_group](#output\_delivery\_group) | The delivery group hosting the application |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
