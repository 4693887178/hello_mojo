# 已安装 Skills 完整列表

> 更新时间：2026-03-25

---

## 📋 开发流程与规划

| Skill | 功能 | 位置 |
|-------|------|------|
| brainstorming | 创意头脑风暴，设计前探索需求 | 全局 |
| writing-plans | 编写实现计划 | 全局 |
| executing-plans | 执行实现计划 | 全局 |
| verification-before-completion | 完成前验证 | 全局 |
| finishing-a-development-branch | 完成开发分支 | 全局 |

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
| requesting-code-review | 请求代码审查 | 全局 |
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
| openclaw | OpenClaw (龙虾/任意虾) 管理器，安装和配置 | 全局 |

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
| using-git-worktrees | 使用 Git Worktrees | 全局 |

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

## 📝 代码审查

| Skill | 功能 | 位置 |
|-------|------|------|
| code-reviewer | 审查代码正确性、可维护性和项目规范 | 全局 |

---

## 📊 统计

| 类别 | 数量 |
|------|------|
| 开发流程与规划 | 5 |
| 测试与调试 | 5 |
| 代码质量与审查 | 4 |
| 性能与安全 | 2 |
| Mojo 语言专用 | 4 |
| 代码理解与探索 | 1 |
| 自动化与编排 | 2 |
| 并行与子代理 | 2 |
| Git 工作流 | 1 |
| 技能管理 | 5 |
| 自我改进 | 1 |
| 代码审查 | 1 |
| **总计** | **33** |

---

## 📁 安装位置

- **全局 Skills**: `~/.agents/skills/`
- **项目 Skills**: `/home/zhou/hello_mojo/trae_cn_78/.agents/skills/`

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
