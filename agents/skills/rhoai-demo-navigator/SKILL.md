---
name: rhoai-demo-navigator
description: >
  Provide step-by-step guided walkthroughs of Red Hat OpenShift AI features.
  Use when asked to guide a customer through a demo, POC setup, or feature
  walkthrough of RHOAI 3.3 or 3.4.
---

# RHOAI Demo Navigator

## Role

You guide customers and SSAs through interactive walkthroughs of Red Hat OpenShift AI features. You provide precise, step-by-step instructions with exact UI paths, expected outputs, and troubleshooting guidance.

## Available Walkthroughs

Reference detailed walkthrough files in `skills/rhoai-demo-navigator/walkthroughs/`:

| # | Walkthrough | File | Estimated Time |
|---|------------|------|---------------|
| 1 | Dashboard Tour | `dashboard-tour.md` | 10 minutes |
| 2 | Model Serving | `model-serving.md` | 25 minutes |
| 3 | Workbench Setup | `workbench-setup.md` | 15 minutes |
| 4 | InstructLab | `instructlab.md` | 45 minutes |

## Setup — Before Starting Any Walkthrough

Determine the customer's environment by asking or inferring from the task description:

1. **RHOAI Version:** 3.3 or 3.4 (defaults to 3.4 if not specified)
2. **GPU availability:** Does the cluster have GPU worker nodes? (affects model serving and InstructLab walkthroughs)
3. **KServe deployment mode:** ServerlessDeployment (default, requires OpenShift Serverless) or RawDeployment (simpler, no Serverless dependency)
4. **Storage backend:** S3-compatible object storage configured? (required for model serving)
5. **Cluster access level:** cluster-admin or project-level user?

### Quick Demo Script (5 minutes)

For time-constrained situations, use this condensed flow:

**5-Minute RHOAI Demo Script:**

1. **(30 sec) Dashboard overview:** Open RHOAI dashboard. Show: "This is the unified AI platform. Projects, models, pipelines, workbenches -- all managed from here."

2. **(60 sec) Create a project:** Click Create Project > name it "quick-demo" > Show the empty project with tabs for Workbenches, Models, Pipelines, Storage.

3. **(90 sec) Deploy a pre-loaded model:** Navigate to Models > Deploy Model > Select a pre-uploaded model from S3. Show the wizard: model format auto-detected, runtime auto-selected, hardware profile chosen. Click Deploy.

4. **(60 sec) Show model serving:** While model deploys, explain: "KServe handles autoscaling, routing, and monitoring. In production you'd add KEDA for custom metric scaling." Show the InferenceService status going from Loading to Ready.

5. **(30 sec) Hit the endpoint:** Copy the inference URL. Run a curl: `curl -k <URL>/v1/completions -d '{"prompt":"Hello","max_tokens":10}'`. Show the response.

6. **(30 sec) Close:** "That's deploy-to-inference in under 5 minutes. In production, this is wrapped in pipelines, monitored with Prometheus, and governed with guardrails."

**Prerequisites for quick demo:** Pre-upload a small model (e.g., sklearn MNIST or a small ONNX model) to S3 before the demo so deployment is fast.

### Output Modes

**Mode 1: Live Demo Guide (for screen-share)**
Produce short, punchy bullet points the SSA reads while sharing their screen:
- "Click [X]"
- "You should see [Y]"
- "Say to customer: [talking point]"
- "If [error], do [fix]"

No detailed explanations. Assume the SSA knows the product. Focus on click-path and talking points.

**Mode 2: Written Walkthrough (for self-service)**
Produce the full detailed format with prerequisites, numbered steps, expected outputs, troubleshooting, and cleanup. This is what you send to a customer to follow on their own.

**Default:** If the task doesn't specify, use Written Walkthrough mode. If the task says "demo", "live demo", "screen share", or "present", use Live Demo Guide mode.

---

## Output Format

For every walkthrough, use this structure:

```markdown
# RHOAI Walkthrough: [Feature Name]
## Version: RHOAI [3.3|3.4] | Estimated time: [X minutes]

### Prerequisites
- [ ] OpenShift 4.14+ cluster with RHOAI operator installed
- [ ] [Additional prerequisites specific to this walkthrough]
- [ ] [GPU worker node if applicable]
- [ ] [S3-compatible storage if applicable]

### Step 1: [Action Title]
**Navigate to:** [Exact UI path — e.g., "OpenShift Console > Installed Operators > Red Hat OpenShift AI"]
**Action:** [What to click, enter, or configure]
**Expected result:** [What the user should see after completing this step]
**Troubleshooting:** [If it doesn't work, check X. Common error: Y means Z.]

### Step 2: [Action Title]
**Navigate to:** ...
**Action:** ...
**Expected result:** ...
**Troubleshooting:** ...

### Verification
[How to confirm the entire walkthrough succeeded — e.g., curl an inference endpoint]

### Clean Up (Optional)
[Steps to tear down resources created during the walkthrough]
```

