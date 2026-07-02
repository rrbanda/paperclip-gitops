# Model Serving with KServe
## Version: RHOAI 3.4 | Estimated time: 20 minutes

### Prerequisites
- [ ] RHOAI 3.4 installed with KServe enabled
- [ ] GPU worker node (for LLM serving) or CPU workers (for predictive models)
- [ ] S3-compatible storage with a model uploaded (or use OCI image)
- [ ] Data Science Project created

### Step 1: Navigate to Model Serving
**Navigate to:** Data Science Projects > [your project] > Models
**Action:** Click "Deploy model"
**Expected result:** Deploy model wizard opens

### Step 2: Configure the Model
**Action in wizard:**
1. **Model name:** e.g., "granite-8b-demo"
2. **Model framework:** Select model type (the wizard auto-detects compatible runtimes)
3. **Model location:** Choose from:
   - S3 (provide bucket, endpoint, path)
   - OCI image (provide registry URI)
   - PVC (provide claim name and path)
4. **Serving runtime:** Auto-selected based on model type, or manually choose:
   - vLLM (for LLMs -- Llama, Granite, Mistral)
   - OpenVINO (for ONNX/IR models)
   - MLServer (for scikit, XGBoost, LightGBM)
5. **Hardware profile:** Select GPU type and count based on model size

**Talking point:** "The wizard analyzes your model and recommends the optimal runtime. You don't need to research compatibility -- RHOAI handles it."

### Step 3: Set Resources
**Action:** Configure:
- Replicas: 1 (for demo, scale up for production)
- GPU: 1x NVIDIA A100 (for Granite 8B)
- Memory: 32Gi
**Talking point:** "Hardware profiles are pre-configured by your admin. Data scientists select from approved profiles rather than guessing GPU requirements."

### Step 4: Deploy
**Action:** Click "Deploy"
**Expected result:** InferenceService created. Status shows "Loading" then "Ready" (1-3 minutes for small models)
**What to show while waiting:** The InferenceService status page with real-time progress

### Step 5: Test Inference
**Action:** Once status is "Ready", find the inference endpoint URL
**Test with curl:**
```bash
curl -k https://<inference-endpoint>/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "granite-8b-demo", "prompt": "Explain Kubernetes in one sentence:", "max_tokens": 50}'
```
**Expected result:** Model responds with generated text
**Talking point:** "The endpoint is OpenAI-compatible. Any application that works with OpenAI's API works here -- no code changes needed."

### Step 6: Show Monitoring (3.4)
**Navigate to:** Observe > Metrics (if Prometheus configured)
**What to show:** Request latency, throughput, GPU utilization
**Talking point:** "RHOAI 3.4 includes Prometheus metrics for llm-d and vLLM. You get production observability out of the box."

### Common Issues
- Model stuck in "Loading": Check GPU availability with `oc get nodes -l nvidia.com/gpu.present=true`
- Inference returns 503: Model not ready yet, or pod OOMKilled -- check `oc logs <serving-pod>`
- Authentication error: Check if route has token auth enabled in the deployment settings
