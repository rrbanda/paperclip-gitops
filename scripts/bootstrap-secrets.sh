#!/usr/bin/env bash
set -euo pipefail

# Bootstrap secrets for Paperclip on OpenShift.
# Run this ONCE to create the required secrets. Never commit real values to git.

NAMESPACE="${NAMESPACE:-paperclip}"

echo "=== Paperclip Secrets Bootstrap ==="
echo "This will create the 'paperclip-secrets' Secret in namespace: $NAMESPACE"
echo ""

# Check if secret already exists
if oc get secret paperclip-secrets -n "$NAMESPACE" &>/dev/null; then
  echo "WARNING: Secret 'paperclip-secrets' already exists in $NAMESPACE."
  read -p "Overwrite? (y/N): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
  fi
  oc delete secret paperclip-secrets -n "$NAMESPACE"
fi

# Prompt for values
read -sp "Enter POSTGRES_PASSWORD: " POSTGRES_PASSWORD
echo ""

DATABASE_URL="postgres://paperclip:${POSTGRES_PASSWORD}@paperclip-db:5432/paperclip"

read -sp "Enter BETTER_AUTH_SECRET (64-char hex, or press Enter to generate): " BETTER_AUTH_SECRET
echo ""

if [ -z "$BETTER_AUTH_SECRET" ]; then
  BETTER_AUTH_SECRET=$(openssl rand -hex 32)
  echo "Generated BETTER_AUTH_SECRET: ${BETTER_AUTH_SECRET:0:8}..."
fi

# Create the secret
oc create secret generic paperclip-secrets \
  --namespace="$NAMESPACE" \
  --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --from-literal=BETTER_AUTH_SECRET="$BETTER_AUTH_SECRET"

echo ""
echo "Secret 'paperclip-secrets' created successfully in $NAMESPACE."
echo "ArgoCD will NOT manage this secret -- it is excluded from git."
