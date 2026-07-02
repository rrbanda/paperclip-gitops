---
name: pitch-builder
description: >
  Create customer-specific AI platform pitch decks and presentations.
  Use when asked to prepare a pitch, presentation, or meeting materials
  for a specific customer or industry.
---

# Pitch Builder

## Purpose

Generate tailored AI platform pitch materials for specific customer accounts. Each pitch is customized to the customer's industry, tech stack, pain points, and competitive landscape — never a generic slide deck.

## Account Intelligence

### Retrieve account context

```bash
python3 scripts/mock-account-intel.py --account "<CustomerName>"
```

**Script location:** The script is at the repository root. Try these paths in order:
1. `python3 scripts/mock-account-intel.py --account "<CustomerName>"`
2. `python3 /app/scripts/mock-account-intel.py --account "<CustomerName>"`

**If the script is not accessible:** Ask the user to provide account context directly. The pitch can be built from user-provided information -- the script is an enrichment source, not a requirement.

**Required fields if script unavailable:**
- Customer name and industry
- Company size (employees or revenue band)
- Known cloud/tech stack
- Competitors they are evaluating
- Meeting attendee roles

Returns structured account data: industry, company size, known tech stack, current AI initiatives, competitive evaluations in progress, key contacts, recent interactions, and pain points.

If the customer name is not found in mock data, ask the user to provide:
- Industry vertical
- Company size (employees, revenue band)
- Known tech stack (cloud provider, container platform, ML tools)
- Known pain points or AI goals
- Competitors they are evaluating
- Meeting attendee roles (CTO, VP Eng, data science lead, procurement, etc.)

## Pitch Structure

Generate a structured pitch document in this format:

```markdown
# AI Platform Pitch: [Customer Name]
## Prepared for: [Meeting Date] | [Attendee Roles]

### 1. Opening Hook
[Industry-specific AI challenge that resonates with this customer's business]

Frame the hook around a quantifiable business problem in their industry. Examples:
- Financial services: "Banks using manual model validation spend 6-12 months per model. Your competitors are automating this."
- Healthcare: "Clinical AI models require FDA-grade audit trails. Most platforms can't provide them."
- Telco: "Network optimization AI needs sub-10ms inference at the edge. Cloud-only platforms can't deliver."

### 2. The Problem (Their World)
- Current AI challenges specific to [industry]
- Pain points based on their known tech stack
- Cost/risk of status quo

Tailor this section using the account intel. If they run Kubernetes but not OpenShift, emphasize the operational burden of self-managed ML infrastructure. If they use a competitor's AI platform, name the specific limitations they are likely hitting.

### 3. Red Hat AI Portfolio (Our Solution)
Map specific products to their needs:
- OpenShift AI → [their specific use case]
- RHEL AI → [if relevant: edge inference, disconnected environments, developer workstations]
- InstructLab → [if model customization needed: domain-specific models, proprietary data fine-tuning]
- Ansible Lightspeed → [if IT automation relevant: infrastructure-as-code, runbook automation]

Only include products relevant to this customer. Do not list the entire portfolio.

### 4. Why Red Hat (Not [Competitor])
Differentiation against their likely alternatives:
- vs [competitor they're evaluating]: [specific advantage]
- Open source advantage for [their concern]
- Hybrid cloud for [their infrastructure reality]

Common competitive positions:
- vs AWS SageMaker: Multi-cloud portability, no cloud lock-in, on-prem support, open model ecosystem
- vs Azure ML: OpenShift runs on Azure (ARO) + on-prem + AWS; avoid single-cloud dependency
- vs Databricks: Kubernetes-native MLOps, integrated with existing OCP investment, subscription pricing vs consumption
- vs Google Vertex AI: On-prem capability, air-gapped support, FIPS/FedRAMP pathway
- vs NVIDIA AI Enterprise: Red Hat is NVIDIA's #1 partner; RHOAI integrates NIM, GPU Operator; no separate NVIDIA platform license needed
- vs Open source DIY (Kubeflow, MLflow, etc.): Red Hat productizes and supports these upstream projects with enterprise SLAs, CVE patching, and certified integrations

### Detailed Competitive Differentiators

When the customer names a specific competitor, use these detailed comparisons (3-4 points each):

**vs AWS SageMaker (detail):**
1. **Multi-cloud portability:** RHOAI runs on AWS, Azure, GCP, and on-prem. SageMaker is AWS-only. If the customer adds a second cloud or needs on-prem, they rebuild everything.
2. **Pricing model:** RHOAI subscription vs SageMaker per-instance-hour + per-inference. At scale (>50K inferences/day), RHOAI is typically 40-60% cheaper.
3. **Open model ecosystem:** RHOAI serves any model (Granite, Llama, Mistral, custom). SageMaker pushes Bedrock/Titan. InstructLab has no SageMaker equivalent.
4. **Kubernetes-native:** If they already run EKS or OpenShift, RHOAI integrates. SageMaker is a parallel silo with its own compute, networking, and IAM.

**vs Databricks (detail):**
1. **MLflow compatibility:** RHOAI ships MLflow GA -- same API, zero migration for existing experiments. Databricks customers can move MLflow data directly.
2. **Infrastructure ownership:** RHOAI on customer's OCP cluster = they own the infra. Databricks = they rent compute at Databricks markup.
3. **On-prem capability:** Databricks has no on-prem story. RHOAI runs identically on bare metal in your data center.
4. **LLM serving cost:** vLLM on RHOAI = no per-token markup. Databricks Foundation Model APIs = per-token pricing on top of compute.

**vs Google Vertex AI (detail):**
1. **Same Kubeflow upstream:** RHOAI and Vertex both use Kubeflow Pipelines. Migration is straightforward -- same pipeline SDK.
2. **Data sovereignty:** Vertex requires data in GCP. RHOAI keeps data wherever the customer's OCP cluster runs.
3. **Model flexibility:** Vertex pushes Gemini. RHOAI is model-agnostic with open runtimes.
4. **Hybrid cloud:** Vertex on Anthos is complex and limited. RHOAI on OCP works consistently across any environment.

**vs NVIDIA AI Enterprise (detail):**
1. **Red Hat is NVIDIA's #1 enterprise partner:** GPU Operator, NIM runtime, and AI Enterprise are certified on RHEL + OpenShift.
2. **No separate platform license:** RHOAI includes NVIDIA GPU Operator integration. Customers don't need a separate NVIDIA AI Enterprise subscription for basic GPU management.
3. **Broader MLOps:** NVIDIA AI Enterprise focuses on inference optimization. RHOAI provides full MLOps lifecycle (training, experimentation, pipelines, serving, monitoring).
4. **Complementary, not competitive:** Position RHOAI as the platform that makes NVIDIA GPUs enterprise-ready, not as an alternative to NVIDIA.

### 5. Proof Points
- [Industry] customer success story
- Relevant metrics and outcomes
- Reference customer (if available)

Use proof points from the same industry when possible. If no exact industry match, use a customer with similar scale, regulatory environment, or technical requirements.

### 6. Recommended Next Steps
- [ ] 30-minute technical deep dive on [most relevant topic for this customer]
- [ ] 2-week POC scope: [specific workload they could test — e.g., "deploy Granite model for document classification on their existing OCP cluster"]
- [ ] Architecture review of their [current ML stack / data pipeline / inference infrastructure]

Make next steps concrete and low-friction. The goal is to advance the deal, not to propose a 6-month engagement.

### 7. Appendix
- Technical specifications relevant to their requirements
- Pricing guidance (contact Red Hat for formal quote)
- Links to documentation and trial access
```

## Workflow

1. Run the account intel script to retrieve customer context.
2. If data is insufficient, ask the user for the missing fields listed above.
3. Identify the top 2-3 pain points that Red Hat AI can address.
4. Select the most relevant Red Hat products (do not dump the entire portfolio).
5. Identify the primary competitor(s) and prepare specific differentiation points.
6. Find the best-fit customer proof point / case study.
7. Draft the pitch using the structure above.
8. Review for accuracy: do not claim capabilities that do not exist. When uncertain about a product fact, reference the RFQ Filler agent's knowledge base at `skills/rfq-filler/rhoai-34-product-facts.md`.

## Customization by Attendee Role

Adjust emphasis based on who will be in the meeting:

| Attendee Role | Emphasize |
|---------------|-----------|
| CTO / VP Engineering | Architecture, scalability, open source strategy, avoiding lock-in |
| Data Science Lead | Model support, experiment tracking, notebook experience, MLOps workflow |
| CISO / Security | Compliance certs, air-gapped support, supply chain security, guardrails |
| Procurement / Finance | Subscription pricing model, TCO comparison, support SLAs |
| Line of Business | Business outcomes, time-to-value, industry proof points |

## Industry-Specific Pitch Templates

Use these pre-built hooks and pain points based on the customer's industry. Select the matching industry and adapt.

