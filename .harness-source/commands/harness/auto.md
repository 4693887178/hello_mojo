---
name: harness:auto
description: Run phase with Harness architecture (Planner -> Generator -> Evaluator with independent agents)
argument-hint: "<phase-number> [--max-fix-attempts N] [--skip-planner] [--sprint-mode]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - mcp_Puppeteer_puppeteer_navigate
  - mcp_Puppeteer_puppeteer_screenshot
  - mcp_Puppeteer_puppeteer_click
  - mcp_Puppeteer_puppeteer_fill
---

<objective>
Execute a single phase using Harness architecture with three independent agents:

1. **Planner Agent** (Task tool) → produces SPEC.md + PLAN.md
2. **Generator Agent** (Task tool) → produces code + SUMMARY.md  
3. **Evaluator Agent** (Task tool) → produces EVALUATION.md with score

Each agent runs in ISOLATED context via Task tool. They communicate ONLY through files.

This implements the Harness architecture from Anthropic's engineering blog:
"Agents aren't hard; the Harness is hard."
</objective>

<core_principle>

## Harness Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Harness Pipeline                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐      │
│   │   Planner   │     │  Generator  │     │  Evaluator  │      │
│   │ Task Agent  │     │ Task Agent  │     │ Task Agent  │      │
│   │ (独立上下文)│     │ (独立上下文)│     │ (独立上下文)│      │
│   └──────┬──────┘     └──────┬──────┘     └──────┬──────┘      │
│          │                   │                   │              │
│          ▼                   ▼                   ▼              │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐      │
│   │  SPEC.md    │────▶│   PLAN.md   │────▶│EVALUATION.md│      │
│   │  PLAN.md    │     │   代码文件   │     │  评分报告   │      │
│   └─────────────┘     │  SUMMARY.md │     └─────────────┘      │
│                       └─────────────┘              │            │
│                                                    │            │
│                          ┌─────────────────────────┘            │
│                          ▼                                      │
│                   ┌─────────────┐                               │
│                   │ 分数 < 7 ?  │                               │
│                   └──────┬──────┘                               │
│                          │                                      │
│              ┌───────────┴───────────┐                         │
│              ▼                       ▼                         │
│        分数 >= 7                分数 < 7                        │
│        继续下一 phase          启动修复循环                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

