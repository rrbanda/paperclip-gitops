# Day-2 Operations Runbook

## Common Scenarios

### Add a User

1. Edit `operations/users.yaml` -- add the user entry.
2. Store password in Vault: `vault kv put paperclip/users/<username> password=<value>`
3. Commit, push, merge PR.
4. ArgoCD syncs; PostSync job provisions the account.
5. Verify: user can log in to Paperclip UI.

### Add an Agent

1. Create `agents/definitions/<slug>/AGENTS.md` with frontmatter and prompt.
2. Reference the agent in `operations/company.yaml` or the appropriate project file.
3. Assign skills in the AGENTS.md `desiredSkills` field.
4. Commit, push, merge PR.
5. Verify: agent appears on the Paperclip Agents page.

### Scale Up

1. Edit the environment patch (e.g. `platform/environments/prod/patches/resources.yaml`).
2. Increase CPU/memory limits or replica count as needed.
3. Commit, push, merge PR.
4. ArgoCD applies the new resource spec. Pods roll automatically.
5. Verify: `oc get pods -n paperclip` shows updated replicas.

### Rotate Secrets

1. Generate new credential value.
2. Update in Vault: `vault kv put paperclip/secrets/<key> value=<new-value>`
3. Trigger ESO refresh: `oc annotate externalsecret paperclip-secrets force-sync=$(date +%s) -n paperclip`
4. Restart affected pods: `oc rollout restart deployment/paperclip -n paperclip`
5. Verify: application logs show successful DB/auth connections.

---

## Troubleshooting

### Pod Not Starting

```bash
oc get events -n paperclip --sort-by='.lastTimestamp' | tail -20
oc describe pod <pod-name> -n paperclip
oc logs <pod-name> -n paperclip --previous
```

Common causes:
- **ImagePullBackOff**: Check image tag in deployment, verify registry access.
- **CrashLoopBackOff**: Check logs for missing env vars or DB connectivity.
- **Pending**: Check resource quota (`oc describe resourcequota -n paperclip`).

### ArgoCD Out of Sync

```bash
# Check sync status
argocd app get paperclip --refresh

# Force sync
argocd app sync paperclip --prune

# If sync fails on resource conflict
argocd app sync paperclip --force --replace
```

Common causes:
- Manual cluster edits that drift from git (fix: revert manual change or update git).
- Schema validation error in new manifests (fix: run `kustomize build` locally first).
- Finalizer blocking deletion (fix: remove finalizer manually if safe).

### DB Backup and Restore

**Create backup:**
```bash
oc exec statefulset/paperclip-db -n paperclip -- \
  pg_dump -U paperclip -Fc paperclip > backup-$(date +%Y%m%d).dump
```

**Restore from backup:**
```bash
oc exec -i statefulset/paperclip-db -n paperclip -- \
  pg_restore -U paperclip -d paperclip --clean --if-exists < backup-file.dump
```

**Verify restore:**
```bash
oc exec statefulset/paperclip-db -n paperclip -- \
  psql -U paperclip -c "SELECT count(*) FROM issues;"
```

---

## Emergency Procedures

### Rollback Deployment

```bash
# Immediate rollback to previous revision
oc rollout undo deployment/paperclip -n paperclip

# Rollback to specific revision
oc rollout history deployment/paperclip -n paperclip
oc rollout undo deployment/paperclip --to-revision=<N> -n paperclip

# In ArgoCD: sync to a previous git commit
argocd app sync paperclip --revision <commit-sha>
```

### Disaster Recovery

**Total cluster loss:**

1. Provision new OpenShift cluster.
2. Install ArgoCD operator.
3. Apply the ArgoCD ApplicationSet: `oc apply -f platform/argocd/appset-platform.yaml`
4. Bootstrap secrets: `./scripts/bootstrap-secrets.sh`
5. ArgoCD reconciles all resources from git.
6. Restore DB from latest backup (see above).
7. Verify: `curl <route>/api/health` returns 200.

**Namespace-level recovery:**

1. Delete and recreate namespace: `oc delete ns paperclip && oc create ns paperclip`
2. ArgoCD auto-heals within sync interval (or force: `argocd app sync paperclip`).
3. Re-bootstrap secrets if using manual secret creation.
4. Restore DB from backup.

### Incident Communication

1. Post in #paperclip-ops Slack channel immediately.
2. Page on-call platform engineer if cluster-level issue.
3. Update incident doc with timeline and resolution.