**Financial Services (FSI)**
- Hook: "Banks validating AI models spend 6-12 months per model under SR 11-7. Red Hat AI cuts that to weeks with automated evaluation and governance."
- Pain points: Model governance under regulatory scrutiny, data sovereignty for financial data, multi-cloud risk, explainability requirements
- Key products: OpenShift AI (MLOps + model registry), Evaluation Hub (model validation), TrustyAI (explainability), air-gapped deployment
- Proof point: "Global banks run OpenShift in production for trading systems. RHOAI extends that trusted platform to AI workloads."
- Competitor weakness: SageMaker can't run on-prem; Databricks lacks air-gapped support

**Healthcare**
- Hook: "Clinical AI models need FDA-grade audit trails and HIPAA-compliant infrastructure. Most AI platforms can't provide both."
- Pain points: PHI data residency, HIPAA compliance, clinical model validation, integration with EHR systems, on-prem requirements for patient data
- Key products: RHOAI on-prem (data never leaves hospital), RHEL AI (edge inference at point of care), NeMo Guardrails (PII/PHI filtering)
- Proof point: "Healthcare systems run OpenShift for clinical applications. RHOAI brings AI to the same governed infrastructure."
- Competitor weakness: Cloud-only platforms can't guarantee PHI stays on-premises

**Telco**
- Hook: "5G network optimization needs sub-10ms inference at the cell edge. Cloud-round-trips are too slow."
- Pain points: Edge deployment at scale (thousands of sites), latency requirements, network function integration, cost of GPU at edge
- Key products: RHOAI + MicroShift (edge AI), KServe RawDeployment (no Knative at edge), vLLM with speculative decoding
- Proof point: "Telcos run OpenShift for network functions today. RHOAI runs AI workloads on the same edge infrastructure."
- Competitor weakness: SageMaker/Vertex have no edge story; Databricks is cloud-only

**Public Sector**
- Hook: "FedRAMP, FIPS 140-2, ITAR, air-gapped -- your AI platform must meet the same bar as your other mission systems."
- Pain points: Security certifications, air-gapped environments, ITAR data handling, IL4/IL5 classification, procurement complexity
- Key products: RHOAI on OCP (FedRAMP pathway via ROSA GovCloud), FIPS-validated RHEL, air-gapped install, STIG hardening
- Proof point: "Federal agencies run OpenShift for mission-critical workloads with ATO. RHOAI extends that authority to AI."
- Competitor weakness: Most AI platforms lack FedRAMP authorization or air-gapped support

**Manufacturing**
- Hook: "Quality inspection AI needs to run on the factory floor, not in the cloud. Latency and connectivity gaps mean cloud-only AI misses defects."
- Pain points: Edge inference for quality inspection, predictive maintenance, supply chain optimization, OT/IT convergence, limited connectivity
- Key products: RHOAI + single-node OpenShift (factory floor), RHEL AI (bare-metal edge), vLLM for document processing
- Proof point: "Manufacturers run OpenShift for industrial IoT. RHOAI adds AI to the same edge-to-cloud architecture."
- Competitor weakness: Cloud platforms require reliable connectivity; factory floors often have intermittent or no cloud access

## Cross-Agent Integration

This skill may be invoked by the **OpenShift Attach Monitor** when it identifies high-priority unattached accounts. When triggered by another agent, the account context is provided in the delegation request — use it directly instead of running the account intel script.

## Quality Checklist

Before delivering the pitch:

- [ ] Every product claim is accurate and reflects GA (not Tech Preview) capabilities
- [ ] Competitor comparisons are factual, not dismissive
- [ ] Next steps are concrete with specific workloads and timelines
- [ ] Proof points are from a relevant industry or analogous use case
- [ ] Pricing section directs to Red Hat sales (never quote specific dollar amounts)
- [ ] Pitch length is appropriate for the meeting format (15-min overview vs 60-min deep dive)

## Output Variants

Adapt pitch length to the meeting format:

**15-Minute Executive Pitch:**
- Sections 1-3 only (Hook, Problem, Solution)
- Skip appendix
- One competitor comparison (the primary threat)
- One proof point
- End with a single clear next step

**30-Minute Standard Pitch:**
- Full 7-section template
- Include top 2 competitors
- 2 proof points
- Detailed next steps

**60-Minute Deep Dive:**
- Full 7-section template with expanded technical detail
- All relevant competitors compared
- Live demo recommendations embedded in the pitch
- Technical appendix with architecture diagrams, sizing estimates
- Q&A prep section: anticipated questions and prepared answers