Sprint Mode (Optional):
┌─────────────────────────────────────────────────────────────────┐
│                  Sprint Contract Flow                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Generator                     Evaluator                       │
│       │                             │                           │
│       │  ┌─────────────────┐        │                           │
│       └─▶│ CONTRACT.md     │───────▶│                           │
│          │ (Proposal)      │        │                           │
│          └─────────────────┘        │                           │
│                   │                 │                           │
│                   ▼                 ▼                           │
│          ┌─────────────────┐  ┌─────────────────┐              │
│          │ Review &        │  │ Approved/       │              │
│          │ Request Changes │◀─│ Revision Needed │              │
│          └─────────────────┘  └─────────────────┘              │
│                   │                 │                           │
│                   ▼                 ▼                           │
│          ┌─────────────────┐        │                           │
│          │ status: agreed  │◀───────┘                           │
│          └─────────────────┘                                    │
│                   │                                             │
│                   ▼                                             │
│          Start Implementation                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principle**: "Agent 不能自己评自己" (Agents cannot evaluate themselves)
- Generator and Evaluator are COMPLETELY INDEPENDENT
- Evaluator does NOT read SUMMARY.md (Generator's explanations)
- Evaluator only sees SPEC.md and actual code

</core_principle>

<process>

## Step 1: Parse Arguments

```bash
# Parse phase number
PHASE_NUM=""
MAX_FIX_ATTEMPTS=3
SKIP_PLANNER=false
SPRINT_MODE=false

for arg in $ARGUMENTS; do
  if [[ "$arg" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    PHASE_NUM="$arg"
  elif [[ "$arg" == "--max-fix-attempts" ]]; then
    : # Next arg is the number
  elif [[ "$arg" =~ ^[0-9]+$ ]] && [[ $prev_arg == "--max-fix-attempts" ]]; then
    MAX_FIX_ATTEMPTS="$arg"
  elif [[ "$arg" == "--skip-planner" ]]; then
    SKIP_PLANNER=true
  elif [[ "$arg" == "--sprint-mode" ]]; then
    SPRINT_MODE=true
  fi
  prev_arg="$arg"
done

# If no phase number, find next incomplete
if [[ -z "$PHASE_NUM" ]]; then
  PHASE_NUM=$(grep -E "^### Phase [0-9]" .planning-harness/ROADMAP.md 2>/dev/null | grep -v "complete" | head -1 | grep -oE "[0-9]+\.?[0-9]*" || echo "1")
fi
```

## Step 2: Display Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 HARNESS ► AUTO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Phase: {PHASE_NUM}
 Mode: Independent Agent Pipeline
 Max Fix Attempts: {MAX_FIX_ATTEMPTS}
 Sprint Mode: {SPRINT_MODE}

 Architecture: Planner → Generator → Evaluator
 Communication: File-based only (no shared context)
```

## Step 3: Planner Agent (Independent)

**Skip if --skip-planner or SPEC.md already exists**

```bash
# Check if SPEC.md exists
if [[ "$SKIP_PLANNER" == "true" ]] || [[ -f ".planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md" ]]; then
  echo "Skipping Planner - SPEC.md already exists or --skip-planner"
else
  echo "Launching Planner Agent (independent context)..."
  
  Task(
    subagent_type="task-analyzer",
    description="Harness Planner for phase ${PHASE_NUM}",
    query="""
你是 Harness Planner Agent。你运行在完全独立的上下文中。

**你的任务**: 为 Phase ${PHASE_NUM} 创建规格文档和执行计划。

**输入文件（读取这些）**:
- .planning-harness/PROJECT.md 或 .planning/PROJECT.md
- .planning-harness/ROADMAP.md 或 .planning/ROADMAP.md
- .planning-harness/STATE.md 或 .planning/STATE.md

**输出文件（必须创建）**:
- .planning-harness/phases/${PHASE_NUM}-{slug}/${PHASE_NUM}-SPEC.md
- .planning-harness/phases/${PHASE_NUM}-{slug}/${PHASE_NUM}-PLAN.md

**SPEC.md 必须包含**:
1. 功能需求 (FR-01, FR-02, ...)
2. 非功能需求 (NFR-01, ...)
3. 验收标准
4. 评分标准 (1-10 分)
5. 测试用例

**如果是 Web 应用，添加**:
- app_type: web
- app_url: http://localhost:3000 (或实际地址)

**关键规则**:
- 你是完全独立的会话，不继承任何上下文
- 只通过文件通信
- 完成后返回：创建的文件列表

参考 Agent 配置: .harness-source/agents/harness-planner.md
""",
    response_language="zh-CN"
  )
  
  # Verify output
  if [[ ! -f ".planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md" ]]; then
    echo "ERROR: Planner did not produce SPEC.md"
    exit 1
  fi
fi
```

## Step 4: Sprint Contract Negotiation (if --sprint-mode)

**Only if SPRINT_MODE=true**

```bash
if [[ "$SPRINT_MODE" == "true" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " SPRINT CONTRACT NEGOTIATION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  CONTRACT_AGREED=false
  MAX_CONTRACT_ROUNDS=3
  CONTRACT_ROUND=0
  
  while [[ "$CONTRACT_AGREED" == "false" ]] && [[ $CONTRACT_ROUND -lt $MAX_CONTRACT_ROUNDS ]]; do
    CONTRACT_ROUND=$((CONTRACT_ROUND + 1))
    
    echo ""
    echo "Contract Round ${CONTRACT_ROUND}/${MAX_CONTRACT_ROUNDS}"
    
    # Generator proposes contract
    Task(
      subagent_type="task-executor",
      description="Generator Contract Proposal - Round ${CONTRACT_ROUND}",
      query="""
你是 Harness Generator Agent。创建 Sprint Contract Proposal。

**必须读取**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-PLAN.md

**创建文件**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-CONTRACT.md

**CONTRACT.md 内容**:
```yaml
---
phase: ${PHASE_NUM}
sprint: 1
status: proposed
---

# Sprint Contract Proposal

## Features to Implement
{列出要实现的功能}

## Testable Behaviors
| ID | Behavior | How to Verify |
{可测试的行为}

## Definition of Done
{完成标准}
```

完成后返回：创建的 CONTRACT.md 路径
""",
      response_language="zh-CN"
    )
    
    # Evaluator reviews contract
    Task(
      subagent_type="result-reviewer",
      description="Evaluator Contract Review - Round ${CONTRACT_ROUND}",
      query="""
你是 Harness Evaluator Agent。审查 Sprint Contract Proposal。

**必须读取**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-CONTRACT.md

**审查要点**:
1. 功能是否覆盖 SPEC.md 的所有 must-have 需求？
2. Testable Behaviors 是否足够具体、可验证？
3. Definition of Done 是否清晰？

**更新 CONTRACT.md**:
- 如果通过: `status: agreed`
- 如果需要修改: `status: needs_revision` + 添加反馈

完成后返回：审查结果
""",
      response_language="zh-CN"
    )
    
    # Check if agreed
    CONTRACT_STATUS=$(grep "^status:" .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-CONTRACT.md 2>/dev/null | tail -1 | cut -d: -f2 | tr -d ' ')
    
    if [[ "$CONTRACT_STATUS" == "agreed" ]]; then
      CONTRACT_AGREED=true
      echo "✅ Contract agreed after ${CONTRACT_ROUND} round(s)"
    else
      echo "⚠️ Contract needs revision. Round ${CONTRACT_ROUND} complete."
    fi
  done
  
  if [[ "$CONTRACT_AGREED" == "false" ]]; then
    echo "❌ Contract negotiation failed after ${MAX_CONTRACT_ROUNDS} rounds"
    AskUserQuestion(
      questions=[{
        header: "Contract",
        question: "Sprint contract negotiation failed. How to proceed?",
        options=[
          {"label": "Continue anyway", "description": "Proceed without agreed contract"},
          {"label": "Manual review", "description": "I'll review and fix the contract manually"},
          {"label": "Abort", "description": "Stop the harness run"}
        ]
      }]
    )
  fi
fi
```

## Step 5: Generator Agent (Independent)

```bash
echo "Launching Generator Agent (independent context)..."

Task(
  subagent_type="task-executor",
  description="Harness Generator for phase ${PHASE_NUM}",
  query="""
你是 Harness Generator Agent。你运行在完全独立的上下文中。

**你的任务**: 执行 PLAN.md 中的任务，生成代码。

**必须读取的文件**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-PLAN.md

**禁止读取的文件**:
- ❌ SUMMARY.md（其他阶段的）
- ❌ EVALUATION.md（其他阶段的）
- ❌ 任何包含"实现说明"的文档

**输出**:
- 代码文件（按 PLAN.md 指定）
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SUMMARY.md

**关键规则**:
- 你是完全独立的会话
- 只读取 SPEC.md 和 PLAN.md
- 按 SPEC.md 的要求实现，不多不少
- 完成后返回：创建/修改的文件列表

参考 Agent 配置: .harness-source/agents/harness-generator.md
""",
  response_language="zh-CN"
)

# Verify output
if [[ ! -f ".planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SUMMARY.md" ]]; then
  echo "WARNING: Generator did not produce SUMMARY.md"
fi
```

## Step 6: Evaluator Agent (Independent)

**CRITICAL: Evaluator does NOT read SUMMARY.md**

```bash
echo "Launching Evaluator Agent (independent context)..."

Task(
  subagent_type="result-reviewer",
  description="Harness Evaluator for phase ${PHASE_NUM}",
  query="""
你是 Harness Evaluator Agent。你运行在完全独立的上下文中。

**你的任务**: 独立评估实现质量，给出评分。

**必须读取的文件**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md（规格合约）
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-PLAN.md（文件路径）
- 代码文件（实际实现）

**禁止读取的文件**:
- ❌ SUMMARY.md（Generator 的自我评估）
- ❌ CONTEXT.md（讨论上下文）
- ❌ 任何包含"实现说明"、"设计决策"的文档

**为什么禁止？** 这是 Harness 架构的核心：
- 你必须评估"实际做了什么"，而不是"想要做什么"
- Generator 的解释会影响你的判断
- Self-Evaluation Bias 是我们要解决的问题

**如果是 Web 应用 (app_type: web)**:
- 使用 Puppeteer MCP 工具测试运行中的应用
- 导航到 app_url
- 截图作为证据
- 测试 UI 交互

**输出**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-EVALUATION.md

**EVALUATION.md 必须包含**:
```yaml
---
phase: {PHASE_NUM}
score: X/10
status: passed | needs_fix | failed
live_testing: true | false
issues:
  - id: I-01
    severity: blocker | high | medium | low
    description: "问题描述"
    file: path/to/file
    line: N
    fix_hint: "修复建议"
---
```

**评分标准**:
- 10分: 完全符合规格
- 7-9分: 功能正常，有轻微差异
- 4-6分: 核心功能可用，有明显问题
- 1-3分: 基本不可用

**关键原则**:
> "Tuning evaluator skepticism is more tractable than making generators self-critical."
> 
> 当不确定时，标记为问题。假阴性比假阳性好。

参考 Agent 配置: .harness-source/agents/harness-evaluator.md
""",
  response_language="zh-CN"
)

# Read evaluation result
EVAL_FILE=$(ls .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-EVALUATION.md 2>/dev/null | head -1)
SCORE=$(grep "^score:" "$EVAL_FILE" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
STATUS=$(grep "^status:" "$EVAL_FILE" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
```

## Step 7: Evaluation Routing

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " EVALUATION RESULT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo " Phase: ${PHASE_NUM}"
echo " Score: ${SCORE}/10"
echo " Status: ${STATUS}"
echo ""

if [[ "$STATUS" == "passed" ]] || [[ $(echo "$SCORE >= 7" | bc) -eq 1 ]]; then
  echo "✅ Phase passed! Ready for next phase."
  echo ""
  echo "Next: /harness:auto {next_phase}"
  exit 0
fi

if [[ "$STATUS" == "failed" ]] || [[ $(echo "$SCORE < 4" | bc) -eq 1 ]]; then
  echo "❌ Phase failed. Manual intervention required."
  echo ""
  echo "Review: $EVAL_FILE"
  AskUserQuestion(
    questions=[{
      header: "Failed",
      question: "Phase evaluation failed with score ${SCORE}/10. How to proceed?",
      options=[
        {"label": "View issues", "description": "Show the evaluation report"},
        {"label": "Retry phase", "description": "Re-run the entire phase from scratch"},
        {"label": "Manual fix", "description": "I'll fix the issues manually"}
      ]
    }]
  )
  exit 1
fi

# needs_fix or score 4-6
echo "⚠️ Phase needs fixes."
echo ""
```

## Step 8: Fix Loop

```bash
FIX_ATTEMPT=0

while [[ $FIX_ATTEMPT -lt $MAX_FIX_ATTEMPTS ]]; do
  FIX_ATTEMPT=$((FIX_ATTEMPT + 1))
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " FIX LOOP ${FIX_ATTEMPT}/${MAX_FIX_ATTEMPTS}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Launch Fix Agent (reuse Generator with EVALUATION.md context)
  Task(
    subagent_type="task-executor",
    description="Harness Fix for phase ${PHASE_NUM} attempt ${FIX_ATTEMPT}",
    query="""
你是 Harness Fix Agent。你运行在完全独立的上下文中。

**你的任务**: 根据 EVALUATION.md 修复问题。

**必须读取的文件**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-EVALUATION.md（问题列表）
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md（规格要求）
- 代码文件（需要修复的文件）

**禁止读取的文件**:
- ❌ SUMMARY.md

**修复优先级**:
1. blocker 级别问题
2. high 级别问题
3. medium 级别问题

**输出**:
- 修复后的代码文件
- 更新 SUMMARY.md

**完成后返回**: 修复的问题列表
""",
    response_language="zh-CN"
  )
  
  # Re-evaluate
  Task(
    subagent_type="result-reviewer",
    description="Harness Re-evaluate phase ${PHASE_NUM} attempt ${FIX_ATTEMPT}",
    query="""
你是 Harness Evaluator Agent。重新评估修复后的代码。

**必须读取**:
- .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-SPEC.md
- 代码文件

**禁止读取**:
- ❌ SUMMARY.md
- ❌ 之前的 EVALUATION.md

**输出**: 更新 EVALUATION.md
""",
    response_language="zh-CN"
  )
  
  # Check new score
  NEW_SCORE=$(grep "^score:" .planning-harness/phases/${PHASE_NUM}-*/${PHASE_NUM}-EVALUATION.md | tail -1 | cut -d: -f2 | tr -d ' ')
  
  echo "Score after fix: ${NEW_SCORE}/10"
  
  if [[ $(echo "$NEW_SCORE >= 7" | bc) -eq 1 ]]; then
    echo ""
    echo "✅ Phase passed after ${FIX_ATTEMPT} fix attempt(s)!"
    exit 0
  fi
  
  # Check for stagnation (score didn't improve)
  if [[ $(echo "$NEW_SCORE <= $SCORE" | bc) -eq 1 ]]; then
    echo "⚠️ Score did not improve. Possible stagnation."
  fi
  
  SCORE=$NEW_SCORE
done

# Max attempts reached
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " MAX FIX ATTEMPTS REACHED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Score: ${SCORE}/10 after ${MAX_FIX_ATTEMPTS} attempts"
echo ""

AskUserQuestion(
  questions=[{
    header: "Stagnation",
    question: "Fix attempts did not achieve passing score. How to proceed?",
    options=[
      {"label": "Continue anyway", "description": "Accept current state and move to next phase"},
      {"label": "Manual fix", "description": "I'll fix the remaining issues manually"},
      {"label": "Stop", "description": "Stop here and review"}
    ]
  }]
)
```

</process>

<success_criteria>

- [ ] Arguments parsed correctly
- [ ] Banner displayed
- [ ] Planner Agent launched (or skipped)
- [ ] SPEC.md created (or already exists)
- [ ] PLAN.md created (or already exists)
- [ ] Sprint Contract negotiated (if --sprint-mode)
- [ ] Generator Agent launched
- [ ] Code files created
- [ ] SUMMARY.md created
- [ ] Evaluator Agent launched
- [ ] EVALUATION.md created with score
- [ ] Score evaluated and routed correctly
- [ ] Fix loop executed if needed (max attempts respected)
- [ ] User prompted for stagnation/failed cases

</success_criteria>
