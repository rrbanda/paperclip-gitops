#!/usr/bin/env bash
set -euo pipefail

# Export current Paperclip company config to the company/ directory.
# Requires: paperclipai CLI configured with access to the running instance.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPANY_DIR="$REPO_ROOT/company"

PAPERCLIP_URL="${PAPERCLIP_URL:-https://paperclip-paperclip.apps.cluster-4l6x6.4l6x6.sandbox1213.opentlc.com}"
COMPANY_ID="${COMPANY_ID:-52d75bd0-d5db-4aa3-ae5b-a991111c4e00}"

echo "=== Paperclip Company Export ==="
echo "URL: $PAPERCLIP_URL"
echo "Company: $COMPANY_ID"
echo "Output: $COMPANY_DIR"
echo ""

# Export using paperclipai CLI (agents + projects, skills are separate)
paperclipai company export "$COMPANY_ID" \
  --out "$COMPANY_DIR" \
  --include company,agents,projects \
  --url "$PAPERCLIP_URL"

echo ""
echo "Export complete. Skills are managed separately in company/skills/."
echo "Review changes with: git diff company/"
