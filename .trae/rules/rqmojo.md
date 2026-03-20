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
在/home/zhou/hello_mojo/.venv/bin路径下, 使用时需要带上路径。
mojo文档地址：https://docs.modular.com/mojo/lib

Mojo Python互操作配置：
由于Mojo编译的程序不自动链接Python库，运行包含Python互操作的Mojo程序时需要预加载Python动态库并设置Python模块路径：
export LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so
export PYTHONPATH=/home/zhou/hello_mojo/.venv/lib/python3.14/site-packages
运行命令示例：
LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so PYTHONPATH=/home/zhou/hello_mojo/.venv/lib/python3.14/site-packages /home/zhou/hello_mojo/.venv/bin/mojo run -I . <file.mojo>