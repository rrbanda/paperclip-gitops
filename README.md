# Paperclip GitOps

GitOps configuration for the Red Hat Americas AI Platform Team's Paperclip deployment on OpenShift.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  This Repository (source of truth)                  │
├─────────────────────────────────────────────────────┤
│  base/           → K8s manifests (Kustomize)        │
│  overlays/       → Environment-specific patches     │
│  company/        → Agents, skills, projects (md)    │
│  argocd/         → ArgoCD Application CR            │
│  scripts/        → Helper scripts                   │
│  secrets/        → Templates only (no real values)  │
└─────────────────────────────────────────────────────┘
         │                          │
         ▼                          ▼
┌─────────────────┐    ┌───────────────────────────┐
│  ArgoCD         │    │  paperclipai CLI           │
│  (auto-sync)    │    │  (manual or CI trigger)    │
│                 │    │                             │
│  Syncs: infra   │    │  Syncs: agents, skills,    │
│  (deploy, svc,  │    │  projects to Paperclip     │
│   route, pvc)   │    │  skill store + company     │
└────────┬────────┘    └─────────────┬─────────────┘
         │                           │
         ▼                           ▼
┌─────────────────────────────────────────────────────┐
│  OpenShift Cluster (paperclip namespace)            │
│  - PostgreSQL StatefulSet                           │
│  - Paperclip Deployment                            │
│  - Route (TLS edge)                                │
│  - Secrets (bootstrapped manually, not in git)     │
└─────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Bootstrap secrets (one-time)

```bash
./scripts/bootstrap-secrets.sh
```

### 2. Apply ArgoCD Application

```bash
oc apply -f argocd/paperclip-infra.yaml
```

ArgoCD will sync all infrastructure (Deployment, StatefulSet, Services, Routes, PVCs).

### 3. Sync company config

```bash
./scripts/import-company.sh
```

This imports agents, skills, and projects into the running Paperclip instance.

## Directory Structure

| Directory | Purpose | Sync Method |
|-----------|---------|-------------|
| `base/` | Canonical K8s manifests | ArgoCD auto-sync |
| `overlays/sandbox/` | Cluster-specific patches | ArgoCD auto-sync |
| `company/agents/` | Agent definitions (AGENTS.md) | `paperclipai company import` |
| `company/skills/` | Skill store source (SKILL.md) | `paperclipai skills import` |
| `company/projects/` | Project definitions | `paperclipai company import` |
| `argocd/` | ArgoCD Application CR | `oc apply` (one-time) |
| `secrets/` | Templates only | `bootstrap-secrets.sh` |
| `scripts/` | Helper scripts | Run manually or via CI |

## Making Changes

### Infrastructure changes (deployment, resources, env vars)

1. Edit files in `base/` or `overlays/sandbox/patches/`
2. Commit and push to `main`
3. ArgoCD auto-syncs within 3 minutes (or click "Sync" in ArgoCD UI)

### Agent changes (add/modify agents)

1. Edit or add `company/agents/<slug>/AGENTS.md`
2. Update `.paperclip.yaml` if adapter config or skill assignments change
3. Commit and push
4. Run `./scripts/import-company.sh`

### Skill changes

1. Edit `company/skills/<name>/SKILL.md`
2. Commit and push
3. Run `./scripts/import-company.sh` (skills are synced first)

### Adding a new environment

1. Create `overlays/<env-name>/kustomization.yaml`
2. Add patches for that environment
3. Create a new ArgoCD Application pointing at the new overlay

## Security

- **Zero secrets in git** -- all sensitive values are in OpenShift Secrets (bootstrapped manually)
- Paperclip's export pipeline automatically strips API keys, tokens, and passwords
- `.gitignore` prevents accidental secret commits
- ArgoCD ignores the `secrets/` directory
- External Secrets Operator (ESO) is available on the cluster for production-grade vault integration

## Cluster Access

- **ArgoCD UI**: https://openshift-gitops-server-openshift-gitops.apps.cluster-4l6x6.4l6x6.sandbox1213.opentlc.com
- **Paperclip UI**: https://paperclip-paperclip.apps.cluster-4l6x6.4l6x6.sandbox1213.opentlc.com
- **OpenShift Console**: https://console-openshift-console.apps.cluster-4l6x6.4l6x6.sandbox1213.opentlc.com

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/bootstrap-secrets.sh` | Create required secrets (interactive, one-time) |
| `scripts/export-company.sh` | Pull current company state from Paperclip to git |
| `scripts/import-company.sh` | Push company config from git to Paperclip |
