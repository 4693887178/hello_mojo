"""
TRAE CN 分配任务给 CodeBuddy CN
任务：给 life.mojo 的 main 函数添加装饰器
"""

import json
import sys
from pathlib import Path
from datetime import datetime

sys.path.insert(0, str(Path(__file__).parent))

from shared_memory.memory_store import SharedMemory, Entity
from protocols.a2a_protocol import A2AMessageBus, Task


def main():
    base_path = Path("/home/zhou/hello-world/multi_agent_system")
    
    shared_memory = SharedMemory(str(base_path / "shared_memory" / "memory.db"))
    message_bus = A2AMessageBus(str(base_path / "shared_memory" / "messages.json"))
    
    print("=" * 60)
    print("TRAE CN: 创建任务并分配给 CodeBuddy CN")
    print("=" * 60)
    
    task = Task(
        task_type="write",
        description="给 life.mojo 的 main 函数添加一个计时装饰器",
        input_data={
            "target_file": "life.mojo",
            "task_id": "task-decorator-001",
            "specification": """
在 /home/zhou/hello-world/life.mojo 文件中：
1. 添加一个计时装饰器函数 `timed`
2. 用这个装饰器装饰 main 函数
3. 装饰器应该在函数执行前后打印时间

当前代码：
```mojo
# My first Mojo program!
def main():
    print("Hello, World!")
```

期望效果：运行时显示函数执行时间
""",
            "language": "mojo"
        },
        assigned_to="codebuddy-cn"
    )
    
    message_bus.send_message(
        from_agent="trae-cn",
        to_agent="codebuddy-cn",
        message_type="task_assignment",
        payload=task.to_dict()
    )
    
    shared_memory.create_entity(Entity(
        name="task-decorator-001",
        entity_type="task",
        observations=[
            "类型: write",
            "描述: 添加计时装饰器",
            "创建者: trae-cn",
            f"创建时间: {datetime.now().isoformat()}",
            "状态: 已发送，等待 CodeBuddy CN 处理"
        ]
    ))
    
    print(f"\n✓ 任务已发送!")
    print(f"  任务ID: {task.task_id}")
    print(f"  任务类型: {task.task_type}")
    print(f"  目标文件: life.mojo")
    print(f"  要求: 添加计时装饰器")
    print(f"\n等待 CodeBuddy CN 处理...")
    print(f"\n提示: CodeBuddy CN 需要运行以下命令来接收任务:")
    print(f"  cd /home/zhou/hello-world/multi_agent_system")
    print(f"  /home/zhou/hello-world/.venv/bin/python agents/codebuddy_cn/worker.py")


if __name__ == "__main__":
    main()
