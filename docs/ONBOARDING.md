# New Team Member Onboarding

## Prerequisites

Before you start, ensure you have:

- GitHub account with access to this repository
- `oc` CLI installed and configured (OpenShift 4.x client)
- Access to the Red Hat VPN (for cluster connectivity)
- A password manager for storing your Paperclip credentials

## Getting Paperclip UI Access

1. Ask your team lead to add your entry to `operations/users.yaml`:

```yaml
- email: you@redhat.com
  name: Your Name
  role: member
```

2. Your team lead stores your initial password in Vault at `paperclip/users/<username>`.
3. Once the PR merges, ArgoCD syncs within 3 minutes. The PostSync job provisions your account.
4. Log in at the Paperclip UI route (check `platform/base/core/paperclip-route.yaml` for the URL).
5. Change your password on first login.

## Creating Your First Task

1. Open the Paperclip UI and navigate to the Issues board.
2. Click "New Task".
3. Fill in title and description. Assign to the appropriate agent (see org chart in UI).
4. Submit. The assigned agent picks up work automatically.

## Where to Find Documentation

| Document | Location |
|----------|----------|
| Operating model | `docs/OPERATING-MODEL.md` |
| Architecture | `docs/ARCHITECTURE.md` |
| Runbook (day-2 ops) | `docs/RUNBOOK.md` |
| Agent definitions | `agents/definitions/<slug>/AGENTS.md` |
| Skills reference | `agents/skills/<name>/SKILL.md` |
| Platform manifests | `platform/` |
| Secrets guide | `secrets/README.md` |

## Contacts

| Role | Person | Responsibilities |
|------|--------|-----------------|
| Platform Engineer | (TBD) | Cluster ops, secrets, scaling, DR |
| Agent Engineer | (TBD) | Agent prompts, skills, adapter config |
| Team Lead | Raghuram Banda | User access, projects, org structure |
| Sales Operations | Monica Livingston | Business priorities, approval gates |
