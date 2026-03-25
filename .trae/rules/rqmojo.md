先读这篇文章，理解文章所讲的内容，这个项目以后都按这个介绍的规范来实现。
<https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents>

## 开发前准备

**重要：在编写或修改任何 Mojo 代码之前，必须先调用以下两个 skill：**

1. **`mojo-syntax`** - 获取最新的 Mojo 语法规范（如果可用）
2. **`mojo-python-interop`** - 获取 Mojo-Python 互操作指南

这两个 skill 提供了关键的语法修正和互操作模式，确保代码符合当前 Mojo 版本（0.26.2.0）的要求。

---

将PYTHON框架rqalpha， 用mojo语言重构，
要求
1.尽量保证功能，文件名称，类名，函数，方法名一致\
2.每个子任务复杂度可控、可独立验证。
3.明确输入 / 输出、验收标准、依赖关系。
4.生成任务依赖图（Mermaid），可视化流程。
5.优先用mojo已经有的模块。

注意事项：
PYTHON是用UV的方式安装的PYTHON3.14版本。
MOJO是用UV的方式安装的0.26.2.0版本。
在/home/zhou/hello\_mojo/trae\_cn\_78/.venv/bin路径下, 使用时需要带上路径。
mojo文档地址：<https://docs.modular.com/mojo/lib>

python rqalpha 位置：/home/zhou/hello\_mojo/trae\_cn\_78/.venv/lib/python3.14/site-packages/rqalpha

mojo重构文件位置：/home/zhou/hello\_mojo/trae\_cn\_78/mojo\_refactor/rqmojo

python测试文件存放位置：/home/zhou/hello\_mojo/trae\_cn\_78/mojo\_refactor/tests/python

mojo测试文件存放位置：/home/zhou/hello\_mojo/trae\_cn\_78/mojo\_refactor/tests/mojo

md格式的测试结果存放位置：/home/zhou/hello\_mojo/trae\_cn\_78/mojo\_refactor/tests/results对应实现目录下。

Mojo Python互操作配置：
由于Mojo编译的程序不自动链接Python库，运行包含Python互操作的Mojo程序时需要预加载Python动态库并设置Python模块路径：
export LD\_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86\_64-gnu/lib/libpython3.14.so
export PYTHONPATH=/home/zhou/hello\_mojo/trae\_cn\_78/.venv/lib/python3.14/site-packages
运行命令示例：
LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so PYTHONPATH=/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages /home/zhou/hello_mojo/trae_cn_78/.venv/bin/mojo run -I . <file.mojo>

## 第三方 Mojo 包

项目使用以下第三方 Mojo 包，位于 `mojo_refactor/rqmojo/third_party/` 目录：

| 包名 | 路径 | 用途 | 导入方式 |
|-----|------|------|---------|
| **argmojo** | `third_party/argmojo/src/` | 命令行参数解析 | `from argmojo import Argument, Arg, Command, ParseResult` |
| **EmberJson** | `third_party/EmberJson/` | JSON 解析 | `from emberjson import Value, JSON, Array, Object, parse` |
| **NuMojo** | `third_party/NuMojo/` | 数值计算 (NDArray) | `from numojo import NDArray, zeros, ones, array` |
| **mojo-yaml** | `third_party/mojo-yaml/src/` | YAML 解析 | `from yaml import parse, YamlValue, Lexer, Parser` |
| **morrow** | `third_party/morrow.mojo/` | 日期时间处理 | `from morrow import Morrow, TimeZone, TimeDelta` |

### 编译时包含第三方包

编译或运行时需要使用多个 `-I` 参数指定每个包的路径：

```bash
mojo build -I rqmojo/third_party/argmojo/src -I rqmojo/third_party/EmberJson -I rqmojo/third_party/NuMojo -I rqmojo/third_party/mojo-yaml/src -I rqmojo/third_party/morrow.mojo <file.mojo>
```

### NuMojo 已修复的语法问题

NuMojo 库已针对 Mojo 0.26.2.0 进行了修复，主要修改：

1. `alias` → `comptime`
2. `@register_passable("trivial")` → `TrivialRegisterPassable` trait
3. `@register_passable` → `RegisterPassable` trait
4. `__copyinit__(out self, other: Self)` → `__init__(out self, *, copy: Self)`
5. `__moveinit__(out self, deinit existing: Self)` → `__init__(out self, *, deinit take: Self)`
6. `VariadicList[Int]` → `VariadicList[Int, _]`
7. `MutOrigin.external` → `MutExternalOrigin`
8. `UnsafePointer[T]` → `UnsafePointer[T, MutExternalOrigin]` (需要显式 origin 参数)
9. `EqualityComparable` → `Equatable`
10. `Representable` / `Stringable` → `Writable`
11. 字符串切片 `str[:n]` → `str[byte=0:n]`
12. `Int(python_obj)` → `Int(py=python_obj)`