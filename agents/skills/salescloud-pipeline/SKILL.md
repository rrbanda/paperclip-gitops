---
name: salescloud-pipeline
description: >
  Pull AI platform sales pipeline data by region, calculate quota progress,
  and generate weekly executive reports. Use when asked to report on regional
  sales progress, pipeline by stage, or quota attainment.
---

# Sales Progress Monitor

## Purpose

Generate weekly executive sales reports for the Red Hat AI platform pipeline. This skill pulls regional pipeline data, calculates quota attainment, and distributes formatted reports to sales leadership.

## Americas Regions

There are 11 regions in the Americas sales organization:

| Code | Region |
|------|--------|
| NE | Northeast |
| SE | Southeast |
| Commercial | Commercial |
| FSI | Financial Services & Insurance |
| Canada | Canada |
| West | West |
| Central | Central |
| NOLA | North Latin America |
| SOLA | South Latin America |
| Brazil | Brazil |
| NA Telco | North America Telco |

Always iterate over all 11 regions when generating a full report. For single-region requests, use only the requested region code.

## Data Retrieval

### Pipeline data (per region)

```bash
python3 scripts/mock-salescloud.py --query pipeline --region <REGION>
```

Returns opportunity-level pipeline data for the given region: opportunity name, account, stage, amount, close date, AE, week-on-week change.

Run this for each of the 11 regions to build a complete Americas view.

### Contact data (for report distribution)

```bash
python3 scripts/mock-salescloud.py --query contacts --region <REGION>
```

Returns the regional manager and key stakeholder email addresses for the given region. Use these to populate the distribution list at the bottom of each report.

## Report Generation

After collecting data from all requested regions, produce a report in this exact format:

```markdown
# AI Platform Weekly Sales Report
## Week of [DATE]

### Executive Summary
- Total pipeline: $X across N opportunities
- Week-on-week change: +/-$X (+/-N%)
- Quota attainment: X% of $TARGET

### Regional Breakdown
| Region | Pipeline | Target | Attainment | WoW Change | Opps |
|--------|----------|--------|------------|------------|------|
| NE     | $X       | $X     | X%         | +$X        | N    |
| SE     | $X       | $X     | X%         | +$X        | N    |
| Commercial | $X   | $X     | X%         | +$X        | N    |
| FSI    | $X       | $X     | X%         | +$X        | N    |
| Canada | $X       | $X     | X%         | +$X        | N    |
| West   | $X       | $X     | X%         | +$X        | N    |
| Central| $X       | $X     | X%         | +$X        | N    |
| NOLA   | $X       | $X     | X%         | +$X        | N    |
| SOLA   | $X       | $X     | X%         | +$X        | N    |
| Brazil | $X       | $X     | X%         | +$X        | N    |
| NA Telco | $X     | $X     | X%         | +$X        | N    |

### Pipeline by Stage
| Stage | Count | Value | % of Total |
|-------|-------|-------|------------|
| Discovery | N  | $X    | X%         |
| Qualification | N | $X | X%        |
| Proposal | N  | $X    | X%         |
| Negotiation | N | $X  | X%         |
| Closed Won | N | $X   | X%         |

### Opportunities Maturing This Week
- [Opp Name] at [Account]: $X moved from [Stage A] to [Stage B]
- [Opp Name] at [Account]: $X moved from [Stage A] to [Stage B]
...

### Distribution
Report sent to: [list of regional manager emails from contacts query]
```

## Calculation Rules

- **Quota attainment** = (Closed Won + Weighted Pipeline) / Target × 100. Weight pipeline by stage: Discovery 10%, Qualification 25%, Proposal 50%, Negotiation 75%, Closed Won 100%.
- **Week-on-week change** = This week's total pipeline minus last week's. Express as both absolute dollars and percentage.
- **Opportunities maturing** = Any opportunity whose stage changed since last week's data pull.

### Pipeline Conversion Metrics

Calculate stage-to-stage conversion rates to show pipeline maturity:

| Conversion | Formula | Healthy Benchmark |
|-----------|---------|-------------------|
| Prospecting → Qualification | (Opps entering Qualification this week) / (Opps in Prospecting last week) × 100 | 30-40% |
| Qualification → Proposal | (Opps entering Proposal) / (Opps in Qualification last week) × 100 | 40-50% |
| Proposal → Negotiation | (Opps entering Negotiation) / (Opps in Proposal last week) × 100 | 50-60% |
| Negotiation → Closed Won | (Opps entering Closed Won) / (Opps in Negotiation last week) × 100 | 60-70% |

Report these in a "Pipeline Health" section of the weekly report.

Flag any conversion rate below the healthy benchmark with "⚠️ Below benchmark" in the report.

### Pipeline Velocity

Track average days each opportunity spends in each stage:

| Stage | Healthy Range | Alert Threshold |
|-------|--------------|-----------------|
| Prospecting | 0-14 days | > 21 days |
| Qualification | 14-30 days | > 45 days |
| Proposal | 7-21 days | > 30 days |
| Negotiation | 14-30 days | > 45 days |

**Stalled Deals:** Flag any opportunity sitting in one stage for longer than the alert threshold. Include in the report as:

```markdown
### Stalled Opportunities (> threshold days in current stage)
| Account | Opp Name | Stage | Days in Stage | AE | Action Needed |
```

Calculate days in stage from the mock data's `lastActivity` field vs current date.

### Product Breakdown

Split pipeline by Red Hat AI product to show portfolio coverage:

| Product | Pipeline Value | Opp Count | % of Total |
|---------|---------------|-----------|------------|
| OpenShift AI | $X | N | X% |
| RHEL AI | $X | N | X% |
| InstructLab | $X | N | X% |
| Ansible Lightspeed | $X | N | X% |
| AI Consulting/Services | $X | N | X% |

Use the `product` field from mock data. If no product field, infer from opportunity name keywords.

Flag any product with < 10% of total pipeline as "⚠️ Underpenetrated -- consider targeted campaign."

### At-Risk Alerts

Flag deals that need immediate attention. Include as a highlighted section near the top of the report, right after the Executive Summary:

**At-risk criteria (flag if ANY apply):**
- Close date has passed (overdue)
- Amount decreased week-on-week (deal shrinking)
- No activity in 30+ days (stale)
- Stage moved backward (regression)

Format:
```markdown
### ⚠️ At-Risk Deals Requiring Immediate Attention
| Account | Opp Name | Amount | Risk Reason | AE | Days Since Last Activity |
```

### Wins This Week

Highlight Closed Won opportunities at the top of the report for positive reinforcement:

```markdown
### 🎯 Wins This Week
| Account | Opp Name | Amount | AE | Region | Product |
```

If no wins this week, state: "No new Closed Won opportunities this week."

## Report Section Order

The weekly report should include sections in this order:

1. Executive Summary
2. At-Risk Alerts
3. Wins This Week
4. Regional Breakdown
5. Pipeline by Stage
6. Pipeline Conversion Metrics
7. Pipeline Velocity / Stalled Deals
8. Product Breakdown
9. Opportunities Maturing This Week
10. Distribution

## Workflow

1. Determine the report scope (all regions or specific region).
2. Run the pipeline query for each in-scope region.
3. Aggregate totals across regions.
4. Calculate quota attainment and WoW changes.
5. Identify opportunities that changed stage.
6. Identify at-risk deals and wins this week.
7. Calculate pipeline conversion metrics and velocity.
8. Generate product breakdown.
9. Run the contacts query for each in-scope region to build the distribution list.
10. Format the report using the template and section order above.
11. Deliver the report to the user and note the distribution list.

## Future: Live Salesforce Integration

When real Salesforce integration is available, replace `python3 scripts/mock-salescloud.py` calls with Salesforce Hosted MCP Server queries using SOQL. Example equivalent queries:

- Pipeline: `SELECT Name, Account.Name, StageName, Amount, CloseDate, Owner.Name FROM Opportunity WHERE Region__c = '<REGION>' AND IsClosed = false`
- Contacts: `SELECT Name, Email, Region__c FROM Contact WHERE Role__c = 'Regional Manager'`

The report format and calculation rules remain the same regardless of data source.
