先读这篇文章，理解文章所讲的内容，这个项目以后都按这个介绍的规范来实现。
https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

将PYTHON框架rqalpha， 用mojo语言重构，
要求
1.尽量保证功能，文件名称，类名，函数，方法名一致  
2.每个子任务复杂度可控、可独立验证。
3.明确输入 / 输出、验收标准、依赖关系。
4.生成任务依赖图（Mermaid），可视化流程。
5.优先用mojo已经有的模块。

注意事项：
PYTHON是用UV的方式安装的PYTHON3.14版本。
MOJO是用UV的方式安装的0.26.2.0版本。
在/home/zhou/hello_mojo/trae_cn_78/.venv/bin路径下, 使用时需要带上路径。
mojo文档地址：https://docs.modular.com/mojo/lib

Mojo函数定义规则（重要）：
Mojo 0.26+版本中，函数定义必须使用 `def` 而不是 `fn`：
- `def foo():` - 不抛出异常的函数
- `def bar() raises:` - 显式抛出 Error 的函数
- `def baz() raises EmptyDictError:` - 抛出特定类型错误的函数
- `fn` 关键字已弃用，所有新代码必须使用 `def`

示例：
```mojo
# 正确 ✓
def calculate_sum(a: Int, b: Int) -> Int:
    return a + b

def process_data(data: Dict) raises:
    if data.is_empty():
        raise Error("Empty data")
    # ...

# 错误 ✗ (fn 已弃用)
fn old_style():  # 不要使用
    pass
```

Mojo Python互操作配置：
由于Mojo编译的程序不自动链接Python库，运行包含Python互操作的Mojo程序时需要预加载Python动态库并设置Python模块路径：
export LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so
export PYTHONPATH=/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages
运行命令示例：
LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so PYTHONPATH=/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages /home/zhou/hello_mojo/trae_cn_78/.venv/bin/mojo run -I . <file.mojo>