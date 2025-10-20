#!/usr/bin/env bash
set -euo pipefail

# Einfaches Test-Script: 10 Zyklen von terraform apply und destroy ohne Nachfragen

echo "Starte 10 Terraform-Zyklen (apply + destroy)..."

for i in {1..10}; do
    echo "=== Zyklus $i / 10 ==="

    echo "Führe terraform apply aus..."
    terraform apply -auto-approve

    echo "Führe terraform destroy aus..."
    terraform destroy -auto-approve

    echo "Zyklus $i abgeschlossen."
done

echo "Alle 10 Zyklen beendet."