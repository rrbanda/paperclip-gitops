#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

info()  { echo "[INFO]  $*"; }
error() { echo "[ERROR] $*" >&2; ((ERRORS++)) || true; }

# --- yamllint ---
info "Running yamllint..."
if command -v yamllint &>/dev/null; then
  yamllint -d relaxed "$REPO_ROOT" || { error "yamllint found issues"; }
else
  error "yamllint not installed (pip install yamllint)"
fi

# --- kustomize build ---
info "Validating kustomize build for all environments..."
if command -v kustomize &>/dev/null; then
  for env_dir in "$REPO_ROOT"/platform/environments/*/; do
    env_name=$(basename "$env_dir")
    if kustomize build "$env_dir" > /dev/null 2>&1; then
      info "  $env_name: OK"
    else
      error "  $env_name: kustomize build failed"
      kustomize build "$env_dir" 2>&1 | head -20
    fi
  done
else
  error "kustomize not installed"
fi

# --- Secret leak detection ---
info "Scanning for leaked secrets..."
LEAK_PATTERNS='(password|token|secret|api.key)\s*[:=]\s*["\x27]?[a-zA-Z0-9/+=]{8,}'
EXCLUDE_DIRS=".git|secrets/templates"

leaked=$(grep -riP "$LEAK_PATTERNS" "$REPO_ROOT" \
  --include="*.yaml" --include="*.yml" --include="*.json" \
  | grep -vE "($EXCLUDE_DIRS|PLACEHOLDER|PLACEHOLDER_DO_NOT_COMMIT)" || true)

if [[ -n "$leaked" ]]; then
  error "Possible secret values found in tracked files:"
  echo "$leaked" | head -10
else
  info "  No leaked secrets detected."
fi

# --- AGENTS.md frontmatter validation ---
info "Validating AGENTS.md frontmatter..."
for agents_file in "$REPO_ROOT"/agents/definitions/*/AGENTS.md; do
  if [[ ! -f "$agents_file" ]]; then
    continue
  fi
  slug=$(basename "$(dirname "$agents_file")")
  if ! head -1 "$agents_file" | grep -q '^---$'; then
    error "  $slug/AGENTS.md: missing YAML frontmatter delimiter"
  fi
done

# --- Summary ---
echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo "VALIDATION FAILED: $ERRORS error(s) found."
  exit 1
else
  info "All validations passed."
  exit 0
fi
