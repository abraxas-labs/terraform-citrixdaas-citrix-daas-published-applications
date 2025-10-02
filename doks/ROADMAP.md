# ROADMAP
**Projekt**: Terraform Modul – Citrix DaaS Published Applications
**Stand**: 2025-10-02
**Ziel**: Stabiler Weg zu Version 1.0.0 & Enterprise Readiness

---
## 🎯 Leitprinzipien
- Vorhersehbarkeit & Stabilität (SemVer konsequent)
- Minimale Breaking Changes – kontrollierte Deprecation Zyklen
- Transparente Security- & Qualitäts-Gates
- Erweiterbarkeit ohne Over-Engineering

---
## 🧭 Milestones Übersicht
| Milestone | Ziel | Hauptthemen | Status |
|-----------|------|-------------|--------|
| M1 – Foundations | CI & Basis-Governance | CI Pipeline, Security Policy | Offen |
| M2 – Documentation+ | Strukturierte Doku | CONTRIBUTING, ROADMAP, MIGRATION Draft | Offen |
| M3 – Testing Core | Technische Verlässlichkeit | Terratest Plan Assertions | Offen |
| M4 – Naming & Stability | Vorbereitung 1.0 | Deprecations + Umbennenungen | Offen |
| M5 – 1.0.0 Release | Stabilisierung | Hardening, final Schema | Offen |
| M6 – Enterprise Add-ons | Governance Tiefe | OPA Policies, Multi-App Patterns | Geplant |

---
## 🏁 Milestone Details
### M1 – Foundations (Kurzfristig)
Ziele:
- CI Minimal (fmt, validate, tflint, examples validate)
- SECURITY.md & CONTRIBUTING.md (erledigt)
- ROADMAP sichtbar (erledigt)
- Changelog `[Unreleased]` Abschnitt aktiv

Erfolgskriterien:
- PR Gate schlägt an bei Formatfehlern
- Alle Beispiele valide (automatisiert)

### M2 – Documentation+
Ziele:
- MIGRATION.md (Vorbereitet für zukünftige Breaking Changes)
- README Verschlankung + Auslagerung USAGE.md
- Provider Version Empfehlungen ergänzen
- Example Matrix (Verwendungsfälle)

### M3 – Testing Core
Ziele:
- Terratest Grundgerüst (Plan Only)
- Negativ Tests für Validierungen (z. B. ungültige Pfade)
- Output Assertions (`application_id`, `published_name` vorhanden)

### M4 – Naming & Stability
Ziele:
- Evaluierung Prefix Reduktion (`citrix_application_name` → `application_name`)
- Dual Definition (Alias Phase) + Deprecation Hinweise
- Konsolidierung `citrix_deliverygroup_name` → `delivery_group_name`
- Optional Flags: zusätzliche Outputs (`has_custom_icon`)

### M5 – 1.0.0 Release
Ziele:
- Entfernen Deprecated Aliase
- Freeze der Variablen-Schnittstelle
- README finalisieren (Architecture + Troubleshooting komprimiert)
- Testabdeckung Plan Assertions ≥ 30%

### M6 – Enterprise Add-ons (Post 1.0)
Ziele:
- OPA/Conftest Policies: Naming, Visibility Regeln
- Multi-App Deployment Patterns (Dokumentiert, nicht zwingend integriert)
- CI Drift Detection (geplanter Cron `terraform plan` Check)
- Security Scan Ergebnisse als Badges

---
## 🚦 Priorisierte Feature-/Verbesserungsliste
| Prio | Item | Beschreibung | Zugeordnetes Milestone |
|------|------|--------------|-------------------------|
| P0 | CI Minimal | fmt, validate, examples loop | M1 |
| P0 | Security Policy | SECURITY.md | M1 (erledigt) |
| P1 | MIGRATION Draft | Template + erste Einträge | M2 |
| P1 | USAGE.md | Auslagerung Konfigurationstabellen | M2 |
| P1 | Terratest Plan | Grundgerüst | M3 |
| P2 | Negativ Tests | Validierungen greifen korrekt | M3 |
| P2 | Naming Aliase | Dual Variables | M4 |
| P2 | Zusätzliche Outputs | Meta Flags | M4 |
| P2 | 1.0 Freeze Vorbereitung | Entfernen Aliase | M5 |
| P3 | Drift Detection | Cron Plan Check | M6 |
| P3 | OPA Policies | Governance Regeln | M6 |
| P3 | Multi-App Pattern Guide | Dokumentation Only | M6 |

---
## 🔄 Deprecation Strategie (Kurzfassung)
| Phase | Aktion | Beispiel |
|-------|-------|----------|
| Einführung | Neue Variable ohne Prefix + Alias | `application_name` + bleibt `citrix_application_name` |
| Deprecation Hinweis | README & MIGRATION | "Wird in 0.9 entfernt" |
| Dual Support | Code nutzt alt + neu (Priorität neu) | `var.application_name != null ? var.application_name : var.citrix_application_name` |
| Entfernung | Release 1.0.0 | Alte Namen gelöscht |

---
## 🔐 Security Roadmap
| Phase | Maßnahme | Ziel |
|-------|----------|------|
| M1 | Policy Dokument | Transparenz |
| M2 | CI tfsec/checkov optional | Grundlage Scans |
| M3 | Ergebnis Badges | Sichtbarkeit |
| M4 | False Positive Baseline | Stabilität |
| M6 | OPA/Conftest | Governance |

---
## 🧪 Testing Roadmap
| Phase | Testtyp | Tiefe |
|-------|---------|------|
| M1 | validate + examples | Syntax |
| M3 | Plan Assertions | Strukturelle Sicherheit |
| M4 | Negative Cases | Validierungsregeln |
| M5 | Regession Set (Kernpfad) | Schnittstellenstabilität |
| M6 | Optional Performance Checks | Skalierung |

---
## 📊 KPIs (Tracking Einstieg)
| KPI | Start | Ziel M3 | Ziel 1.0 | Ziel M6 |
|-----|-------|---------|----------|---------|
| Beispiele valide (CI) | n/a | 100% | 100% | 100% |
| Testabdeckung Plan | 0% | 20% | 30% | 50% |
| Zeit PR→Release Ø | variabel | <5 Tage | <3 Tage | <2 Tage |
| Security Scan Clean Rate | n/a | ≥90% | ≥95% | ≥98% |

---
## 🗂 Dateiplan Ergänzungen
| Datei | Status | Milestone |
|-------|--------|-----------|
| MIGRATION.md | Offen | M2 |
| USAGE.md | Offen | M2 |
| tests/ (Go) | Offen | M3 |
| policy/ (OPA) | Geplant | M6 |

---
## ❓ FAQ Roadmap
| Frage | Antwort |
|-------|---------|
| Wann 1.0? | Nach Abschluss M4 & M5 Stabilisierung |
| Breaking Changes Risiko? | Gering bis M4 (vorbereitet), danach Freeze |
| Multi-App nativ? | Vorerst im Consumer (for_each) statt Modul-Intern |
| Provider 2.x Support | Nach Stabilitätstests – eigener Milestone post 1.0 |

---
## ✅ Nächste unmittelbare Schritte
1. CI Pipeline anlegen (validate & examples)
2. MIGRATION.md Skeleton hinzufügen
3. README erweitern: Provider Version Empfehlung
4. Issue Templates (Bug / Feature / Question) vorbereiten

---
*Diese Roadmap wird iterativ gepflegt. Vorschläge willkommen via Issue mit Label `roadmap`.*
