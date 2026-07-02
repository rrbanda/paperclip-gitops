# DO NOT COMMIT THIS FILE WITH REAL VALUES
# This is a TEMPLATE showing the required secret shape.
# Use scripts/bootstrap-secrets.sh or Vault + ESO for actual secrets.
apiVersion: v1
kind: Secret
metadata:
  name: paperclip-secrets
  namespace: paperclip
type: Opaque
stringData:
  DATABASE_URL: "postgres://paperclip:PLACEHOLDER@paperclip-db:5432/paperclip"
  POSTGRES_PASSWORD: "PLACEHOLDER_DO_NOT_COMMIT_REAL_VALUES"
  BETTER_AUTH_SECRET: "PLACEHOLDER_GENERATE_WITH_openssl_rand_hex_32"
