# RHOAI Dashboard Tour
## Version: RHOAI 3.4 | Estimated time: 10 minutes

### Prerequisites
- [ ] OpenShift cluster with RHOAI operator installed
- [ ] Admin or user access to the RHOAI dashboard

### Step 1: Access the Dashboard
**Navigate to:** OpenShift Console > Installed Operators > Red Hat OpenShift AI > Launch dashboard (or direct URL: `https://<cluster>/odh-dashboard`)
**Expected result:** RHOAI dashboard home page with "Enabled" applications listed

### Step 2: Review Enabled Applications
**Navigate to:** Home page
**What to show:** List of enabled components -- Data Science Projects, Model Serving, Pipelines, Workbenches. Point out that each is a managed component.
**Talking point:** "Everything you see here is operator-managed. Updates, patches, and lifecycle are handled by Red Hat."

### Step 3: Create a Data Science Project
**Navigate to:** Data Science Projects > Create project
**Action:** Enter project name (e.g., "customer-demo"), optional description
**Expected result:** New project created with empty sections for workbenches, pipelines, models, storage
**Talking point:** "A project is a Kubernetes namespace with RHOAI resources pre-configured. Your team gets isolated compute and storage."

### Step 4: Show Cluster Settings (Admin)
**Navigate to:** Settings > Cluster settings
**What to show:** Model serving platforms enabled, workbench images available, GPU profiles
**Talking point:** "Admins control what's available to data scientists. You can restrict model sizes, limit GPU allocation, and manage workbench images centrally."

### Step 5: Show Model Serving Configuration
**Navigate to:** Settings > Model serving platforms
**What to show:** KServe enabled, available runtimes (vLLM, OpenVINO, MLServer, NIM)
**Talking point:** "RHOAI supports multiple serving runtimes. vLLM for LLMs, MLServer for predictive models, NIM for NVIDIA-optimized inference. The platform auto-selects the best runtime based on your model."

### Common Issues
- Dashboard not loading: Check `oc get pods -n redhat-ods-applications | grep dashboard`
- No model serving options: KServe may not be enabled -- check DataScienceCluster CR
