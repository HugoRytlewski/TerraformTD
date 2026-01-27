#!/bin/bash

source $(dirname "$0")/config.sh

echo "🔍 Test Fonctionnel : Vérification de l'accès à $TARGET_URL"

# Test 1: Code HTTP 200
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL")

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✅ [SUCCESS] Le site est accessible (HTTP 200)."
else
    echo "❌ [FAIL] Le site a renvoyé $HTTP_CODE (attendu: 200)."
    exit 1
fi

# Test 2: Contenu attendu
EXPECTED_CONTENT="System Operational"
CONTENT=$(curl -s "$TARGET_URL")

if echo "$CONTENT" | grep -q "$EXPECTED_CONTENT"; then
  echo "[SUCCESS] Le contenu attendu est présent."
else
  echo "[FAIL] Contenu manquant. Attendu : '$EXPECTED_CONTENT'"
  exit 1
fi

echo " Tous les tests fonctionnels sont passés !"
exit 0
