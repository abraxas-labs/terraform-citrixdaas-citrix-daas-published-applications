# examples

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_citrix-daas-published-applications"></a> [citrix-daas-published-applications](#module\_citrix-daas-published-applications) | abraxas-labs/citrix-daas-published-applications/citrixdaas | 0.5.7 |

## Resources

| Name | Type |
|------|------|
| [citrix_admin_folder.example_admin_folder_1](https://registry.terraform.io/providers/citrix/citrix/latest/docs/resources/admin_folder) | resource |
| [citrix_application_icon.example_application_icon](https://registry.terraform.io/providers/citrix/citrix/latest/docs/resources/application_icon) | resource |
| [citrix_delivery_group.example_delivery_group](https://registry.terraform.io/providers/citrix/citrix/latest/docs/data-sources/delivery_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_citrix_application_command_line_executable"></a> [citrix\_application\_command\_line\_executable](#input\_citrix\_application\_command\_line\_executable) | The command line executable | `string` | n/a | yes |
| <a name="input_citrix_application_description"></a> [citrix\_application\_description](#input\_citrix\_application\_description) | Application Description | `string` | n/a | yes |
| <a name="input_citrix_application_name"></a> [citrix\_application\_name](#input\_citrix\_application\_name) | The name of the application | `string` | n/a | yes |
| <a name="input_citrix_application_published_name"></a> [citrix\_application\_published\_name](#input\_citrix\_application\_published\_name) | The name of the application | `string` | n/a | yes |
| <a name="input_citrix_application_visibility"></a> [citrix\_application\_visibility](#input\_citrix\_application\_visibility) | Please enter Users or group . Example: ["domain\\UserOrGroupName"]<br>By default, the application is visible to all users within a delivery group. However, you can restrict its visibility to only certain users by specifying them in the limit\_visibility\_to\_users list. | `list(string)` | `[]` | no |
| <a name="input_citrix_deliverygroup_name"></a> [citrix\_deliverygroup\_name](#input\_citrix\_deliverygroup\_name) | Please enter the Name of the delivery group. Example: "DG-A-Test" | `string` | n/a | yes |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Please enter the The Citrix Cloud Client id. Example: 12345678-1234-1234-1234-123456789012<br>Link https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Please enter the The Citrix Cloud Client secret. Example: xxxxxxx-xxxxxxx==<br>Link https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html | `string` | n/a | yes |
| <a name="input_customer_id"></a> [customer\_id](#input\_customer\_id) | Please enter The Citrix Cloud customer id. Example: xxxxxxxx<br>Link https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html | `string` | n/a | yes |
| <a name="input_icon_path"></a> [icon\_path](#input\_icon\_path) | Please enter the Path to the icon | `string` | `"/icons/citrix.ico"` | no |
| <a name="input_mandant_prefix"></a> [mandant\_prefix](#input\_mandant\_prefix) | please enter the Customer name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
