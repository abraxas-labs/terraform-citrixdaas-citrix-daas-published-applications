# CONTRIBUTING

Vielen Dank für dein Interesse an Beiträgen zu diesem Terraform Modul für Citrix DaaS veröffentlichte Applikationen! Dieses Dokument beschreibt den empfohlenen Workflow, Qualitätsanforderungen und Richtlinien für Pull Requests.

---
## 🧭 Inhaltsverzeichnis
1. Philosophie & Ziele
2. Kommunikationskanäle
3. Issue Guidelines
4. Branching & Git Flow
5. Entwicklungsumgebung einrichten
6. Pre-Commit Hooks & Qualitätssicherung
7. Konventionen (Code, Commits, Terraform)
8. Tests & Validierung
9. Dokumentation aktualisieren
10. Release Prozess (Maintainer)
11. Security Hinweise
12. License & Contributor Attribution

---
## 1. Philosophie & Ziele
Wir optimieren für:
- Vorhersagbarkeit & Stabilität (Backward Compatibility, SemVer)
- Transparenz (Changelog, Roadmap, klare Migrationspfade)
- Reproduzierbarkeit (Formatierung, Validierung, deterministischer State)
- Minimale Überraschungen für Anwender

Nicht-Ziele:
- Vollautomatisiertes Multi-App Lifecycle Management (kann separat folgen)
- Überkomplexe interne Abstraktionsschichten

---
## 2. Kommunikationskanäle
| Zweck | Kanal |
|-------|-------|
| Bug melden | GitHub/GitLab Issue (Template verwenden) |
| Feature Request | Issue mit Label `enhancement` |
| Sicherheitsproblem | Siehe `SECURITY.md` (nicht öffentlich posten) |
| Diskussion / Architektur | Discussion Board (wenn vorhanden) |

---
## 3. Issue Guidelines
Bevor du ein Issue erstellst:
1. Suche nach bestehenden Issues (Duplikate vermeiden)
2. Prüfe Changelog für evtl. bekannte Änderungen
3. Nutze das passende Template (Bug / Feature / Question)

### Bug Report Mindestangaben
- Modulversion & Provider-Version
- Terraform Version (`terraform version` Ausgabe)
- Minimal reproduzierbare Konfiguration (Code-Auszug)
- Erwartetes vs. tatsächliches Verhalten
- Relevante Logs/Fehlermeldungen (gekürzt)

### Feature Request Angaben
- Use Case / Problem
- Nutzen / Impact
- Vorschlag (optional Code-Snippet)
- Breaking Change Risiko?

---
## 4. Branching & Git Flow
| Zweig | Zweck |
|-------|------|
| `main` / `master` | Stable Releases (tagged) |
| `refactoring` / `develop` | Integrations-/Vorbereitungszweige |
| `feature/<kurz-beschreibung>` | Neue Features |
| `fix/<kurz-beschreibung>` | Fehlerbehebungen |
| `docs/<kurz-beschreibung>` | Dokumentationsänderungen |
| `chore/<thema>` | Infrastruktur / Tooling |

Konvention: Kleinbuchstaben, Bindestriche, keine Sonderzeichen.

---
## 5. Entwicklungsumgebung einrichten
Voraussetzungen:
- Terraform >= 1.2 (empfohlen >= 1.5)
- (Optional) Go >= 1.21 für Terratest zukünftig
- pre-commit installiert

Setup:
```
pre-commit install
terraform init
```

Example Verifikation:
```
for d in examples/*/; do (cd "$d" && terraform init -backend=false && terraform validate); done
```

---
## 6. Pre-Commit Hooks & Qualitätssicherung
Falls `.pre-commit-config.yaml` vorhanden:
- `terraform fmt` (Formatierung)
- `terraform validate`
- `tflint`
- `terraform-docs` (aktualisiert Tabellen in READMEs)
- (Optional) Security: `tfsec`, `checkov`

PR darf nur gemergt werden wenn:
- Kein Format-Diff
- Validierung erfolgreich
- Beispiele validieren
- Changelog aktualisiert (falls user impacting)

