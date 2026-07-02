---
name: rfq-filler
description: >
  Fill out AI platform questionnaires and RFQs/RFIs using verified Red Hat AI
  product data. Use when given a questionnaire, RFQ, RFI, or security
  assessment to complete. References the RHOAI 3.4 product facts knowledge base.
---

# RFQ Filler

## Purpose

Complete customer questionnaires, RFQs (Request for Quote), RFIs (Request for Information), and security assessments accurately using verified Red Hat OpenShift AI 3.4 product data. Every answer must be specific, cite the relevant product or feature, and flag gaps honestly.

## Knowledge Base

The authoritative product facts file is:

```
skills/rfq-filler/rhoai-34-product-facts.md
```

Always load and reference this file before answering any question. Do not rely on general knowledge — use the facts file as the source of truth for version numbers, feature availability, certification status, and deployment options.

## Workflow

When given a questionnaire or RFQ document:

1. **Parse** — Extract every question or requirement line item. Preserve the original numbering, section structure, and format.
2. **Map** — For each question, search the product facts knowledge base for the relevant capability. Match on keywords: security, deployment, model support, MLOps, inference, training, safety, support, pricing.
3. **Answer** — Write a specific, accurate response. Include product names, version numbers, and feature names. Do not use generic marketing language.
4. **Cite** — For each answer, note the specific Red Hat product or feature that addresses the requirement (e.g., "OpenShift AI 3.4 — KServe GA", "RHEL 9.x — FIPS 140-2 validated").
5. **Flag gaps** — If Red Hat cannot fully meet a requirement, mark the answer with `[PARTIAL]` or `[GAP]` and explain what is and is not covered. Never claim a capability that does not exist.
6. **Format** — Match the original questionnaire format exactly. If the input is a table, output a table. If numbered questions, use the same numbering. If a spreadsheet-style grid, reproduce the grid structure.

## Category Reference

Use this reference to quickly locate answers in the product facts knowledge base:

### Security & Compliance
- FIPS 140-2: Validated on RHEL and OpenShift Container Platform
- SOC 2 Type II: OpenShift Container Platform
- FedRAMP: Pathway available via ROSA FedRAMP High
- HIPAA: Architecture-level support (BAA available with Red Hat)
- CVE patching: Published SLA for critical/important CVEs
- Supply chain: Sigstore-based image signing, SBOM generation

### Deployment Options
- On-premises: OpenShift Container Platform (bare metal, VMware, etc.)
- Public cloud managed: ROSA (AWS), ARO (Azure), RHOAI Cloud Service
- Hybrid: Consistent experience across on-prem and cloud via OpenShift
- Air-gapped: Disconnected install supported for OCP and RHOAI
- Edge: MicroShift, single-node OpenShift, RHEL AI at the edge

### Model Support
- Open model ecosystem: Granite (IBM), Llama (Meta), Mistral, custom models
- Not locked to a single model provider — bring any compatible model
- Model registry for versioning and governance
- InstructLab for model customization with synthetic data

### MLOps
- Kubeflow Pipelines 2.0 (GA in RHOAI 3.4)
- MLflow experiment tracking (GA)
- Model registry with lifecycle management
- Experiment tracking and comparison
- Data Science Projects for team workspace isolation

### Inference
- KServe (GA) — scalable model serving with autoscaling
- vLLM — high-throughput LLM inference
- llm-d — distributed inference for large models
- NVIDIA NIM integration
- MLServer for traditional ML models
- Custom serving runtimes supported

### Training
- Kubeflow Trainer v2 — distributed training orchestration
- InstructLab — knowledge and skills-based model customization
- Distributed training across GPU nodes
- AutoML capabilities via supported frameworks
- GPU sharing and scheduling (NVIDIA GPU Operator, AMD ROCm)

### AI Safety & Trustworthiness
- NeMo Guardrails integration for content filtering
- TrustyAI for bias detection and explainability
- Evaluation Hub for model quality assessment
- Garak for adversarial testing / red-teaming
- Model lineage tracking

### Support & SLAs
- 24x7 premium support available
- Multiple SLA tiers (Standard, Premium, Premium Plus)
- Dedicated Technical Account Manager (TAM) available
- Certified partner ecosystem for specialized needs

### Pricing
- Subscription-based pricing (not per-inference or per-API-call)
- Pricing scales with cluster size, not usage volume
- Contact Red Hat sales for formal quote
- Academic and startup programs available

