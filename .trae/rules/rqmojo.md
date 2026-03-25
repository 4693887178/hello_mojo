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
LD\_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86\_64-gnu/lib/libpython3.14.so PYTHONPATH=/home/zhou/hello\_mojo/trae\_cn\_78/.venv/lib/python3.14/site-packages /home/zhou/hello\_mojo/trae\_cn\_78/.venv/bin/mojo run -I . \<file.mojo>
