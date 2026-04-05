---
phase: {PHASE_NUM}
name: {phase_name}
created: {timestamp}
app_type: web | backend | cli | library | mojo
app_url: {url_if_web_app}
sprint_mode: true | false
---

# Phase {PHASE_NUM}: {phase_name} - Specification

## Goal

{phase_goal}

## Application Type

**Type**: {web | backend | cli | library | mojo}

{If web application:}
**URL**: {http://localhost:3000 or actual URL}
**Live Testing**: Evaluator will test the running application via Puppeteer MCP

## Functional Requirements

### FR-01: {requirement_name}
- **Description**: {what_it_does}
- **Input**: {expected_input}
- **Output**: {expected_output}
- **Acceptance Criteria**: {testable_criteria}
- **Priority**: must-have | should-have | nice-to-have
- **Test Method**: automated | live | manual

### FR-02: {requirement_name}
...

## Non-Functional Requirements

### NFR-01: {requirement_name}
- **Description**: {what_it_requires}
- **Acceptance Criteria**: {testable_criteria}

## Technical Constraints

- {constraint_1}
- {constraint_2}

## Dependencies

- Depends on: {list of dependencies}
- Blocks: {list of blocked phases}

## Success Criteria

- [ ] {criterion_1}
- [ ] {criterion_2}
- [ ] {criterion_3}

## Scoring Rubric

| Score | Meaning | Description |
|-------|---------|-------------|
| 10 | Perfect | All requirements met, no issues |
| 9 | Excellent | All must-haves met, minor polish needed |
| 7-8 | Good | All must-haves met, some should-haves missing |
| 5-6 | Acceptable | Core functionality works, notable gaps |
| 3-4 | Poor | Major issues, core functionality broken |
| 1-2 | Failed | Does not work |

## Test Cases

### TC-01: {test_name}
- **Given**: {precondition}
- **When**: {action}
- **Then**: {expected_result}
- **Test Type**: unit | integration | live

### TC-02: {test_name}
...

## Live Test Scenarios (for web applications)

{Only if app_type: web}

### Scenario 1: {scenario_name}
1. Navigate to {url}
2. {action_1}
3. Verify {expected_result_1}
4. {action_2}
5. Verify {expected_result_2}

### Scenario 2: {scenario_name}
...