## Answer Quality Rules

1. **Be specific.** "KServe GA in RHOAI 3.4 with autoscaling and canary deployments" — not "We support model serving."
2. **Include versions.** "RHEL 9.4 with FIPS 140-2 validated cryptographic modules" — not "We support FIPS."
3. **Acknowledge gaps.** If the customer asks about a feature Red Hat does not have, say so. Mark with `[GAP]` and suggest the closest alternative or partner solution.
4. **Use `[PARTIAL]` for partial coverage.** If Red Hat covers part of a requirement but not all, explain what is covered and what is not.
5. **Never fabricate certifications.** Only claim certifications that are documented in the product facts file.
6. **Differentiate GA vs Tech Preview.** Always note if a feature is GA (generally available) vs Tech Preview. Customers making procurement decisions need GA features.

## Output Format

Match the input format. Examples:

**If the input is a numbered questionnaire:**
```
1. Does your platform support FIPS 140-2?
   Answer: Yes. RHEL 9.x includes FIPS 140-2 validated cryptographic modules. OpenShift Container Platform inherits FIPS mode from the underlying RHEL nodes. RHOAI components run on FIPS-enabled OCP clusters.

2. What inference engines are supported?
   Answer: KServe (GA in RHOAI 3.4) for scalable model serving, vLLM for high-throughput LLM inference, llm-d for distributed inference across nodes, NVIDIA NIM for GPU-optimized inference, and MLServer for traditional ML workloads. Custom serving runtimes are also supported.
```

**If the input is a table:**
```
| # | Requirement | Response | Compliance | Notes |
|---|-------------|----------|------------|-------|
| 1 | FIPS 140-2 support | Yes | Full | RHEL 9.x validated modules; OCP inherits FIPS mode |
| 2 | Air-gapped deployment | Yes | Full | Disconnected install supported for OCP and RHOAI |
| 3 | Real-time inference SLA < 50ms | [PARTIAL] | Partial | KServe + vLLM achieve sub-50ms for small models; large LLMs depend on hardware and model size |
```

## Confidence Scoring

For each answer, assign a confidence level based on the source:

| Confidence | Criteria | How to display |
|-----------|---------|----------------|
| **HIGH** | Answer directly from verified product facts file with exact version/feature name | No marker needed (default) |
| **MEDIUM** | Inferred from related capabilities or general Red Hat platform knowledge | Mark: `[Confidence: Medium]` |
| **LOW** | Best-effort response based on general industry knowledge, not verified against product facts | Mark: `[Confidence: Low -- verify with Red Hat product team]` |

Include a confidence summary at the end of the completed questionnaire:
```markdown
### Response Confidence Summary
- High confidence answers: N (X%)
- Medium confidence answers: N (X%)  
- Low confidence answers: N (X%)
- Gaps flagged: N
```

## Multi-Format Handling

Enterprise RFQs arrive in many formats. Handle each:

| Format | How to process |
|--------|---------------|
| **Pasted text in task description** | Parse directly. Preferred format. |
| **Attached PDF** | Read from task attachments if available. If not parseable, ask user to paste key sections. |
| **Attached Excel/CSV** | Read column headers as questions, fill response columns. If not parseable, ask for paste. |
| **Attached Word document** | Read from attachment. If not parseable, ask for paste. |
| **Referenced URL** | Note: "Cannot access external URLs. Please paste the questionnaire content into the task description." |

When the format cannot be automatically parsed, respond with:
"I can see an attachment was provided but cannot parse it directly. Please paste the questionnaire questions into a comment on this task, and I'll complete them immediately."

## Compliance Matrix Template

For security-focused RFQs or formal compliance assessments, use this enhanced format instead of the standard Q&A:

```markdown
| # | Requirement | Status | Evidence | Red Hat Product | Version | Confidence |
|---|-------------|--------|----------|-----------------|---------|------------|
| 1 | FIPS 140-2 encryption | ✅ Met | RHEL FIPS validated crypto modules | RHEL | 9.4 | High |
| 2 | Air-gapped deployment | ✅ Met | Disconnected install with mirrored registries | OCP + RHOAI | 4.16 / 3.4 | High |
| 3 | Real-time inference < 10ms | ⚠️ Partial | Achievable for small models; large LLMs depend on hardware | RHOAI KServe | 3.4 | Medium |
| 4 | Multi-tenant data isolation | ❌ Gap | Namespace-level isolation only; no row-level data isolation | RHOAI | 3.4 | High |
```

