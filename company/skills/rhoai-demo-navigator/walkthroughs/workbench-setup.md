# Jupyter Workbench Setup
## Version: RHOAI 3.4 | Estimated time: 10 minutes

### Prerequisites
- [ ] RHOAI installed with Jupyter component enabled
- [ ] Data Science Project created
- [ ] (Optional) GPU node for accelerated notebooks

### Step 1: Create Workbench
**Navigate to:** Data Science Projects > [your project] > Workbenches > Create workbench
**Action:** Configure:
1. **Name:** e.g., "data-exploration"
2. **Image:** Select from available images:
   - Standard Data Science (Python, pandas, scikit-learn, matplotlib)
   - PyTorch (CUDA-enabled)
   - TensorFlow (CUDA-enabled)
   - Minimal Python
3. **Container size:** Small (2 CPU, 8Gi) for demo, or larger for real work
4. **GPU:** 0 for data exploration, 1+ for training
5. **Storage:** Create new PVC (e.g., 20Gi) or attach existing

**Expected result:** Workbench pod starts (30-60 seconds)

### Step 2: Open JupyterLab
**Action:** Click "Open" link once workbench status shows "Running"
**Expected result:** JupyterLab opens in new tab with file browser and launcher

### Step 3: Run a Demo Notebook
**Action:** Open a terminal in JupyterLab and clone a demo repo:
```bash
git clone https://github.com/rh-aiservices-bu/llm-on-openshift.git
```
**Navigate to:** `llm-on-openshift/examples/` and open a notebook
**Expected result:** Notebook executes with pre-built examples

**Talking point:** "Workbenches are ephemeral compute with persistent storage. Your data survives restarts. The container image includes all standard ML libraries -- no pip install nightmares."

### Step 4: Show S3 Connection
**Navigate to:** Data Science Projects > [project] > Data connections
**Action:** Show how to add an S3 data connection (bucket, endpoint, access key)
**Talking point:** "Data connections are managed at the project level. Once configured, every workbench and pipeline in the project can access the same data -- no hardcoded credentials in notebooks."

### Common Issues
- Workbench stuck in "Starting": Image pull may be slow on first use. Check `oc get pods -n rhods-notebooks`
- GPU not available in workbench: Confirm GPU operator is installed and node has GPUs: `oc get nodes -l nvidia.com/gpu.present=true`
- Storage full: Increase PVC size or clean up old data