---
## 7. Konventionen
### 7.1 Code / Terraform
| Bereich | Konvention |
|---------|-----------|
| Dateinamen | snake_case, logisch gruppiert |
| Ressourcen | Single-Resource Module: `resource "<type>" "this"` |
| Data Sources | `data "..." "this"` bei Einzel-Verwendung |
| Variablen Präfix | Derzeit `citrix_` (Migration geplant – siehe ROADMAP) |
| Strings | Doppelte Anführungszeichen |
| Indentation | 2 Spaces |

### 7.2 Commits
Empfohlenes Format (konventionell):
```
<type>(scope): prägnante beschreibung

(optional body)
(optional footer)
```
**Types**: feat, fix, docs, refactor, chore, test, ci, security

Beispiele:
```
feat(examples): add multi-app usage example
fix(outputs): correct published application output name
```

### 7.3 Changelog Einträge
Nutze Kategorien: Added / Changed / Deprecated / Fixed / Removed / Security

---
## 8. Tests & Validierung
Aktuell: Fokus auf `terraform validate` und Beispiele.
Geplant:
- Terratest (Plan Parsing) – keine echten API Calls erforderlich
- Negative Tests: ungültige Pfade, zu lange Namen, falsches Icon Format

Beispiel (Pseudo Go):
```go
plan := terraform.InitAndPlanAndShowWithStruct(t, opts)
require.NotNil(t, plan.ResourcePlannedValuesMap["citrix_application.published_application"])
```

---
## 9. Dokumentation aktualisieren
Pflicht bei PR wenn zutreffend:
| Änderung | Aktion |
|----------|--------|
| Neue Variable | `variables.tf` + README Input Tabelle aktualisiert |
| Entfernte Variable | README + MIGRATION.md Hinweis |
| Breaking Change | CHANGELOG + MIGRATION.md |
| Neues Beispiel | Ordner + README + Haupt-README Beispiele-Liste |
| Security Relevanz | SECURITY.md erweitern |

`terraform-docs` läuft idealerweise automatisch (CI oder Pre-Commit).

---
## 10. Release Prozess (Maintainer)
1. Prüfen offene Issues / Blocker
2. Letzten Commit Tagging-Kandidat verifizieren
3. CHANGELOG aktualisieren und Abschnitt `[Unreleased]` verschieben
4. Version semantisch bestimmen (Patch / Minor / Major)
5. Tag setzen: `git tag -a v0.x.y -m "Release v0.x.y"`
6. Push: `git push origin v0.x.y`
7. README & Registry Render kontrollieren
8. Optional: Release Notes Plattform erstellen

Rollback Strategie: neuen Patch mit Revert Commits veröffentlichen.

---
## 11. Security Hinweise
Siehe `SECURITY.md`. Grundsatz: Nie Secrets in Issues, PRs oder Commits. State Files nicht anhängen.

---
## 12. License & Contributor Attribution
Mit Beitrag erklärst du dich einverstanden, dass dein Code unter der im Repository enthaltenen **MIT Lizenz** veröffentlicht wird. Füge dich optional zur Maintainer/Contributor Sektion (PR).

---
## 13. FAQ (Kurz)
| Frage | Antwort |
|-------|---------|
| Kann ich Variablen umbenennen? | Nur mit Deprecation Pfad + Changelog Hinweis |
| Multi-App Support im Modul direkt? | Vorerst im Consumer mittels for_each empfohlen |
| Wann 1.0.0? | Nach Stabilisierung von Naming & Tests (siehe ROADMAP) |

---
## 14. Schnelle Checkliste vor Pull Request
- [ ] Terraform Formatierung OK
- [ ] `terraform validate` OK (Root + Examples falls betroffen)
- [ ] Beispiele angepasst (falls relevant)
- [ ] CHANGELOG aktualisiert
- [ ] README / Doku aktualisiert
- [ ] Keine Secrets / sensiblen Daten
- [ ] CI Checks grün

Vielen Dank für deinen Beitrag! 🙌
