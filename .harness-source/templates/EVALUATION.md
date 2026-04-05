---
phase: {PHASE_NUM}
evaluated: {timestamp}
score: {X}/10
status: passed | needs_fix | failed
evaluator: harness-evaluator
---

# Phase {PHASE_NUM}: {phase_name} - Evaluation Report

## Executive Summary

**Score**: {X}/10
**Status**: {passed|needs_fix|failed}
**Verdict**: {one_sentence_summary}

## Requirement Scores

| ID | Requirement | Priority | Score | Status | Issues |
|----|-------------|----------|-------|--------|--------|
| FR-01 | {name} | must-have | 8 | ✅ | 0 |
| FR-02 | {name} | must-have | 5 | ⚠️ | 1 |
| NFR-01 | {name} | should-have | 10 | ✅ | 0 |

## Detailed Findings

### FR-01: {requirement_name}

**Score**: 8/10
**Status**: ✅ Passed with minor issues

**What was expected**:
{from SPEC.md acceptance criteria}

**What was found**:
{actual implementation details}

**Issues**: None

**Evidence**:
```
{code snippet or test output}
```

### FR-02: {requirement_name}

**Score**: 5/10
**Status**: ⚠️ Needs fixes

**What was expected**:
{from SPEC.md acceptance criteria}

**What was found**:
{actual implementation details}

**Issues**:
1. **I-01** (high): {description}
   - File: {path}:{line}
   - Fix: {fix_hint}

**Evidence**:
```
{code snippet showing the issue}
```

## Issues Summary

| ID | Severity | Description | File | Fix Hint |
|----|----------|-------------|------|----------|
| I-01 | high | {desc} | {file}:{line} | {hint} |

## Test Results

| Test | Result | Details |
|------|--------|---------|
| TC-01 | ✅ PASS | {details} |
| TC-02 | ❌ FAIL | {details} |

## Human Verification Needed

{Items that cannot be verified programmatically}

1. **{Item}**
   - Why: {reason}
   - How to verify: {instructions}

## Scoring Breakdown

- Must-have requirements (weight 1.0): {score}/10
- Should-have requirements (weight 0.7): {score}/10
- Nice-to-have requirements (weight 0.3): {score}/10

**Weighted Average**: {overall_score}/10

## Recommendation

{If score >= 7: "Phase passed. Ready for next phase."}
{If score < 7: "Phase needs fixes. Run /harness:fix to address issues."}
