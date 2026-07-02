# DO NOT COMMIT THIS FILE WITH REAL VALUES
# This is a TEMPLATE showing the required secret shape.
# Use scripts/bootstrap-secrets.sh or Vault + ESO for actual secrets.
apiVersion: v1
kind: Secret
metadata:
  name: atlas-secrets
  namespace: paperclip
type: Opaque
stringData:
  AUTH_PASSWORD: "PLACEHOLDER_DO_NOT_COMMIT_REAL_VALUES"
