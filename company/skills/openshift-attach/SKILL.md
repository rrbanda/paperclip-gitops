---
name: openshift-attach
description: >
  Monitor OpenShift accounts for AI platform attach rate. Identify accounts
  with OpenShift but no AI pipeline and generate alerts for sales management.
  Use when asked about AI attach rates, unattached accounts, or OpenShift-to-AI conversion.
---

# OpenShift Attach Monitor

## Purpose

Track which OpenShift accounts have AI platform pipeline and which do not. Generate weekly reports highlighting unattached accounts that need sales action, and create follow-up tasks to drive AI attach rate improvement.

## Data Retrieval

### Unattached accounts only

```bash
python3 scripts/mock-attach-data.py --query unattached
```

Returns accounts that have an active OpenShift subscription but zero AI platform pipeline entries. Each record includes: account name, region, assigned AE, OpenShift version, last contact date.

### Full account list

```bash
python3 scripts/mock-attach-data.py --query all
```

Returns every OpenShift account with a flag indicating whether AI pipeline exists. Use this for the denominator in attach rate calculations and for trend analysis.

### Aggregate summary

```bash
python3 scripts/mock-attach-data.py --query summary
```

Returns pre-calculated totals: total OpenShift accounts, accounts with AI pipeline, accounts without, attach rate percentage, and week-on-week change.

### Create follow-up tasks

```bash
python3 scripts/mock-attach-data.py --create-task --account "AccountName" --ae "AE Name" --description "Document AI pipeline status"
```

Creates a mock Salesforce task assigned to the AE for the given account. Use this after identifying unattached accounts to ensure follow-up happens.

### Task Monitoring

After creating follow-up tasks, monitor whether AEs actually completed them. This is critical -- creating tasks is meaningless if they're never closed.

**Check task status:**
```bash
python3 scripts/mock-attach-data.py --query closed-tasks
```

Returns: tasks created in previous weeks, their current status (open/closed/overdue), and the AE response.

**Include in the weekly report:**

```markdown
### Follow-Up Task Compliance
| Week Created | Tasks Created | Tasks Closed | Tasks Open | Tasks Overdue | Compliance Rate |
|-------------|---------------|-------------|------------|---------------|-----------------|
| This week | N | N | N | N | X% |
| Last week | N | N | N | N | X% |
| 2 weeks ago | N | N | N | N | X% |

**Overdue Tasks (> 14 days open):**
| Account | AE | Task Description | Created Date | Days Open |
```

Escalate AEs with > 2 overdue tasks to their regional manager by including them in the "Escalation" section.

### Account Prioritization Matrix

Not all unattached accounts are equal. Score each unattached account to focus sales effort:

| Factor | Weight | Scoring |
|--------|--------|---------|
| Company size (revenue/employees) | 30% | Large=3, Medium=2, Small=1 |
| OpenShift node count | 25% | >20 nodes=3, 10-20=2, <10=1 |
| Recency of last contact | 20% | <30 days=3, 30-90=2, >90 days=1 |
| Industry (strategic vertical) | 15% | FSI/Healthcare/Public Sector=3, Telco/Manufacturing=2, Other=1 |
| Existing Red Hat product breadth | 10% | 3+ products=3, 2=2, 1=1 |

**Priority Score** = Weighted sum (max 3.0)

Sort the unattached accounts report by priority score descending. Label:
- Score > 2.5: 🔴 **HIGH PRIORITY** -- immediate action required
- Score 2.0-2.5: 🟡 **MEDIUM PRIORITY** -- schedule within 2 weeks
- Score < 2.0: 🟢 **STANDARD** -- include in next campaign wave

### Historical Trend

Track attach rate over the last 4 weeks to show direction:

```markdown
### Attach Rate Trend
| Week | Total Accounts | Attached | Unattached | Attach Rate | Change |
|------|---------------|----------|------------|-------------|--------|
| This week | N | N | N | X% | +/-X% |
| Last week | N | N | N | X% | -- |
| 2 weeks ago | N | N | N | X% | -- |
| 3 weeks ago | N | N | N | X% | -- |
```

