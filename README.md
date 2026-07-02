# Paperclip GitOps

Enterprise-grade GitOps configuration for Red Hat Americas AI Platform Team's Paperclip deployment.

## Repository Structure

```
.github/          CI/CD workflows, CODEOWNERS, PR template
platform/         Infrastructure manifests (Platform Engineering)
  base/           Canonical K8s resources (Kustomize base)
  environments/   Per-env overlays (dev, staging, prod)
  argocd/         ArgoCD ApplicationSet definitions
agents/           Agent definitions and skills (Agent Engineering)
  definitions/    AGENTS.md files per agent
  skills/         SKILL.md files for the skill store
  config/         Adapter configurations (no secrets)
operations/       Org structure and config (Team Lead)
  users.yaml      Declarative user list
  org-chart.yaml  Agent hierarchy
  projects/       Project definitions
  routines/       Recurring task schedules
secrets/          Templates and ESO manifests (never real values)
docs/             Operating model, runbook, architecture
scripts/          Helper scripts (bootstrap, validate, import/export)
```

## Quick Start

```bash
# 1. Bootstrap secrets (one-time per environment)
./scripts/bootstrap-secrets.sh

# 2. Apply ApplicationSet (one-time)
oc apply -f platform/argocd/appset-platform.yaml

# 3. Validate locally before pushing
./scripts/validate.sh
```

## Operating Model

See [docs/OPERATING-MODEL.md](docs/OPERATING-MODEL.md) for the producer/consumer framework.

| Role | Owns | Access |
|------|------|--------|
| Platform Engineer | `platform/`, `secrets/` | Cluster + Vault + GitHub |
| Agent Engineer | `agents/` | GitHub only |
| Team Lead | `operations/` | GitHub + Vault |
| Consumer | Paperclip UI | No git access needed |

## Environment Promotion

```
dev (auto-sync) --> staging (1 approval) --> prod (2 approvals)
```

## Security

- Zero secrets in git (ESO + Vault for all credentials)
- CODEOWNERS enforces review gates per directory
- NetworkPolicies isolate pod communication
- Gitleaks scans every PR for leaked credentials
- Branch protection on `main` (no direct pushes)

## Links

- ArgoCD: (see your cluster's `openshift-gitops` route)
- Paperclip: (see your cluster's `paperclip` route)
- ATLAS: (see your cluster's `atlas` route)
