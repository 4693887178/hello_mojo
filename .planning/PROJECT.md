# PROJECT.md

## Project: RQAlpha Mojo Refactoring

### Overview
将 Python 量化交易框架 RQAlpha 使用 Mojo 语言重构，保持功能、文件名称、类名、函数、方法名一致。

### Tech Stack
- **Python**: 3.14 (UV 安装)
- **Mojo**: 0.26.2.0 (UV 安装)
- **Python RQAlpha**: `.venv/lib/python3.14/site-packages/rqalpha`
- **Mojo RQMojo**: `mojo_refactor/rqmojo`

### Project Structure
```
mojo_refactor/
├── rqmojo/                    # Mojo 重构代码
│   ├── third_party/           # 第三方 Mojo 包
│   │   ├── argmojo/           # 命令行参数解析
│   │   ├── EmberJson/         # JSON 解析
│   │   ├── NuMojo/            # 数值计算
│   │   ├── mojo-yaml/         # YAML 解析
│   │   └── morrow.mojo/       # 日期时间处理
│   └── ...
├── tests/
│   ├── python/                # Python 测试文件
│   ├── mojo/                  # Mojo 测试文件
│   └── results/               # 测试结果 (MD格式)
└── docs/                      # 文档
```

### Milestones

#### Milestone 1: 基础模块重构 (Group 01-06)
**Status**: ✅ Completed
**Description**: 完成依赖数量 0-3 的基础模块重构

**Completed Groups**:
- Group 01: 无依赖基础模块 (10 files)
- Group 02: 依赖数量 0-1 模块 (10 files)
- Group 03: 依赖数量 1-2 模块 (10 files)
- Group 04: 依赖数量 2 模块 (10 files)
- Group 05: 依赖数量 2 模块 (10 files)
- Group 06: 依赖数量 2-3 模块 (10 files)

#### Milestone 2: 核心模块重构 (Group 07)
**Status**: ✅ Completed
**Description**: 完成依赖数量 3-4 的核心模块重构

**Completed Groups**:
- Group 07: 依赖数量 3-4 模块 (10 files)

#### Milestone 3: 业务层重构 (Group 08-09)
**Status**: 🔄 In Progress
**Description**: 完成依赖数量 4-5 的业务层模块重构

**Groups**:
- Group 08: 依赖数量 4 模块 (10 files) - 待验证
- Group 09: 依赖数量 4-5 模块 (10 files) - ✅ 测试通过

#### Milestone 4: 高级业务层重构 (Group 10-12)
**Status**: ⏳ Pending
**Description**: 完成依赖数量 5-10 的高级业务层模块重构

**Groups**:
- Group 10: 依赖数量 5-6 模块 (10 files)
- Group 11: 依赖数量 6 模块 (10 files)
- Group 12: 依赖数量 7-10 模块 (10 files)

#### Milestone 5: 入口层重构 (Group 13)
**Status**: ⏳ Pending
**Description**: 完成依赖数量 15+ 的入口层模块重构

**Groups**:
- Group 13: 依赖数量 15+ 模块 (3 files)

### Current Milestone: Milestone 3 - 业务层重构 (Group 08-09)

**Goal**: 完成 Group 08-09 的重构和测试验证

**Target**:
- Group 08: 10 个文件的 Mojo 测试验证
- Group 09: ✅ 已完成测试验证

**Tasks**:
- [x] Group 09 Mojo 测试修复 (16 files)
- [ ] Group 08 Mojo 测试验证
- [ ] 修复 Group 08 编译问题

### Key Decisions
1. 使用工厂函数模式 (`create_*()`) 替代直接构造函数
2. 使用 struct 替代 dict 进行配置
3. 保留 Python 命名规范，但允许 Mojo 特定优化
4. 不支持 Python 特有功能（如 context manager, decorator）时提供替代方案

### Notes
- Mojo 编译需要预加载 Python 动态库
- 运行命令示例见 project_rules.md
