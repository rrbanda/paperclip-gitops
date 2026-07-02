# Secrets Management

Secrets are NEVER stored in this repository. They are created manually on the cluster.

## Required Secrets

The `paperclip-secrets` Secret must exist in the `paperclip` namespace with these keys:

| Key | Description |
|-----|-------------|
| `POSTGRES_PASSWORD` | PostgreSQL password for the paperclip user |
| `DATABASE_URL` | Full postgres connection string: `postgres://paperclip:<password>@paperclip-db:5432/paperclip` |
| `BETTER_AUTH_SECRET` | 64-char hex string for auth token signing |

## Bootstrap

Run the bootstrap script to create secrets interactively:

```bash
./scripts/bootstrap-secrets.sh
```

Or create manually:

```bash
oc create secret generic paperclip-secrets \
  --namespace=paperclip \
  --from-literal=POSTGRES_PASSWORD='<your-password>' \
  --from-literal=DATABASE_URL='postgres://paperclip:<your-password>@paperclip-db:5432/paperclip' \
  --from-literal=BETTER_AUTH_SECRET='<64-char-hex>'
```

## Production: External Secrets Operator

For production, use the External Secrets Operator (already installed on this cluster) with a
SecretStore backed by HashiCorp Vault, AWS Secrets Manager, or Azure Key Vault. See the
OpenShift External Secrets documentation for setup.