Flag: "⚠️ Attach rate declining for 2+ consecutive weeks -- escalate to leadership."
Flag: "✅ Attach rate improving -- current strategy is working."

### PeopleRover / Dataverse Integration

For report distribution and AE contact lookup:

**Primary source:** PeopleRover / Microsoft Dataverse
```bash
# Future: replace with Dataverse Web API call
# GET https://<org>.crm.dynamics.com/api/data/v9.2/contacts?$filter=region eq '<REGION>' and role eq 'Regional Manager'
python3 scripts/mock-salescloud.py --query contacts --region <REGION>
```

**Contact fields needed:**
- Regional manager: name, email, title
- AE for each account: name, email
- OpenShift specialist (if different from AI specialist): name, email

**Fallback hierarchy:**
1. PeopleRover contact record
2. Salesforce account owner email
3. Regional manager (generic distribution)

If a contact is not found in PeopleRover, note in the report: "[Contact not found in PeopleRover -- using Salesforce account owner]"

## Report Generation

Produce a report in this exact format:

```markdown
# OpenShift AI Attach Rate Report
## Week of [DATE]

### Summary
- Total OpenShift accounts: N
- Accounts with AI pipeline: N (X%)
- Accounts WITHOUT AI pipeline: N (X%) ← ACTION NEEDED
- Week-on-week attach improvement: +N accounts

### Unattached Accounts Requiring Action
| Account | Region | AE | OpenShift Version | Last Contact | Action |
|---------|--------|----|--------------------|-------------|--------|
| Acme Corp | NE | J. Smith | 4.15 | 2025-01-10 | Schedule AI workshop |
| Beta Inc  | West | A. Jones | 4.14 | 2024-12-05 | Renewal + AI bundle pitch |
...

### Recommended Actions
For each unattached account:
1. Salesforce task created for AE: "Document AI opportunity status for [Account]"
2. Pitch deck recommendation: Assign to Pitch Builder agent with account context
3. Follow-up deadline: [DATE + 2 weeks]

### Distribution
Report sent to: OpenShift management + Regional management
```

## Workflow

1. Run the `--query summary` command to get aggregate statistics.
2. Run the `--query unattached` command to get the list of accounts needing action.
3. For each unattached account, determine the recommended action based on:
   - **Last contact > 90 days ago:** "Re-engage: schedule introductory AI workshop"
   - **Last contact 30–90 days ago:** "Follow up: send AI platform overview + schedule demo"
   - **Last contact < 30 days ago:** "Active: document current AI pipeline status in Salesforce"
   - **OpenShift version < 4.14:** "Upgrade path: bundle OCP upgrade with RHOAI adoption"
4. Create Salesforce tasks for each unattached account using the `--create-task` command.
5. Format the report using the template above.
6. Note cross-agent delegation opportunities (see below).

## Cross-Agent Delegation

When an unattached account is identified as a high-priority target (large account, recent engagement, or strategic industry), delegate to the **Pitch Builder** agent to generate customer-specific pitch materials. Provide the Pitch Builder with:

- Account name
- Industry vertical
- Known tech stack (OpenShift version, cloud provider)
- AE name and region
- Any known pain points or business context

This ensures each high-value unattached account gets a tailored pitch, not just a generic follow-up task.

## Key Metrics

- **Attach rate** = Accounts with AI pipeline / Total OpenShift accounts × 100
- **Week-on-week improvement** = This week's attached count minus last week's
- **Action coverage** = Unattached accounts with a Salesforce task / Total unattached accounts × 100 (target: 100%)

## Future: Live Salesforce Integration

When real Salesforce integration is available, replace `python3 scripts/mock-attach-data.py` calls with Salesforce Hosted MCP Server queries. The `--create-task` command maps to Salesforce Task object creation via the MCP API.
