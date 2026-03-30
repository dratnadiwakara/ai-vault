# Referee Report — Markdown Summary Format

A markdown summary that visualizes audit findings for quick review. Uses headings, tables, and bullets to convey the same content as the full report in a scannable format.

## Principles

1. **Action titles**: Section headings should state the finding, not describe the content.
   - GOOD: "Python implementation differs by 0.003 on main specification"
   - BAD: "Cross-language comparison results"

2. **Well-formatted tables**: Use markdown tables with clear headers, aligned columns, and visual indicators (✓/✗) for match/mismatch.

3. **One insight per section**: Each heading should convey a single takeaway.

4. **Scannable**: Use bullets, tables, and short paragraphs. The author should grasp key findings without reading the full report.

---

## Summary Structure

```markdown
# Referee Report Summary — [Project Name] Round [N]
Date: YYYY-MM-DD

## Executive Summary

**Verdict:** [Accept / Minor Revisions / Major Revisions / Reject]

- Key finding 1
- Key finding 2
- Key finding 3
- Key finding 4

---

## Cross-Language Replication

### Main DiD Estimate Matches Across R and Python

| Specification | R | Python | Match? |
|--------------|---|--------|--------|
| Point Estimate | 0.234567 | 0.234567 | ✓ |
| Std. Error | 0.045123 | 0.045123 | ✓ |
| N | 15,432 | 15,432 | ✓ |

**Verdict:** Both implementations produce identical results to 6 decimal places.

---

## Replication Readiness Score: 6/10

| Met | Not Met |
|-----|---------|
| ✓ Folder structure | ✗ Master script missing |
| ✓ Relative paths | ✗ No README in /code |
| ✓ Dependencies documented | ✗ Seeds not set |

---

## Top Code Audit Concerns

1. **[Issue title]**: [One-line explanation]
2. **[Issue title]**: [One-line explanation]

---

## Top Econometrics Concerns

1. **[Issue title]**: [One-line explanation]

---

## Recommendations

1. [Prioritized action item]
2. [Prioritized action item]
3. [Prioritized action item]
```

---

## Example: Cross-Language Comparison (Match)

| Specification | R | Python | Match? |
|--------------|---|--------|--------|
| Point Estimate | 0.234567 | 0.234567 | ✓ |
| Std. Error | 0.045123 | 0.045123 | ✓ |
| N | 15,432 | 15,432 | ✓ |

---

## Example: Cross-Language Discrepancy

| Period | R | Python | Match? |
|--------|---|--------|--------|
| t-2 | 0.012 | 0.012 | ✓ |
| t-1 | 0.008 | 0.008 | ✓ |
| t+0 | 0.156 | **0.148** | ✗ |
| t+1 | 0.189 | **0.181** | ✗ |

**Diagnosis:** Python's `linearmodels` package drops 847 observations with missing control variables, while R keeps them.

**Resolution:** Author should verify intended missing value handling.
