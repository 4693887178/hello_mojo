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
