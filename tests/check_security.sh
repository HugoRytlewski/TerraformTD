#!/bin/bash

source $(dirname "$0")/config.sh

echo "  Test de Sécurité : Vérification des headers sur $TARGET_URL"

# Headers à vérifier
REQUIRED_HEADERS=(
    "X-Frame-Options: DENY"
    "X-Content-Type-Options: nosniff"
)

ERRORS=0

for header in "${REQUIRED_HEADERS[@]}"; do
    KEY=$(echo "$header" | cut -d: -f1)
    EXPECTED_VALUE=$(echo "$header" | cut -d: -f2 | xargs)

    # Récupérer le header depuis le serveur
    ACTUAL_VALUE=$(curl -s -I "$TARGET_URL" | grep -i "^$KEY:" | cut -d: -f2 | xargs | tr -d '\r')

    if [ "$ACTUAL_VALUE" == "$EXPECTED_VALUE" ]; then
        echo "[SUCCESS] $KEY est présent et correct ($ACTUAL_VALUE)."
    else
        echo " [FAIL] $KEY manquant ou incorrect. Attendu: '$EXPECTED_VALUE', Reçu: '$ACTUAL_VALUE'"
        ERRORS=$((ERRORS+1))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo "  Il y a $ERRORS problèmes de sécurité détectés !"
    exit 1
else
    echo " Tous les tests de sécurité sont passés !"
    exit 0
fi
