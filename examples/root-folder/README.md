# Example: Application in Root Folder

This example demonstrates publishing a Citrix application **without** organizing it into a subfolder. The application will be created in the root folder of Citrix Studio Applications.

## Use Cases

- **Simple setups**: When you don't need folder organization
- **Testing**: Quick deployment without creating folders first
- **Legacy migrations**: When moving from flat folder structures
- **Single application**: When you only need to publish one app

## What This Does

Creates a Calculator application in the **root folder** by:
- **Option 1**: Omitting `citrix_application_folder_path` (recommended)
- **Option 2**: Explicitly setting `citrix_application_folder_path = null`

## Prerequisites

- Citrix Cloud account with DaaS service
- Existing Delivery Group
- **NO folder required** (unlike other examples)

## Usage

1. **Set environment variables** for Citrix API credentials:

```bash
export TF_VAR_citrix_customer_id="your-customer-id"
export TF_VAR_citrix_client_id="your-client-id"
export TF_VAR_citrix_client_secret="your-client-secret"
export TF_VAR_citrix_deliverygroup_name="Your-Delivery-Group"
```

2. **Initialize and apply**:

```bash
terraform init
terraform plan
terraform apply
```

## Result

The Calculator application will appear in:
- **Citrix Studio**: Applications → (root level, no subfolder)
- **Citrix Workspace**: Available to users immediately

## Comparison with Other Examples

| Example | Folder Required? | Use Case |
|---------|------------------|----------|
| `root-folder` (this) | ❌ No | Simple/testing scenarios |
| `basic` | ✅ Yes | Organized production deployments |
| `restricted` | ✅ Yes | Apps with visibility restrictions |
| `with-icon` | ✅ Yes | Custom branded applications |

## Notes

- If you later want to move the app to a folder, update `citrix_application_folder_path` and run `terraform apply`
- Applications in the root folder are still fully functional and accessible to users
- This approach reduces prerequisites (no folder creation needed)
