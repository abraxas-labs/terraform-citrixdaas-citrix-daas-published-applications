# 004: Deployment Documentation

**Status**: pending
**Created**: 2025-09-27
**Priority**: medium

## Description

Dokumentation des neuen 2-Phasen-Deployment-Workflows für Machine Catalogs nach der Conditional Module Deployment Implementierung.

## 2-Phasen-Deployment Anleitung

### Phase 1: Infrastructure Setup 🏗️

**Ziel**: Deployment der Basis-Infrastruktur ohne Machine Catalogs

```bash
# Option A: CLI Override
terraform apply -var-file="customer.auto.tfvars" -var="deploy_machine_catalogs=false"

# Option B: .auto.tfvars Konfiguration (empfohlen)
# Set deploy_machine_catalogs = false in customer.auto.tfvars
terraform apply -var-file="customer.auto.tfvars"
```

**Deployed Resources:**
- ✅ Citrix Service Account (`citrix_service_account.sc_for_machine_id_domain`)
- ✅ Application Folder (`module.citrix_daas_application_folder`)
- ✅ Azure Hypervisor Connection (`module.citrix_daas_hypervisor_azure`)
- ✅ Resource Pool
- ✅ Image Definition (`module.citrix_image_hsd`)
- ✅ Image Version

**Expected Output:**
```
Plan: 7 to add, 0 to change, 0 to destroy.
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

### Phase 2: Machine Catalog Deployment 🖥️

**Prerequisite**: Phase 1 muss erfolgreich abgeschlossen sein

```bash
# Option A: CLI Override
terraform apply -var-file="customer.auto.tfvars" -var="deploy_machine_catalogs=true"

# Option B: .auto.tfvars Update (empfohlen)
# Set deploy_machine_catalogs = true in customer.auto.tfvars
terraform apply -var-file="customer.auto.tfvars"
```

**Deployed Resources:**
- ✅ Machine Catalog HSD Test (`module.citrix_machine_catalog_hsd_test`)
- ✅ Machine Catalog HSD Production (wenn uncommented)

## Configuration Management

### customer.auto.tfvars Updates

```hcl
# Phase 1 Configuration
deploy_machine_catalogs = false # Infrastructure nur

# Phase 2 Configuration
deploy_machine_catalogs = true  # Mit Machine Catalogs
```

## Troubleshooting

### Problem: "Missing Attribute Configuration" Error

**Symptom:**
```
Error: Missing Attribute Configuration
Expected domain to be configured when identity_type is Active Directory.
```

**Lösung:**
- ✅ Stelle sicher, dass Phase 1 erfolgreich durchgeführt wurde
- ✅ Service Account muss im Terraform State existieren
- ✅ Verwende `deploy_machine_catalogs = false` für Phase 1

### Problem: Machine Catalogs werden nicht deployed

**Symptom:**
```
Plan: 0 to add, 0 to change, 0 to destroy.
```

**Lösung:**
- ✅ Setze `deploy_machine_catalogs = true`
- ✅ Prüfe `machine_catalog_count > 0`

## CI/CD Integration

### GitLab Pipeline Stages

```yaml
stages:
  - phase1-infrastructure
  - phase2-machine-catalogs

phase1-infrastructure:
  script:
    - terraform apply -var="deploy_machine_catalogs=false" -auto-approve

phase2-machine-catalogs:
  script:
    - terraform apply -var="deploy_machine_catalogs=true" -auto-approve
  needs:
    - phase1-infrastructure
```

## Action Items

- [ ] Update main README.md with 2-phase deployment instructions
- [ ] Create CI/CD pipeline templates
- [ ] Add deployment validation scripts
- [ ] Document rollback procedures

## Notes

**Deployment Best Practices:**
- Verwende `.auto.tfvars` Konfiguration für reproduzierbare Deployments
- Immer Phase 1 vor Phase 2 durchführen
- Validiere successful completion jeder Phase
- Dokumentiere alle Phase-spezifischen Outputs
