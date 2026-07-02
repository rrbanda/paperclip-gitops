#!/usr/bin/env bash
set -euo pipefail

# Import company config from this repo into the running Paperclip instance.
# This syncs: skills (to store) + agents/projects (via company import).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPANY_DIR="$REPO_ROOT/company"

PAPERCLIP_URL="${PAPERCLIP_URL:-https://PAPERCLIP_ROUTE_URL}"
COMPANY_ID="${COMPANY_ID:-52d75bd0-d5db-4aa3-ae5b-a991111c4e00}"

echo "=== Paperclip Company Import ==="
echo "URL: $PAPERCLIP_URL"
echo "Company: $COMPANY_ID"
echo "Source: $COMPANY_DIR"
echo ""

# Step 1: Sync skills to the skill store
echo "--- Syncing skills to store ---"
for skill_dir in "$COMPANY_DIR"/skills/*/; do
  if [ -f "$skill_dir/SKILL.md" ]; then
    skill_name=$(basename "$skill_dir")
    echo "  Importing skill: $skill_name"
    paperclipai skills import "$skill_dir" \
      --url "$PAPERCLIP_URL" \
      --company "$COMPANY_ID" || echo "  WARNING: Failed to import $skill_name"
  fi
done

echo ""

# Step 2: Import company package (agents + projects)
echo "--- Importing company config ---"
paperclipai company import "$COMPANY_DIR" \
  --target existing \
  --companyId "$COMPANY_ID" \
  --collision replace \
  --yes \
  --url "$PAPERCLIP_URL"

echo ""
echo "Import complete. Verify in Paperclip UI."
