# 002: Solution Strategies

**Status**: pending
**Created**: 2025-09-27
**Priority**: high

## Description

Entwicklung von Lösungsstrategien für das Machine Catalog Deployment-Problem. Evaluation verschiedener Ansätze zur Auflösung der Circular Dependency.

## Lösungsansätze

### Strategie 1: Conditional Module Deployment ⭐ **EMPFOHLEN**
```hcl
# Variable für stufenweise Deployment
variable "deploy_machine_catalogs" {
  description = "Enable machine catalog deployment after infrastructure is ready"
  type        = bool
  default     = false
}

# Conditional Module Call
module "citrix_machine_catalog_hsd_test" {
  count = var.deploy_machine_catalogs ? var.machine_catalog_count : 0
  # ... rest of module configuration
}
```

**Vorteile:**
- ✅ Saubere Lösung ohne Code-Modifikation
- ✅ Explizite Kontrolle über Deployment-Phasen
- ✅ Keine Provider-spezifischen Workarounds

**Nachteile:**
- ⚠️ Erfordert 2-Phasen-Deployment
- ⚠️ Zusätzliche Variable erforderlich

### Strategie 2: Terraform Target-Based Deployment
```bash
# Phase 1: Infrastructure & Service Account
terraform apply -target=citrix_service_account.sc_for_machine_id_domain
terraform apply -target=module.citrix_daas_hypervisor_azure

# Phase 2: Machine Catalogs
terraform apply
```

**Vorteile:**
- ✅ Keine Code-Änderungen erforderlich
- ✅ Granulare Kontrolle über Resources

**Nachteile:**
- ❌ Manueller, fehleranfälliger Prozess
- ❌ Nicht reproduzierbar in CI/CD

### Strategie 3: Module Precondition Enhancement
```hcl
# In modules/citrix-machine-catalog-hsd/main.tf
lifecycle {
  precondition {
    condition     = var.service_account_id != null && var.domain_name != null
    error_message = "Service Account ID and Domain Name must be configured before Machine Catalog deployment"
  }
}
```

**Vorteile:**
- ✅ Bessere Fehlerbehandlung
- ✅ Klare Abhängigkeiten

**Nachteile:**
- ❌ Löst das grundlegende Problem nicht
- ❌ Weiterhin Circular Dependency

### Strategie 4: Domain Configuration Refactoring
```hcl
# Separate domain data source
data "citrix_domain" "active_directory" {
  name = local.domain_name
  # Only query if service account exists
  depends_on = [citrix_service_account.sc_for_machine_id_domain]
}

# Use data source in module
domain_name = data.citrix_domain.active_directory.name
```

**Vorteile:**
- ✅ Explizite Domain-Validierung
- ✅ Bessere Dependency-Auflösung

**Nachteile:**
- ⚠️ Erfordert Provider-Support für Domain Data Source
- ⚠️ Zusätzliche Komplexität

## Bewertung und Empfehlung

### Empfohlene Lösung: **Strategie 1 (Conditional Module Deployment)**

**Implementierungsplan:**
1. Variable `deploy_machine_catalogs` in `variables.tf` hinzufügen
2. Conditional count in `citrix-machine-catalogs.tf` implementieren
3. Dokumentation für 2-Phasen-Deployment erstellen
4. CI/CD Pipeline anpassen

**Deployment-Workflow:**
```bash
# Phase 1: Infrastructure Setup
terraform apply -var="deploy_machine_catalogs=false"

# Phase 2: Machine Catalog Deployment
terraform apply -var="deploy_machine_catalogs=true"
```

## Action Items

- [ ] Implement conditional deployment variable
- [ ] Update citrix-machine-catalogs.tf with conditional logic
- [ ] Test 2-phase deployment workflow
- [ ] Update documentation and CI/CD pipeline

## Notes

**Warum Strategie 1?**
- Minimal invasive Lösung
- Reproduzierbar und automatisierbar
- Klare Trennung der Deployment-Phasen
- Kompatibel mit bestehender Infrastruktur
