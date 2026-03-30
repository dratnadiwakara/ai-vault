# Referee Report Format

## Filing Locations

- **Report (Markdown):** `correspondence/referee2/YYYY-MM-DD_round[N]_report.md`
- **Summary (Markdown):** `correspondence/referee2/YYYY-MM-DD_round[N]_summary.md`
- **Author response:** `correspondence/referee2/YYYY-MM-DD_round[N]_response.md`

---

## Report Structure

```
=================================================================
                        REFEREE REPORT
              [Project Name] — Round [N]
              Date: YYYY-MM-DD
=================================================================

## Summary

[2-3 sentences: What was audited? What is the overall assessment?]

---

## Audit 1: Code Audit

### Findings
[Numbered list of issues found]

### Missing Value Handling Assessment
[Specific assessment of how missing values are treated]

---

## Audit 2: Cross-Language Replication

### Replication Scripts Created
- `code/replication/referee2_replicate_[name].R`
- `code/replication/referee2_replicate_[name].py`

### Comparison Table

| Specification | R | Python | Match? |
|--------------|---|--------|--------|
| Main estimate | X.XXXXXX | X.XXXXXX | Yes/No |
| SE | X.XXXXXX | X.XXXXXX | Yes/No |
| N | X | X | Yes/No |

### Discrepancies Diagnosed
[If any mismatches, explain the likely cause and which implementation is correct]

---

## Audit 3: Directory & Replication Package

### Replication Readiness Score: X/10

### Deficiencies
[Numbered list]

---

## Audit 4: Output Automation

### Tables: [Automated / Manual / Mixed]
### Figures: [Automated / Manual / Mixed]
### In-text statistics: [Automated / Manual / Mixed]

### Deductions
[List any issues]

---

## Audit 5: Econometrics

### Identification Assessment
[Is the strategy credible?]

### Specification Issues
[Numbered list of concerns]

---

## Major Concerns
[Numbered list — MUST be addressed before acceptance]

1. **[Short title]**: [Detailed explanation and why it matters]

## Minor Concerns
[Numbered list — should be addressed]

1. **[Short title]**: [Explanation]

## Questions for Authors
[Things requiring clarification]

---

## Verdict

[ ] Accept
[ ] Minor Revisions
[ ] Major Revisions
[ ] Reject

**Justification:** [Brief explanation]

---

## Recommendations
[Prioritized list of what the author should do before resubmission]

=================================================================
                      END OF REFEREE REPORT
=================================================================
```

---

## Author Response Format

```
=================================================================
                    AUTHOR RESPONSE TO REFEREE REPORT
                    Round [N] — Date: YYYY-MM-DD
=================================================================

## Response to Major Concerns

### Major Concern 1: [Title]
**Action taken:** [Fixed / Justified]
[Detailed explanation of fix OR justification for not fixing]

### Major Concern 2: [Title]
...

## Response to Minor Concerns

### Minor Concern 1: [Title]
**Action taken:** [Fixed / Acknowledged]
[Brief explanation]

...

## Answers to Questions

### Question 1
[Answer]

...

## Summary of Code Changes

| File | Change |
|------|--------|
| `code/01_clean.R` | Fixed missing value handling on line 47 |
| ... | ... |

=================================================================
```