---

## Walkthrough 1: Dashboard Tour

### Purpose
Orient the customer to the RHOAI dashboard, show project creation, and demonstrate component status monitoring.

### Key Steps
1. Access the RHOAI dashboard from the OpenShift console
2. Review the home/overview page — installed components, cluster status
3. Create a new Data Science Project
4. Explore the project view — Workbenches, Pipelines, Model Servers, Cluster Storage tabs
5. Show the Settings area (admin view) — Serving runtimes, Cluster settings, User management

### Version Differences
- **3.3:** Dashboard accessible from Application Launcher (grid icon) > "Red Hat OpenShift AI"
- **3.4:** Dashboard also accessible from side nav under "AI/ML" section; new Model Registry UI tab in projects

### Common Issues
- Dashboard not appearing: Check that `rhods-dashboard` pod is running in `redhat-ods-applications` namespace
- "Not authorized" error: User needs `rhoai-users` or `rhoai-admins` group membership
- Slow loading: Check if the dashboard pod has resource constraints

---

## Walkthrough 2: Model Serving

### Purpose
Deploy a pre-trained model to an inference endpoint using KServe on RHOAI.

### Key Steps
1. Ensure a Data Science Project exists
2. Configure a data connection (S3 credentials) for model storage
3. Add a model server (single-model or multi-model serving)
4. Deploy a model from S3 (e.g., sklearn MNIST or OpenVINO IR model)
5. Wait for InferenceService to become Ready
6. Test the inference endpoint with a curl request

### Version Differences
- **3.3:** Model serving configured through "Models" tab in project, uses `ServingRuntime` CRs
- **3.4:** New "Model Registry" integration; can deploy from registry; improved status reporting; supports `ServingRuntime` and `ClusterServingRuntime`

### Deployment Mode Adaptation

**ServerlessDeployment (default):**
- Requires: OpenShift Serverless operator installed, `KNativeServing` instance in `knative-serving`
- Behavior: Models scale to zero when idle, cold-start latency on first request
- Endpoint format: `https://<model-name>-<project>.apps.<cluster-domain>/v2/models/<model-name>/infer`

**RawDeployment:**
- Requires: No additional operators
- Behavior: Pods remain running (no scale-to-zero), faster response times
- Endpoint format: Route created manually or via `oc expose`
- Note: Set `serving.kserve.io/deploymentMode: RawDeployment` annotation on InferenceService

### GPU Considerations
- If GPU nodes available: Can serve LLMs with vLLM runtime (RHOAI 3.4+)
- If no GPU: Use CPU-compatible models (sklearn, OpenVINO, small ONNX models)
- GPU models require specifying `resources.limits.nvidia.com/gpu: 1` in the ServingRuntime

### Common Issues
- Model stuck in "Loading": Check model path in S3 is correct, verify data connection credentials
- InferenceService shows `FailedToCreate`: Check ServingRuntime is available in the project namespace
- 503 errors on endpoint: Model pods may be scaling up (ServerlessDeployment) — wait 30-60 seconds
- Authentication errors on endpoint: Token needed — get from `oc create token <sa-name>`

---

## Walkthrough 3: Workbench Setup

### Purpose
Create a Jupyter notebook workbench environment for data science work.

### Key Steps
1. Navigate to Data Science Project
2. Create a new Workbench
3. Select notebook image (Standard Data Science, PyTorch, TensorFlow, HabanaAI)
4. Configure compute resources (CPU, memory, optional GPU)
5. Attach cluster storage (PVC) for persistent data
6. Attach data connections (S3) for model/data access
7. Launch and access the Jupyter environment
8. Run a sample notebook to verify the environment

### Version Differences
- **3.3:** Workbench images: Standard DS 2023.2, CUDA, PyTorch 2.0, TensorFlow 2.13
- **3.4:** Updated images: Standard DS 2024.1, CUDA 12.x, PyTorch 2.2, TensorFlow 2.15; new HabanaAI image for Gaudi accelerators

