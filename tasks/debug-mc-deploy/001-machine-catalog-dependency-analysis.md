# 001: Machine Catalog Dependency Analysis

**Status**: completed
**Created**: 2025-09-27
**Priority**: high

## Description

Analysis der Machine Catalog Deployment-Probleme mit `citrix-machine-catalogs.tf`. Das Problem liegt in der komplexen Dependency-Kette zwischen Service Account, Domain-Konfiguration und Machine Catalog.

## Root Cause Analysis

### Problem-Zusammenfassung
```
Error: Missing Attribute Configuration
│
│   with module.citrix_machine_catalog_hsd_test[0].citrix_machine_catalog.hsd,
│   on modules/citrix-machine-catalog-hsd/main.tf line 2, in resource "citrix_machine_catalog" "hsd":
│    2: resource "citrix_machine_catalog" "hsd" {
│
│ Expected domain to be configured when identity_type is Active Directory.
```

### Dependency-Kette

1. **Machine Catalog** (`citrix-machine-catalogs.tf:7-55`)
   - Benötigt: `domain_name` (local.domain_name)
   - Benötigt: `service_account_id` (citrix_service_account.sc_for_machine_id_domain.id)
   - Hat explizite `depends_on`: `citrix_service_account.sc_for_machine_id_domain`

2. **Service Account** (`main.tf:39-46`)
   - Erstellt: `citrix_service_account.sc_for_machine_id_domain`
   - Benötigt: `identity_provider_identifier = local.domain_name`
   - Benötigt: GitLab-Variable für Windows-Password

3. **Domain-Konfiguration** (`locals.tf:34`)
   - Definiert: `domain_name = "m${var.mvd_mandant}.abxcloud.ch"`
   - Benötigt: `var.mvd_mandant` Variable

### Identifizierte Ursache

**Das Problem liegt im Machine Catalog Modul**: `modules/citrix-machine-catalog-hsd/main.tf`

```hcl
# Zeile 16: identity_type wird gesetzt
identity_type = var.identity_type

# Zeile 79-88: Machine Domain Identity Konfiguration
machine_domain_identity = var.service_account_id != null ? {
  domain             = var.domain_name  # ← HIER liegt das Problem!
  domain_ou          = var.hsd_domain_ou
  service_account_id = var.service_account_id
} : {
  domain                   = var.domain_name
  domain_ou                = var.hsd_domain_ou
  service_account          = var.service_account
  service_account_password = var.service_account_password
}
```

**Root Cause**: Wenn `identity_type = "ActiveDirectory"` (default), muss das `domain` Feld in `machine_domain_identity` konfiguriert sein, aber Terraform kann nicht validieren, dass alle Dependencies verfügbar sind bei einem "kalten Start".

## Action Items

- [x] Analyze dependency chain from main.tf → locals.tf → machine-catalog
- [x] Identify missing domain configuration validation
- [x] Review module variable passing

## Notes

**Warum funktioniert es nach dem ersten Deployment?**
- Nach erstem Deployment existiert der Service Account im Terraform State
- Terraform kann dann die Domain-Konfiguration korrekt auflösen
- Dependencies sind im State verfügbar für Referenz

**Warum schlägt es bei "kaltem Start" fehl?**
- Service Account existiert noch nicht im State
- Domain-Validierung schlägt fehl beim Citrix Provider
- Circular dependency zwischen Service Account und Machine Catalog
