# 已安装 Skills 完整列表

> 更新时间：2026-04-03

---

## 🧬 OpenSpace 自进化引擎

| Skill | 功能 | 位置 |
|-------|------|------|
| delegate-task | 委派任务给 OpenSpace 执行，支持编码、DevOps、网页研究 | 项目 |
| skill-discovery | 搜索 OpenSpace 本地和云端技能库 | 项目 |

**MCP 工具**: `execute_task`, `search_skills`, `fix_skill`, `upload_skill`

**核心能力**:
- 🧬 自进化 - 任务成功时技能自动升级，失败时自动修复
- 🌐 群体智能 - 一个 Agent 学到的，全网 Agent 共享
- 💰 节省成本 - 46% 更少 token，4.2 倍收益

---

## 📋 开发流程与规划 (GSD)

| Skill | 功能 | 位置 |
|-------|------|------|
| gsd:new-project | 初始化新项目 | 全局 |
| gsd:new-milestone | 开始新的里程碑周期 | 全局 |
| gsd:discuss-phase | 规划前收集阶段上下文 | 全局 |
| gsd:plan-phase | 创建阶段计划 | 全局 |
| gsd:execute-phase | 执行阶段计划 | 全局 |
| gsd:verify-work | 验证阶段完成情况 | 全局 |
| gsd:debug | 系统化调试 | 全局 |
| gsd:ship | 创建PR，运行review，准备合并 | 全局 |
| gsd:progress | 检查项目进度 | 全局 |

---

## 🧪 测试与调试

| Skill | 功能 | 位置 |
|-------|------|------|
| test-driven-development | 测试驱动开发 (TDD) | 全局 |
| systematic-debugging | 系统化调试 | 全局 |
| iterative-development | Self-Refine/TDD 迭代循环 | 项目 |
| ralph-loop | Ralph Wiggum 长时间迭代循环 | 项目 |
| unit-test-generator | 单元测试生成器 | 项目 |

---

## 🔍 代码质量与审查

| Skill | 功能 | 位置 |
|-------|------|------|
| code-simplifier | 简化和优化代码 | 项目 |
| code-reviewer | 审查代码正确性、可维护性和项目规范 | 全局 |
| receiving-code-review | 接收代码审查反馈 | 全局 |
| agent-md-refactor | 重构 agent 指令文件 | 项目 |

---

## ⚡ 性能与安全

| Skill | 功能 | 位置 |
|-------|------|------|
| performance-optimizer | 性能优化器 | 项目 |
| memory-safety-patterns | 内存安全模式 | 项目 |

---

## 🔥 Mojo 语言专用

| Skill | 功能 | 位置 |
|-------|------|------|
| mojo-syntax | Mojo 语法指南 | 全局 |
| mojo-python-interop | Mojo-Python 互操作 | 全局 |
| mojo-gpu-fundamentals | Mojo GPU 编程基础 | 全局 |
| new-modular-project | 创建新的 Mojo/MAX 项目 | 全局 |

---

## 🗺️ 代码理解与探索

| Skill | 功能 | 位置 |
|-------|------|------|
| understand-anything-knowledge-graph | 代码库知识图谱，可视化探索 | 项目 |

---

## ⚙️ 自动化与编排

| Skill | 功能 | 位置 |
|-------|------|------|
| n8n-mcp-orchestrator | n8n MCP 编排器 | 项目 |

---

## ⚡ 并行与子代理

| Skill | 功能 | 位置 |
|-------|------|------|
| dispatching-parallel-agents | 分发并行代理 | 全局 |
| subagent-driven-development | 子代理驱动开发 | 全局 |

---

## 🌿 Git 工作流

| Skill | 功能 | 位置 |
|-------|------|------|
| gsd:using-git-worktrees | 使用 Git Worktrees | 全局 |

---

## 🛠️ 技能管理

| Skill | 功能 | 位置 |
|-------|------|------|
| find-skills | 发现和安装 skills | 全局 |
| writing-skills | 编写自定义 skills | 全局 |
| using-superpowers | 使用超能力技能 | 全局 |
| skill-creator | 创建新 skill（必用） | 全局 |
| tavily-search | Tavily 搜索工具 | 全局 |

---

## 🤖 自我改进

| Skill | 功能 | 位置 |
|-------|------|------|
| self-improving-agent | 自我改进agent，从所有skill经验中学习 | 全局 |

---

## 📊 统计

| 类别 | 数量 |
|------|------|
| 开发流程与规划 (GSD) | 9 |
| 测试与调试 | 5 |
| 代码质量与审查 | 4 |
| 性能与安全 | 2 |
| Mojo 语言专用 | 4 |
| 代码理解与探索 | 1 |
| 自动化与编排 | 1 |
| 并行与子代理 | 2 |
| Git 工作流 | 1 |
| 技能管理 | 5 |
| 自我改进 | 1 |
| **总计** | **35** |

---

## 📁 安装位置

- **全局 Skills**: `~/.agents/skills/`
- **项目 Skills**: `/home/zhou/hello_mojo/trae_cn_78/.trae/skills/`
- **GSD Skills**: `~/.gsdc/`

---

## 🔧 安装命令

```bash
# 安装 skill 到项目
npx skills add <owner/repo@skill> --path /home/zhou/hello_mojo/trae_cn_78/.trae/skills -y

# 安装 skill 到全局
npx skills add <owner/repo@skill> -g -y

# 搜索 skill
npx skills find <keyword>
```

---

## 🗑️ 已删除的重复技能 (2026-03-27)

以下技能因与 GSD 技能重复已被删除：

| 删除的技能 | 替代技能 |
|-----------|---------|
| using-git-worktrees | gsd:using-git-worktrees |
| openclaw-config | gsd:openclaw-config |
| verification-before-completion | gsd:verify-work |
| writing-plans | gsd:plan-phase |
| executing-plans | gsd:execute-phase |
| requesting-code-review | gsd:review |
| brainstorming | gsd:discuss-phase |