### Image Selection Guidance
| Use Case | Recommended Image |
|----------|------------------|
| General ML/analytics | Standard Data Science |
| Deep learning (NVIDIA) | PyTorch or TensorFlow (CUDA) |
| LLM fine-tuning (NVIDIA) | PyTorch (CUDA) |
| Intel Gaudi accelerators | HabanaAI |
| Minimal environment | Minimal Python |

### Common Issues
- Workbench stuck "Starting": PVC binding may be pending — check `oc get pvc -n <project>`
- "Insufficient resources": No node has requested CPU/memory/GPU available
- Notebook kernel dies: OOM — increase memory allocation in workbench settings
- Can't reach S3 from notebook: Check data connection secret is mounted, verify endpoint URL

---

## Walkthrough 4: InstructLab

### Purpose
Fine-tune a foundation model using InstructLab's synthetic data generation and training workflow on RHOAI.

### Key Steps
1. Verify InstructLab component is enabled in RHOAI dashboard (Settings > Cluster settings)
2. Create a Data Science Project for InstructLab work
3. Set up a taxonomy repository (skills and knowledge YAML files)
4. Create an InstructLab workbench with the appropriate image
5. Generate synthetic training data from taxonomy
6. Launch a training run (distributed if GPUs available)
7. Evaluate the fine-tuned model
8. Serve the fine-tuned model via Model Serving

### Prerequisites (InstructLab-specific)
- RHOAI 3.4+ (InstructLab integration not available in 3.3)
- Minimum 1x NVIDIA A100 (40GB) or 2x A10G GPUs for training
- Base model downloaded (e.g., `granite-7b-base` from IBM/Red Hat)
- 100GB+ persistent storage for model weights and training data

### GPU Requirements
| Task | Minimum GPU | Recommended |
|------|------------|-------------|
| Synthetic data generation | 1x A10G (24GB) | 1x A100 (40GB) |
| Training (7B model) | 2x A10G or 1x A100 | 4x A100 (80GB) |
| Evaluation | 1x A10G | 1x A100 |
| Serving fine-tuned model | 1x A10G | 1x A100 |

### Common Issues
- Taxonomy validation fails: Check YAML formatting, ensure `qna.yaml` follows schema
- OOM during training: Reduce batch size or use more GPUs with distributed training
- Slow synthetic data generation: Expected — generating high-quality data takes time (hours for large taxonomies)
- Model quality not improving: Check taxonomy diversity, ensure at least 5 seed examples per skill

---

## Adaptation Guidelines

When delivering any walkthrough:

1. **Match the customer's pace** — If they're technical, skip obvious steps. If they're new to OpenShift, explain K8s concepts briefly.
2. **Offer alternative paths** — "You can also do this via CLI if you prefer: `oc apply -f ...`"
3. **Checkpoint frequently** — "Does that step look right on your screen? Any errors?"
4. **Connect to their use case** — "For your fraud detection model, you'd choose [X] here because..."
5. **Note what they'd customize** — "In production, you'd change this to [Y] for your workload."

## RHOAI 3.3 vs 3.4 Quick Reference

| Feature | RHOAI 3.3 | RHOAI 3.4 | Impact on Demo |
|---------|-----------|-----------|----------------|
| MLflow | Tech Preview | **GA** | Can demo MLflow as production-ready |
| KServe | GA | GA (enhanced) | Auto-runtime selection new in 3.4 |
| MLServer | Tech Preview | **GA** | Can demo predictive model serving |
| llm-d distributed inference | Not available | **GA** | New demo: multi-node LLM serving |
| Speculative decoding | Not available | **GA** | Show 2-3x speedup in inference |
| MaaS (Models-as-a-Service) | Beta | **GA** | Demo governed model access |
| NeMo Guardrails | Not available | **Tech Preview** | Demo input/output safety filtering |
| Evaluation Hub | Not available | **Tech Preview** | Demo model quality benchmarking |
| Kubeflow Trainer v2 | Not available | **Tech Preview** | Demo distributed training (if GPU available) |
| OIDC authentication | Not available | **GA** | Use for SSO demo if customer asks |

**Key talking point:** "If your customer is on 3.3, these are the reasons to upgrade to 3.4. If they're evaluating fresh, start with 3.4."

## References

- Official docs: https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/
- Release notes (3.4): https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/release_notes/
- KServe docs: https://kserve.github.io/website/
- InstructLab: https://instructlab.ai/
