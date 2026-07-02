# Red Hat OpenShift AI 3.4 -- Verified Product Facts

Use these facts when answering RFQ/RFI questions. All data points are from official Red Hat documentation and release notes (June 2026).

## Product Identity

- **Full name:** Red Hat OpenShift AI Self-Managed 3.4
- **Also known as:** RHOAI, Red Hat AI
- **Latest version:** 3.4.1 (GA June 2026)
- **License:** Commercial subscription (Red Hat)
- **Open source upstream:** Open Data Hub (ODH)
- **Requires:** Red Hat OpenShift Container Platform 4.14+ (4.16+ recommended for llm-d)

## Deployment Options

- On-premises (any OCP cluster)
- AWS (ROSA, self-managed OCP on EC2)
- Azure (ARO, self-managed OCP on Azure)
- GCP (self-managed OCP on GCP)
- IBM Cloud (OCP on IBM Cloud, KubeRay + Llama Stack on IBM Power)
- Air-gapped / disconnected (supported with mirrored registries)
- Edge (KServe RawDeployment for lightweight serving)

## Core Components (GA in 3.4)

| Component | Status | What it does |
|-----------|--------|-------------|
| Dashboard | GA | Web UI for project management, model deployment, workbenches |
| KServe (model serving) | GA | Single-model serving with dedicated servers (ServerlessDeployment + RawDeployment) |
| MLServer | GA | Serving runtime for predictive/classical ML models (scikit, XGBoost, LightGBM) |
| vLLM | GA | High-throughput LLM serving runtime with PagedAttention |
| llm-d | GA | Distributed inference across multiple vLLM pods with Endpoint Picker (EPP) |
| Kubeflow Pipelines 2.0 | GA | ML workflow automation with Docker containers |
| MLflow | GA | Experiment tracking, model registry, artifact management |
| Jupyter Workbenches | GA | JupyterLab-based development environments |
| CodeFlare + KubeRay | GA | Distributed computing with Ray |
| Models-as-a-Service (MaaS) | GA | Governed self-service access to foundation models |
| OIDC authentication | GA | Direct authentication with OIDC identity providers |
| Speculative decoding | GA | 2-3x inference speedup with draft model verification |

## Technology Preview Features (3.4)

| Feature | Status | What it does |
|---------|--------|-------------|
| Llama Stack Operator | TP | Agentic AI runtime with RAG and OpenAI-compatible APIs |
| MCP Catalog | DP | Discover and deploy trusted MCP servers |
| MCP Gateway | TP | Centralized auth and tool-level access control for MCP |
| Evaluation Hub | TP | Unified AI evaluation control plane (LM-Eval, Garak, RAGAS) |
| NeMo Guardrails | TP | Runtime input/output safety filtering |
| TrustyAI Guardrails Orchestrator | TP | Orchestrate multiple safety detectors |
| Kubeflow Trainer v2 | TP | Next-gen distributed training with TrainJob API |
| Feature Store | TP | Feature ingestion, transformation, serving |
| KEDA autoscaling | TP | Scale based on custom metrics |
| Evaluation Stack UI | TP | Guided evaluation workflow in dashboard |

## Security and Compliance

- **Base OS:** Red Hat Enterprise Linux (FIPS 140-2 validated cryptographic modules)
- **Container platform:** OpenShift (NIST 800-53 controls, DISA STIG, CIS Benchmarks)
- **FedRAMP:** Pathway through OpenShift (ROSA GovCloud is FedRAMP High authorized)
- **SOC 2:** OpenShift platform level
- **HIPAA:** Architecture-level compliance (data residency via on-prem deployment)
- **EU AI Act:** Evaluation Hub provides risk assessment evidence
- **CVE patching:** Red Hat SLA-backed security updates
- **Agent API keys:** Hashed at rest (SHA-256)
- **Secrets:** Encrypted at rest (local AES or AWS Secrets Manager)
- **RBAC:** OpenShift native RBAC + RHOAI dashboard user management
- **Audit:** Activity logging for all mutating actions
- **Air-gapped:** Fully supported with mirrored registries and OCI model images

## Supported Hardware Accelerators

| Accelerator | Support level |
|------------|--------------|
| NVIDIA A100 (40GB/80GB) | Fully supported |
| NVIDIA H100 (80GB) | Fully supported |
| NVIDIA L40S | Fully supported |
| AMD Instinct MI300X (192GB) | Fully supported |
| Intel Gaudi 3 (128GB) | Fully supported |
| IBM Spyre | Supported (3.4) |
| NVIDIA T4 | Supported (inference only) |

## Support

- **Support model:** Red Hat subscription with 24x7 premium support option
- **SLA:** Standard (business hours) or Premium (24x7 with 1-hour critical response)
- **TAM:** Technical Account Manager available as add-on
- **Lifecycle:** Follows Red Hat product lifecycle (typically 3+ years per major version)
- **Training:** Red Hat Training courses available (DO480, AI290)

## Pricing

- **Model:** Subscription-based per cluster/node (NOT per-inference or per-token)
- **No per-API-call fees:** Unlike cloud AI services
- **Includes:** Platform + support + security updates
- **LLM costs:** Customer-managed (bring your own models, use open source Granite/Llama/Mistral)
- **Quote:** Contact Red Hat sales or partner for specific pricing
