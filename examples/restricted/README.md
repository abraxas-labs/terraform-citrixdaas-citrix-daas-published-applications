# Example: Restricted Application Visibility

This example demonstrates how to restrict application visibility to specific Active Directory users or groups.

## What This Example Does

- Publishes Microsoft Excel to Citrix Cloud
- Restricts visibility to specific AD groups (Finance Team)
- Shows how to use the `citrix_application_visibility` variable

## Prerequisites

- Terraform >= 1.2
- Citrix Cloud account with DaaS service enabled
- Existing Citrix Delivery Group
- Existing Application Folder
- Citrix Cloud API credentials
- Active Directory integration configured in Citrix Cloud
- AD groups or users to restrict access to

## How Visibility Restrictions Work

**Without restrictions** (default):
- Application visible to ALL users in the delivery group

**With restrictions**:
- Application ONLY visible to specified users/groups
- Users must be members of the AD groups specified
- Format: `DOMAIN\\GroupName` or `DOMAIN\\UserName`

## Usage

1. **Identify your AD groups/users**:
   - Go to Active Directory Users and Computers
   - Note the exact names of groups/users (case-sensitive)
   - Note your domain name

2. **Copy the example tfvars file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit `terraform.tfvars`**:
   ```hcl
   citrix_customer_id        = "your-customer-id"
   citrix_client_id          = "your-client-id"
   citrix_client_secret      = "your-client-secret"

   # Restrict to specific groups
   citrix_application_visibility = [
     "YOURDOMAIN\\Finance-Users",
     "YOURDOMAIN\\Accounting-Team"
   ]
   ```

4. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Examples of Visibility Restrictions

### Restrict to a single AD group
```hcl
citrix_application_visibility = [
  "CONTOSO\\Finance-Department"
]
```

### Restrict to multiple AD groups
```hcl
citrix_application_visibility = [
  "CONTOSO\\Finance-Users",
  "CONTOSO\\Accounting-Users",
  "CONTOSO\\Executives"
]
```

### Restrict to specific users
```hcl
citrix_application_visibility = [
  "CONTOSO\\john.doe",
  "CONTOSO\\jane.smith"
]
```

### Mix of groups and users
```hcl
citrix_application_visibility = [
  "CONTOSO\\Finance-Department",
  "CONTOSO\\cfo.user"
]
```

## Verification

After applying, verify in Citrix Cloud Console:

1. Go to **DaaS > Manage > Applications**
2. Find your application
3. Click on the application
4. Check the **Users** tab
5. Should show only the specified groups/users

## Testing Access

**As a restricted user**:
1. Login to Citrix Workspace
2. Application should be visible

**As a non-restricted user**:
1. Login to Citrix Workspace
2. Application should NOT be visible

## Clean Up

```bash
terraform destroy
```

## Troubleshooting

### Error: Group/User not found
```
Error: AD group "DOMAIN\\GroupName" not found
```
**Solution**:
- Verify the exact group/user name in Active Directory
- Check domain name is correct
- Ensure double backslashes in Terraform: `"DOMAIN\\\\GroupName"`

### Application not visible to any users
**Possible causes**:
1. AD group is empty (no members)
2. Group/user name mismatch
3. Domain name incorrect

**Solution**:
```bash
# Check AD group membership
Get-ADGroupMember "Finance-Users"

# Verify domain name
echo $env:USERDOMAIN
```

### Application visible to all users (restriction not working)
**Possible causes**:
1. Empty `citrix_application_visibility` list
2. Citrix Cloud AD integration issue

**Solution**: Verify AD integration in Citrix Cloud Console.

## Next Steps

- See [basic example](../basic/) for simple usage without restrictions
- See [with-icon example](../with-icon/) for custom application icons
- Combine visibility restrictions with custom icons for complete configuration<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| <a name="module_excel"></a> [excel](#module\_excel) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [citrix_admin_folder.apps](https://registry.terraform.io/providers/citrix/citrix/latest/docs/data-sources/admin_folder) | data source |
| [citrix_delivery_group.production](https://registry.terraform.io/providers/citrix/citrix/latest/docs/data-sources/delivery_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_citrix_application_folder"></a> [citrix\_application\_folder](#input\_citrix\_application\_folder) | Citrix application folder name | `string` | `"Production"` | no |
| <a name="input_citrix_application_visibility"></a> [citrix\_application\_visibility](#input\_citrix\_application\_visibility) | List of Active Directory users or groups that can access this application.<br>Format: ["DOMAIN\\GroupName", "DOMAIN\\UserName"]<br>Example: ["CONTOSO\\Finance-Users", "CONTOSO\\john.doe"] | `list(string)` | `[]` | no |
| <a name="input_citrix_client_id"></a> [citrix\_client\_id](#input\_citrix\_client\_id) | Citrix Cloud API Client ID | `string` | n/a | yes |
| <a name="input_citrix_client_secret"></a> [citrix\_client\_secret](#input\_citrix\_client\_secret) | Citrix Cloud API Client Secret | `string` | n/a | yes |
| <a name="input_citrix_customer_id"></a> [citrix\_customer\_id](#input\_citrix\_customer\_id) | Citrix Cloud Customer ID | `string` | n/a | yes |
| <a name="input_citrix_deliverygroup_name"></a> [citrix\_deliverygroup\_name](#input\_citrix\_deliverygroup\_name) | Name of the existing Citrix Delivery Group | `string` | `"Production-DG"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_excel_name"></a> [excel\_name](#output\_excel\_name) | The name of the published Excel application |
| <a name="output_restricted_to"></a> [restricted\_to](#output\_restricted\_to) | Users/groups with access to the application |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
