# Paperclip GitOps Operating Model

## Producer / Consumer Framework

This repository follows a **producer/consumer operating model** where platform builders maintain infrastructure and agent definitions via git, while end-users consume agent services through the Paperclip UI without needing git or cluster access.

---

## Roles

### Producers (Build and Maintain)

| Role | Owns | Access Required |
|------|------|-----------------|
| **Platform Engineer** | `base/`, `overlays/`, `argocd/`, `secrets/` | Cluster admin, Vault, GitHub |
| **Agent Engineer** | `company/agents/`, `company/skills/` | GitHub only |
| **Team Lead** | `users.yaml`, `company/projects/`, routines in `.paperclip.yaml` | GitHub + Vault |

### Consumers (Use and Request)

| Role | Interface | Actions |
|------|-----------|---------|
| **Sales Rep / SSA** | Paperclip UI | Create tasks, view outputs |
| **Sales Manager** | Paperclip UI + ATLAS | Review dashboards, approve actions |
| **Executive** | ATLAS Dashboard | View KPIs, ROI metrics |

---

## Producer Workflows

### Platform Engineer

| Action | File to Edit | Frequency |
|--------|--------------|-----------|
| Scale resources | `overlays/sandbox/patches/deployment-env.yaml` | As needed |
| Add new environment | `overlays/<env>/kustomization.yaml` | Per cluster |
| Update PostgreSQL | `base/postgres-statefulset.yaml` | Quarterly |
| Manage network rules | `base/network-policies.yaml` | On change |
| Rotate secrets | Vault (never git) | Quarterly |
| Configure alerts | `base/monitoring.yaml` | As needed |
| Manage CI/CD | `base/tekton-pipelines.yaml` | On change |

### Agent Engineer

| Action | File to Edit | Frequency |
|--------|--------------|-----------|
| Create agent | `company/agents/<slug>/AGENTS.md` + `.paperclip.yaml` | Per agent |
| Update agent behavior | `company/agents/<slug>/AGENTS.md` body | Iterative |
| Create/update skill | `company/skills/<name>/SKILL.md` | Per skill |
| Assign skills | `.paperclip.yaml` desiredSkills | Per assignment |
| Set delegation chain | `.paperclip.yaml` reportsTo | Per reorg |

**Workflow:**
```
git checkout -b add-new-agent
# Create AGENTS.md + update .paperclip.yaml
git push -> PR -> review -> merge to main
# ArgoCD syncs -> PostSync Job imports -> agent appears in Paperclip
```

### Team Lead

| Action | File to Edit | Frequency |
|--------|--------------|-----------|
| Add team member | `users.yaml` + password in Vault | Per hire |
| Create project | `company/projects/<slug>/PROJECT.md` | Per initiative |
| Set up routines | `.paperclip.yaml` routines section | Per cadence |
| Adjust org chart | `.paperclip.yaml` reportsTo | Per reorg |

---

## Consumer Guide

### Sales Rep / SSA (No git access needed)

| I want to... | How |
|--------------|-----|
| Get a pitch deck built | Paperclip UI -> New Task -> assign to "Pitch Builder" |
| Fill out an RFQ | Paperclip UI -> New Task -> assign to "RFQ Response Agent" |
| Practice a sales call | Paperclip UI -> New Task -> assign to "Sales Simulation Engine" |
| Get meeting prep | Paperclip UI -> New Task -> assign to your personal "CoS" agent |
| Check my task status | Paperclip UI -> Issues board -> filter by "assigned to me" |

### Sales Manager

| I want to... | How |
|--------------|-----|
| See weekly pipeline report | Paperclip UI -> Done tasks from "Sales Progress Monitor" |
| Check attach rates | Paperclip UI -> Done tasks from "OpenShift Attach Monitor" |
| Approve a cluster command | Paperclip UI -> Approvals queue |
| Track team productivity | ATLAS Dashboard -> Value Dashboard |

### Executive

| I want to... | How |
|--------------|-----|
| View pilot KPIs | ATLAS Dashboard (your cluster's `atlas` route) |
| Review business case | ATLAS -> Business Case page |
| See the agent org chart | Paperclip UI -> Agents page |

---

## Change Flow

```
Producer edits file in git
        |
        v
Push to main (or PR -> merge)
        |
        v
ArgoCD detects change (webhook or 3-min poll)
        |
        v
ArgoCD syncs K8s resources (infra changes)
        |
        v
PostSync Jobs fire (company config, skills, users)
        |
        v
Paperclip updated (agents/skills/users appear)
        |
        v
Consumers see changes in Paperclip UI
```

---

## Branch Strategy

| Branch | Purpose | Who Merges |
|--------|---------|------------|
| `main` | Production (auto-synced by ArgoCD) | Team Lead or Platform Eng |
| `feat/<slug>` | New agent/skill development | Agent Engineer via PR |
| `infra/<slug>` | Infrastructure changes | Platform Engineer via PR |

---

## What Lives Where

| Data | Location | GitOps? |
|------|----------|---------|
| Infrastructure | This repo (`base/`, `overlays/`) | Yes - ArgoCD |
| Agents | This repo (`company/agents/`) | Yes - PostSync |
| Skills | This repo (`company/skills/`) | Yes - PostSync |
| Projects | This repo (`company/projects/`) | Yes - PostSync |
| Routines | This repo (`.paperclip.yaml`) | Yes - PostSync |
| Users | This repo (`users.yaml`) | Yes - PostSync |
| Passwords | HashiCorp Vault | No - manual |
| Tasks (work items) | Paperclip DB | No - runtime |
| Agent history | Paperclip DB | No - operational |
| KPIs | ATLAS (computed) | No - derived |

---

## Day-2 Operations

| Scenario | Who | Action |
|----------|-----|--------|
| New team member | Team Lead | Add to `users.yaml`, store password in Vault, push |
| New agent needed | Agent Engineer | Create `AGENTS.md` + `.paperclip.yaml` entry, PR, merge |
| Skill update | Agent Engineer | Edit `SKILL.md`, push |
| Scale up | Platform Engineer | Edit overlay resource patch, push |
| New cluster | Platform Engineer | New overlay + ArgoCD App + bootstrap secrets |
| Disaster recovery | Platform Engineer | Apply ArgoCD to new cluster + restore DB backup |
| Agent misbehaving | Agent Engineer | Fix prompt in `AGENTS.md`, push |
| Password rotation | Platform Engineer | Update Vault, restart pods |

---

## Security Boundaries

| Data | Where it NEVER appears |
|------|------------------------|
| Passwords | Git, ArgoCD UI, pod logs, ConfigMaps |
| API keys | Git (auto-stripped by Paperclip export) |
| Vault tokens | Git, application pods |
| User PII beyond email/name | Git |

All secrets flow: **Vault -> ESO -> K8s Secret -> Pod mount (ephemeral)**