Use this format when: the RFQ explicitly uses compliance terminology (SOC 2, FedRAMP, HIPAA, ISO 27001) or when the customer is in a regulated industry (FSI, healthcare, government, defense).

## Pre-Built Answers for Common Questions

These are the 10 most frequently asked questions in AI platform RFQs. Use these as templates and customize based on the specific customer's wording.

**Q1: Does the platform support FIPS 140-2?**
A: Yes. RHEL 9.x includes FIPS 140-2 validated cryptographic modules (certificate #4271). OpenShift Container Platform inherits FIPS mode from the underlying RHEL nodes when deployed with `fips=true` kernel parameter. RHOAI 3.4 components run on FIPS-enabled OCP clusters without modification. [Confidence: High]

**Q2: Can the platform be deployed in an air-gapped / disconnected environment?**
A: Yes. OpenShift supports fully disconnected installation using mirrored container registries. RHOAI operator and all components can be installed from a mirrored registry. Models can be stored locally or in OCI images. No internet connectivity required at runtime. [Confidence: High]

**Q3: What model formats and frameworks are supported?**
A: RHOAI 3.4 supports: PyTorch, TensorFlow, ONNX, SafeTensors, scikit-learn, XGBoost, LightGBM, and custom model formats. Foundation models from any provider (Granite/IBM, Llama/Meta, Mistral, custom) are supported through KServe and vLLM serving runtimes. The platform is not locked to a single model vendor. [Confidence: High]

**Q4: How is user access controlled?**
A: Access control operates at multiple layers: (1) OpenShift RBAC for cluster-level permissions, (2) RHOAI dashboard user/admin groups for application-level access, (3) Namespace-level isolation for data science projects, (4) OIDC/OAuth integration for SSO (GA in RHOAI 3.4), (5) Token authentication for model inference endpoints. [Confidence: High]

**Q5: What audit logging is available?**
A: OpenShift provides Kubernetes audit logs for all API server operations. RHOAI adds application-level logging for model deployments, pipeline executions, and workbench sessions. When integrated with a SIEM (via OpenShift Logging Operator), all agent and user actions are traceable. MLflow (GA in 3.4) provides experiment-level tracing including LLM calls, tool executions, and reasoning steps via OpenTelemetry. [Confidence: High]

**Q6: What is the pricing model?**
A: Red Hat AI uses subscription-based pricing tied to cluster size (node count), not per-inference or per-API-call. This provides predictable costs regardless of inference volume. No per-token fees, no per-seat fees for data scientists. Contact Red Hat sales for a formal quote based on your cluster configuration. [Confidence: High]

**Q7: What SLA and support options are available?**
A: Three tiers: Standard (business hours, next-business-day response for Severity 1), Premium (24x7, 1-hour response for Severity 1), Premium Plus (24x7, 15-minute response for Severity 1 + named Technical Account Manager). Red Hat publishes CVE response SLAs for critical and important security vulnerabilities. [Confidence: High]

**Q8: How does the platform handle model governance and lineage?**
A: MLflow (GA in RHOAI 3.4) provides experiment tracking, model versioning, and artifact management. Model Registry enables lifecycle management (staging, production, archived). OCI model cards capture governance metadata. Evaluation Hub (Tech Preview) provides quality benchmarking. TrustyAI provides bias detection and explainability metrics. [Confidence: High — note Eval Hub and TrustyAI are Tech Preview]

**Q9: What GPU accelerators are supported?**
A: Fully supported: NVIDIA A100 (40/80GB), NVIDIA H100 (80GB), NVIDIA L40S, AMD Instinct MI300X (192GB), Intel Gaudi 3 (128GB), IBM Spyre. Also supported for inference: NVIDIA T4, NVIDIA V100. GPU management via NVIDIA GPU Operator (automatic driver installation, monitoring, MIG partitioning) or AMD ROCm. [Confidence: High]

**Q10: Can the platform run in multiple cloud environments and on-premises?**
A: Yes. OpenShift AI runs identically on: bare metal on-premises, VMware vSphere, AWS (self-managed or ROSA), Azure (self-managed or ARO), GCP (self-managed), IBM Cloud. The same RHOAI operator, dashboard, and tooling work across all environments. Models trained on-prem can be served in cloud, and vice versa, with no code changes. [Confidence: High]
