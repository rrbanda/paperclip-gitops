# System Architecture

## Component Topology

```
+-----------------------------------------------------------+
|                   OpenShift Cluster                        |
|  namespace: paperclip                                     |
|                                                           |
|  +------------------+       +------------------------+    |
|  |   Paperclip      |       |   PostgreSQL           |    |
|  |   (Deployment)   |------>|   (StatefulSet)        |    |
|  |                  |       |   - PVC: 10Gi          |    |
|  |  - REST API      |       +------------------------+    |
|  |  - Agent runtime |                                     |
|  |  - UI (Vite)     |       +------------------------+    |
|  +------------------+       |   ATLAS                |    |
|         |                   |   (Deployment)         |    |
|         |                   |   - Value dashboard    |    |
|  +------v-----------+       |   - KPI tracking       |    |
|  |   Route          |       +------------------------+    |
|  |   (TLS edge)     |                                     |
|  +------------------+       +------------------------+    |
|                             |   Eval Portal          |    |
|                             |   (Deployment)         |    |
|                             |   - Static HTML/nginx  |    |
|                             +------------------------+    |
+-----------------------------------------------------------+
```

## GitOps Flow

```
+------------+       +-------------+       +------------------+
|            |       |             |       |                  |
|  Developer |------>|   GitHub    |------>|   ArgoCD         |
|  (git push)|       |   (main)   |       |   (controller)   |
|            |       |             |       |                  |
+------------+       +------+------+       +--------+---------+
                            |                       |
                            |  webhook / 3min poll  |
                            +-----------------------+
                                                    |
                                                    v
                                    +---------------+---------------+
                                    |                               |
                                    v                               v
                            +-------+--------+       +-------------+------+
                            | K8s Resources  |       | PostSync Jobs      |
                            | (Deployments,  |       | - provision-users  |
                            |  Services,     |       | - sync-company     |
                            |  Routes, etc.) |       | - import-agents    |
                            +----------------+       +--------------------+
```

## Data Flow: Secrets

```
+----------------+       +---------------------+       +----------------+
|                |       |                     |       |                |
|  HashiCorp    |------>|  External Secrets   |------>|  K8s Secret    |
|  Vault        |       |  Operator (ESO)     |       |  (ephemeral)   |
|               |       |                     |       |                |
+----------------+       +---------------------+       +-------+--------+
                                                               |
     Vault path:                                               | volumeMount
     paperclip/secrets/db-password                             | or envFrom
     paperclip/secrets/auth-secret                             |
     paperclip/users/<username>                                v
                                                       +-------+--------+
                                                       |  Application   |
                                                       |  Pod           |
                                                       +----------------+

Flow: Vault --> ESO (ClusterSecretStore) --> ExternalSecret --> K8s Secret --> Pod
```

## Network Topology

```
                         Internet
                            |
                            v
                    +-------+--------+
                    |  OpenShift     |
                    |  Router (HAProxy)
                    +---+-------+---+
                        |       |
           TLS edge     |       |    TLS edge
          termination   |       |   termination
                        v       v
              +---------+--+ +--+-----------+
              | paperclip  | | atlas        |
              | Route      | | Route        |
              | *.apps...  | | *.apps...    |
              +-----+------+ +------+-------+
                    |               |
                    v               v
              +-----+------+ +-----+--------+
              | paperclip  | | atlas        |
              | Service    | | Service      |
              | :3100      | | :8080        |
              +-----+------+ +------+-------+
                    |               |
                    v               v
              +-----+------+ +-----+--------+
              | paperclip  | | atlas        |
              | Pod(s)     | | Pod(s)       |
              +------------+ +--------------+

NetworkPolicies:
  - paperclip -> postgres:  ALLOW (port 5432)
  - ingress -> paperclip:   ALLOW (port 3100, from router)
  - ingress -> atlas:       ALLOW (port 8080, from router)
  - default:                DENY all other inter-pod traffic
```

## Environment Matrix

| Environment | Namespace | Replicas | Resources | ArgoCD App |
|-------------|-----------|----------|-----------|------------|
| dev | paperclip-dev | 1 | 512Mi / 0.5 CPU | paperclip-dev |
| staging | paperclip-staging | 1 | 1Gi / 1 CPU | paperclip-staging |
| prod | paperclip | 2 | 2Gi / 2 CPU | paperclip-prod |
