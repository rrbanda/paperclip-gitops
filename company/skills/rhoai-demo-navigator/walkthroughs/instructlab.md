# InstructLab Fine-Tuning on RHOAI
## Version: RHOAI 3.4 | Estimated time: 30 minutes (plus training time)

### Prerequisites
- [ ] RHOAI 3.4 with Training Hub / Kubeflow Trainer v2 enabled
- [ ] GPU worker node (minimum 1x A100 40GB for Granite 8B LoRA)
- [ ] S3 storage for model artifacts
- [ ] Base model available (Granite 3.3 8B recommended for demos)

### Step 1: Understand InstructLab
**Talking point:** "InstructLab is Red Hat's open-source approach to model alignment. Instead of expensive full fine-tuning, you write simple YAML files describing what you want the model to learn, InstructLab generates synthetic training data, and trains a LoRA adapter. The result: a domain-expert model from a few hours of work."

**Key concepts:**
- **Taxonomy:** YAML files describing skills (how-to) or knowledge (facts) you want to add
- **Synthetic data generation:** InstructLab creates training examples from your taxonomy
- **LoRA training:** Parameter-efficient fine-tuning (~10% of full fine-tuning cost)
- **Evaluation:** Compare base model vs fine-tuned model on your domain questions

### Step 2: Create Taxonomy Files
**Action:** In a workbench or locally, create a taxonomy file:
```yaml
# taxonomy/knowledge/insurance/claims/qna.yaml
version: 3
domain: insurance
created_by: demo-user
seed_examples:
  - context: |
      An insurance claim is a formal request by a policyholder to an insurance 
      company for coverage or compensation for a covered loss or policy event.
    questions_and_answers:
      - question: What is an insurance claim?
        answer: An insurance claim is a formal request to an insurance company for coverage or compensation under a policy.
      - question: Who can file an insurance claim?
        answer: The policyholder or an authorized representative can file an insurance claim.
      - question: What information is needed to file a claim?
        answer: Policy number, date and description of the incident, supporting documentation, and contact information.
```

**Talking point:** "This is all the domain expert writes. No ML expertise needed. The taxonomy is version-controlled in Git alongside your business logic."

### Step 3: Generate Synthetic Data
**Action:** Using the InstructLab CLI in a workbench:
```bash
ilab data generate --taxonomy-path ./taxonomy --output-dir ./training-data --num-instructions 100
```
**Expected result:** Generated training data in JSONL format (5-15 minutes depending on base model and GPU)
**Talking point:** "InstructLab uses the base model to generate hundreds of training examples from your few seed examples. This is the LAB (Large-scale Alignment for chatBots) methodology."

### Step 4: Train the LoRA Adapter
**Action:**
```bash
ilab model train --data-path ./training-data --output-dir ./trained-model --num-epochs 3
```
**Expected result:** LoRA adapter saved to output directory (15-60 minutes for Granite 8B on 1x A100)
**Talking point:** "LoRA trains only ~1% of the model's parameters. This means you need a fraction of the GPU memory and time compared to full fine-tuning. A 7B model trains in under an hour on a single A100."

### Step 5: Evaluate
**Action:**
```bash
ilab model evaluate --model ./trained-model --benchmark ./taxonomy
```
**Expected result:** Comparison showing base model vs fine-tuned model accuracy on domain questions
**Talking point:** "Evaluation tells you exactly how much your model improved on your domain. If the numbers don't look good, iterate on the taxonomy and retrain."

### Step 6: Deploy the Fine-Tuned Model
**Action:** Upload the LoRA adapter to S3, then deploy via RHOAI dashboard using KServe (same as the model serving walkthrough, but point to the fine-tuned artifact)
**Talking point:** "The fine-tuned model deploys with the same KServe infrastructure as any other model. No special runtime needed."

### Common Issues
- `ilab data generate` OOM: Reduce `--num-instructions` or use a smaller teacher model
- Training fails with CUDA error: Check GPU driver compatibility with `nvidia-smi`
- Evaluation shows no improvement: Add more diverse seed examples in the taxonomy, minimum 5 Q&A pairs per topic
- Model too large for available GPU: Use QLoRA (4-bit quantization) to reduce memory requirements
