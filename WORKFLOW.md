---
max_concurrency: 3
poll_interval_ms: 30000
max_retry_backoff_ms: 300000
# 使用美团 LongCat API
model: LongCat-Flash-Chat
agent_timeout_ms: 3600000
stall_timeout_ms: 300000

tracker:
  type: github
  token: $GITHUB_TOKEN
  owner: 4693887178
  repo: hello-world
  active_states:
    - "open"
  terminal_states:
    - "closed"

agent:
  type: codex

codex:
  # 通过环境变量注入 OpenAI 兼容接口配置
  # binary_path 将使用 npx 调用并传递环境变量
  binary_path: OPENAI_API_KEY=$LONGCAT_API_KEY OPENAI_BASE_URL=https://api.longcat.chat/v1 npx @openai/codex app-server
  approval_policy: never
  thread_sandbox: workspace-write
  turn_timeout_ms: 3600000
  read_timeout_ms: 5000
  stall_timeout_ms: 300000

workspace:
  root: /home/zhou/hello-world/symphony_workspaces

hooks:
  after_create: |
    git clone --depth 1 https://github.com/4693887178/hello-world.git .
    git checkout -b mojo-refactor/${issue.identifier}
  before_run: |
    echo "Starting Mojo refactor for ${issue.identifier}"
  timeout_ms: 120000

server:
  port: 4321

---

# Mojo 重构任务

你正在将 Python 的 **rqalpha** 量化交易框架重构为 **Mojo** 语言。

## 任务信息

- **Issue ID**: {{ issue.title }}
- **描述**: {{ issue.description }}
- **URL**: {{ issue.url }}

## 重构规范

### 1. 保持一致性
- 文件名称保持一致
- 类名保持一致
- 函数名保持一致
- 方法名保持一致

### 2. Mojo 特性要求
- 使用 Mojo 0.26.1 语法
- 优先使用 Mojo 内置模块
- 每个 Mojo 文件需要可独立验证

### 3. Python 互操作
运行 Mojo 程序时需要设置环境变量：
```bash
export LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so
export PYTHONPATH=/home/zhou/hello-world/.venv/lib/python3.14/site-packages
```

运行命令示例：
```bash
LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so \
PYTHONPATH=/home/zhou/hello-world/.venv/lib/python3.14/site-packages \
/home/zhou/hello-world/.venv/bin/mojo run -I . <file.mojo>
```

### 4. 验收标准
- [ ] 代码编译通过
- [ ] 功能测试通过
- [ ] 代码风格符合 Mojo 规范
- [ ] 文档注释完整

## 工作流程

1. **分析** Python 源码结构和功能
2. **设计** Mojo 模块结构
3. **实现** Mojo 代码
4. **测试** 验证功能正确性
5. **提交** 创建 PR 并等待审查

## 注意事项

- 每个子任务复杂度可控、可独立验证
- 明确输入/输出、验收标准、依赖关系
- 遇到问题时在 issue 中留言说明
