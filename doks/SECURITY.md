# SECURITY POLICY

## 🔐 Übersicht
Dieses Projekt stellt ein Terraform Modul zur Bereitstellung veröffentlichter Citrix DaaS Applikationen bereit. Sicherheit umfasst hier:
- Schutz sensibler Werte (API Credentials)
- Sicherer Umgang mit Infrastruktur- und Identitätsparametern
- Transparente Behandlung gemeldeter Schwachstellen
- Minimierung des Risikos unbeabsichtigter Eskalationen durch Fehlkonfiguration

---
## ✅ Unterstützte Versionen
Wir unterstützen aktiv die letzten **drei Minor-Releases** innerhalb des aktuellen Hauptzweigs (0.x Phase) sowie die **neueste veröffentlichte Version**.

| Version | Status | Sicherheitsfixes |
|---------|--------|------------------|
| 0.6.x   | Aktiv  | Ja |
| 0.5.x   | Eingeschränkt | Nur kritische Fixes |
| < 0.5   | Nicht unterstützt | Nein |

Mit Release 1.0.0 wird ein Long-Term Support Schema (LTS + Current) evaluiert.

---
## 🛡️ Sicherheitsrelevante Themen im Modul
| Bereich | Beschreibung | Empfehlung |
|---------|--------------|------------|
| Provider Auth | Citrix Cloud Credentials (Client ID / Secret) | Niemals in VCS speichern, als Umgebungsvariablen setzen |
| Sensible Variablen | `client_secret` als `sensitive = true` markiert | Terraform State file schützen (Backend Security) |
| Sichtbarkeit | Optionale Limitierung via AD-Gruppen | Testen in Staging bevor Produktion |
| Icons (Binary Data) | Base64 Einbettung möglich | Keine vertraulichen Inhalte in Icons packen |
| Application Names | Keine sensiblen Bezeichner (kundenintern) verwenden | Namenskonvention definieren |

---
## 📦 Geheimnis-Handling (Secrets Management)
Empfohlenes Vorgehen:
1. Nutzung von Environment Variablen: `export TF_VAR_client_secret=...`
2. Remote Backend (z. B. Terraform Cloud, S3 mit Encryption + Versioning)
3. Keine `.tfvars` mit Klartext-Secret einchecken
4. Optional: Einsatz externer Secret Manager (Vault, AWS Secrets Manager)

Beispiel (.gitignore prüfen):
```
*.auto.tfvars
terraform.tfvars
```

---
## 🔍 Security Scans
Empfohlene Tools (können in CI aktiviert werden):
| Tool | Zweck | Status |
|------|-------|--------|
| tfsec | Terraform Sicherheitsanalysen | Optional (empfohlen) |
| checkov | Best Practices & Policy Checks | Optional (empfohlen) |
| trivy config | Generischer IaC Scanner | Optional |
| tflint | Style & pot. Fehler | Bereits empfohlen |

Baseline Beispiel (tfsec):
```
tfsec . --format json --out tfsec-report.json
```

---
## 🚨 Schwachstellen melden (Responsible Disclosure)
Bitte KEINE Schwachstellen öffentlich in Issues posten.

Meldeweg:
1. E-Mail an: `security@abraxas-labs.example` (Platzhalter – anpassen)
2. Enthalten sein sollten: Reproduktionsschritte, Auswirkungsbeschreibung, betroffene Version
3. Erwartete Antwortzeit: 5 Werktage
4. Koordinierte Offenlegung: Veröffentlichung nach gemeinsamer Abstimmung

Falls keine Antwort innerhalb von 10 Werktagen erfolgt → freundlich erinnern.

---
## 🧪 Validierungsstrategie (Empfehlung)
| Ebene | Kontrolle | Ziel |
|-------|-----------|-----|
| Pre-Commit | `terraform fmt`, `validate`, `tflint` | Konsistenz & Syntax |
| CI Stage 1 | `terraform validate` alle Beispiele | Sicherer Plan |
| CI Stage 2 | Security Scans | Policy Compliance |
| Optional Stage | Terratest Plan Assertions | Semantische Validität |

---
## 🔏 Terraform State Sicherheit
| Risiko | Maßnahme |
|--------|----------|
| Offenlegung State (lokal) | Remote Backend verwenden |
| State Theft | Backend Access Control + Encryption at Rest |
| Ungewollte Drifts | Regelmäßige `terraform plan` Checks (CI Cron) |

---
## 🧩 Supply Chain
| Komponente | Quelle | Empfehlung |
|------------|--------|------------|
| Citrix Provider | `citrix/citrix` | Version per Root Projekt pinnen (`~> 1.0.x`) |
| Modul selbst | Git Tag | Prüfsumme durch Terraform Registry |
| Abhängigkeiten | Keine verschachtelten Module | N/A |

Renovate/Dependabot kann eingesetzt werden für automatisierte Provider Update PRs.

---
## ❗ Bekannte Einschränkungen
| Bereich | Limitation |
|---------|-----------|
| Multi-App Deployment | Aktuell nicht nativ im Modul (Single Resource) |
| Secrets Rotation | Keine automatische Rotation (extern managen) |
| Audit Logging | Liegt außerhalb des Modulumfangs (Citrix Seite) |

---
## 🔮 Geplante Security Verbesserungen
| Phase | Item |
|-------|------|
| Kurzfristig | SECURITY.md Veröffentlichung + CI tfsec Integration |
| Mittelfristig | Checkov Baseline + Policy Exceptions dokumentieren |
| Langfristig | OPA/Conftest Richtlinien für Naming & Visibility |

---
## 📄 Lizenz & Haftung
Dieses Modul wird "AS IS" bereitgestellt (siehe LICENSE). Sicherheitsrelevante Anpassungen liegen in Verantwortung der konsumierenden Plattform-Teams.

---
## ✅ Zusammenfassung
Diese Security Policy schafft Transparenz über Umgang mit Credentials, geplante Maßnahmen und Meldeprozesse. Vorschläge für weitergehende Hardening-Schritte sind willkommen – bitte über Pull Request oder Security Kontakt einreichen.
