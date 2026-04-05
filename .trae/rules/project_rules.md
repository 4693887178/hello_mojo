# GSD Assets

GSD 是一套用于管理上下文的开发流程框架（或元提示词框架）。

有以下核心指令，当用户输入包含这些指令名时，你应当调用对应的技能文档。

| 指令（技能名） | 调用路径 | 用途 |
|----------|------|---------|
| `/gsd:new-project` | `~/.gsdc/new-project.md` | 初始化新项目 |
| `/gsd:new-milestone` | `~/.gsdc/new-milestone.md` | 开始新的里程碑周期 |
| `/gsd:discuss-phase` | `~/.gsdc/discuss-phase.md` | 规划前收集阶段上下文 |
| `/gsd:plan-phase` | `~/.gsdc/plan-phase.md` | 创建阶段计划 |
| `/gsd:research-phase` | `~/.gsdc/research-phase.md` | 研究阶段实现方案 |
| `/gsd:execute-phase` | `~/.gsdc/execute-phase.md` | 执行阶段计划 |
| `/gsd:verify-work` | `~/.gsdc/verify-work.md` | 验证阶段完成情况 |
| `/gsd:ship` | `~/.gsdc/ship.md` | 创建PR，运行review，准备合并 |
| `/gsd:map-codebase` | `~/.gsdc/map-codebase.md` | 分析现有代码 |
| `/gsd:progress` | `~/.gsdc/progress.md` | 检查项目进度 |
| `/gsd:debug` | `~/.gsdc/debug.md` | 系统化调试 |

更多指令请参考 `~/.gsdc/*`，完整指令列表：

```
add-phase
add-tests
add-todo
audit-milestone
check-todos
cleanup
complete-milestone
debug
discuss-phase
execute-phase
health
help
insert-phase
list-phase-assumptions
map-codebase
new-milestone
new-project
new-project.bak
pause-work
plan-milestone-gaps
plan-phase
progress
quick
reapply-patches
remove-phase
research-phase
resume-work
set-profile
settings
ship
update
verify-work
```

此外，在执行技能时，你可能需要参考以下文档中的其他资源：

* [GSD Agent](./gsd-agents.md)
* [提问技巧、Git、TDD、配置等可参考](./gsd-references.md)

---

## `/gsd:ship` 命令 SSL 证书问题解决方案

由于系统 SSL 证书配置问题，`gh` CLI 无法使用。使用 Python 脚本替代：

### 一行命令创建 PR

```bash
GITHUB_TOKEN=ghp_xxx /home/zhou/hello_mojo/trae_cn_78/.venv/bin/python /home/zhou/hello_mojo/trae_cn_78/github_pr.py create "标题" "描述" "分支名"
```

### 一行命令列出 PR

```bash
GITHUB_TOKEN=ghp_xxx /home/zhou/hello_mojo/trae_cn_78/.venv/bin/python /home/zhou/hello_mojo/trae_cn_78/github_pr.py list
```

**注意：** 将 `ghp_xxx` 替换为你的实际 GitHub Token。

---

# Harness 架构

Harness 是基于 Anthropic 工程博客 ["Harness design for long-running application development"](https://www.anthropic.com/engineering/harness-design-long-running-apps) 实现的独立开发框架。

**核心理念**: "Agent 不能自己评自己" - 通过独立 Agent 实现对抗性评估。

## 架构说明

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
│                   分数 < 7 ? → 修复循环                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Harness 指令

| 指令 | 调用路径 | 用途 |
|------|---------|------|
| `/harness:auto` | `.harness-source/commands/harness/auto.md` | 运行完整 Harness 流程 |

## 文件位置

```
.harness-source/
├── agents/
│   ├── harness-planner.md    # 规划 Agent
│   ├── harness-generator.md  # 生成 Agent
│   └── harness-evaluator.md  # 评估 Agent
├── commands/harness/
│   └── auto.md               # 自动流程指令
└── templates/
    ├── SPEC.md               # 规格文档模板
    └── EVALUATION.md         # 评估报告模板

.planning-harness/             # 独立的规划目录（与 .planning 并存）
├── PROJECT.md
├── ROADMAP.md
├── STATE.md
└── phases/
    └── {PHASE_NUM}-{slug}/
        ├── {PHASE_NUM}-SPEC.md       # 规格文档
        ├── {PHASE_NUM}-PLAN.md       # 执行计划
        ├── {PHASE_NUM}-SUMMARY.md    # 执行总结
        └── {PHASE_NUM}-EVALUATION.md # 评估报告
```

## 关键规则

### Evaluator 禁读文件

**Evaluator 必须独立评估，禁止读取：**
- ❌ SUMMARY.md（Generator 的自我评估）
- ❌ CONTEXT.md（讨论上下文）
- ❌ 任何包含"实现说明"、"设计决策"的文档

**原因**: Self-Evaluation Bias - AI 对自己生成的内容天然宽容。

### 评分标准

| 分数 | 含义 |
|-----|------|
| 10 | 完全符合规格 |
| 7-9 | 功能正常，有轻微差异 |
| 4-6 | 核心功能可用，有明显问题 |
| 1-3 | 基本不可用 |

### 修复循环

- 分数 < 7 时自动启动修复循环
- 最多 3 次修复尝试
- 连续 2 次分数无提升报告停滞

## 与 GSD 的关系

| 方面 | GSD | Harness |
|-----|-----|---------|
| 规划目录 | `.planning/` | `.planning-harness/` |
| Agent 通信 | 文件 + 上下文 | **仅文件** |
| 评估方式 | 对话式验证 | **独立评估 + 评分** |
| 上下文 | 共享 | **完全隔离** |

**两套系统完全独立，互不影响。**
