"""
完整的多Agent协作演示
展示从任务创建到执行的完整流程
"""

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from shared_memory.memory_store import SharedMemory, Entity
from protocols.a2a_protocol import A2AMessageBus, Task
from protocols.mcp_protocol import MCPProtocol


def print_section(title: str):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def demo_full_workflow():
    base_path = Path("/home/zhou/hello-world/multi_agent_system")
    
    shared_memory = SharedMemory(str(base_path / "shared_memory" / "memory.db"))
    message_bus = A2AMessageBus(str(base_path / "shared_memory" / "messages.json"))
    mcp = MCPProtocol(str(base_path / "shared_memory" / "mcp_context.json"))
    
    print_section("步骤1: 初始化共享记忆和MCP会话")
    
    session_id = mcp.create_session("demo-orchestrator")
    print(f"创建MCP会话: {session_id}")
    
    mcp.add_context(
        context_type="user_intent",
        content="演示多Agent协作：Python到Mojo的代码转换和审查",
        source_agent="orchestrator"
    )
    
    shared_memory.create_entity(Entity(
        name="demo-task-001",
        entity_type="task",
        observations=["演示任务", "状态: 待处理"]
    ))
    
    print_section("步骤2: Orchestrator创建任务")
    
    task1 = Task(
        task_type="convert",
        description="将datetime_func.py转换为Mojo",
        input_data={
            "source_file": "mojo_refactor/rqmojo/utils/datetime_func.mojo",
            "target_file": "mojo_refactor/rqmojo/utils/datetime_func_v2.mojo"
        },
        assigned_to="codebuddy-cn"
    )
    
    print(f"任务1: {task1.task_type}")
    print(f"  描述: {task1.description}")
    print(f"  分配给: {task1.assigned_to}")
    
    message_bus.send_message(
        from_agent="orchestrator",
        to_agent="codebuddy-cn",
        message_type="task_assignment",
        payload=task1.to_dict()
    )
    print("  -> 任务已发送到消息队列")
    
    print_section("步骤3: CodeBuddy CN Agent接收并执行任务")
    
    messages = message_bus.receive_messages("codebuddy-cn")
    print(f"收到 {len(messages)} 条消息")
    
    if messages:
        task_data = messages[0]["payload"]
        print(f"  任务类型: {task_data['task_type']}")
        print(f"  输入数据: {json.dumps(task_data['input_data'], indent=4)}")
        
        shared_memory.add_observation("demo-task-001", "[codebuddy-cn] 开始处理转换任务")
        
        result = {
            "status": "completed",
            "summary": "Python -> Mojo 转换完成",
            "files_created": ["datetime_func_v2.mojo"],
            "conversion_notes": ["类型注解已转换", "函数签名已更新"]
        }
        
        message_bus.send_message(
            from_agent="codebuddy-cn",
            to_agent="orchestrator",
            message_type="task_result",
            payload={"task_id": task_data["task_id"], "result": result}
        )
        print("  -> 结果已发送回Orchestrator")
    
    print_section("步骤4: Orchestrator创建审查任务")
    
    task2 = Task(
        task_type="review",
        description="审查转换后的Mojo代码",
        input_data={
            "target_files": ["mojo_refactor/rqmojo/utils/datetime_func_v2.mojo"]
        },
        assigned_to="trae-cn"
    )
    
    print(f"任务2: {task2.task_type}")
    print(f"  描述: {task2.description}")
    print(f"  分配给: {task2.assigned_to}")
    
    message_bus.send_message(
        from_agent="orchestrator",
        to_agent="trae-cn",
        message_type="task_assignment",
        payload=task2.to_dict()
    )
    print("  -> 任务已发送到消息队列")
    
    print_section("步骤5: TRAE CN Agent接收并执行审查任务")
    
    messages = message_bus.receive_messages("trae-cn")
    print(f"收到 {len(messages)} 条消息")
    
    if messages:
        task_data = messages[0]["payload"]
        print(f"  任务类型: {task_data['task_type']}")
        print(f"  输入数据: {json.dumps(task_data['input_data'], indent=4)}")
        
        shared_memory.add_observation("demo-task-001", "[trae-cn] 开始审查代码")
        
        result = {
            "status": "completed",
            "summary": "代码审查完成",
            "issues": [
                {"type": "style", "message": "建议添加文档注释"}
            ],
            "approved": True
        }
        
        message_bus.send_message(
            from_agent="trae-cn",
            to_agent="orchestrator",
            message_type="task_result",
            payload={"task_id": task_data["task_id"], "result": result}
        )
        print("  -> 审查结果已发送回Orchestrator")
    
    print_section("步骤6: Orchestrator收集结果并更新共享记忆")
    
    results = message_bus.receive_messages("orchestrator")
    print(f"收到 {len(results)} 个结果")
    
    for msg in results:
        if msg["type"] == "task_result":
            print(f"  任务ID: {msg['payload']['task_id']}")
            print(f"  结果: {json.dumps(msg['payload']['result'], indent=4, ensure_ascii=False)}")
    
    mcp.add_context(
        context_type="decision",
        content={
            "decision": "代码转换和审查流程完成",
            "approved": True
        },
        source_agent="orchestrator"
    )
    
    shared_memory.add_observation("demo-task-001", "任务完成")
    
    print_section("步骤7: 查看最终共享记忆状态")
    
    graph = shared_memory.read_graph()
    print("知识图谱实体:")
    for entity in graph["entities"]:
        print(f"  - {entity['name']} ({entity['entityType']})")
        for obs in entity["observations"]:
            print(f"      • {obs}")
    
    print("\n知识图谱关系:")
    for relation in graph["relations"]:
        print(f"  - {relation['from']} --[{relation['relationType']}]--> {relation['to']}")
    
    print_section("步骤8: 查看MCP上下文")
    
    context = mcp.get_context_for_agent("orchestrator")
    print("MCP上下文条目:")
    for entry in context.get("context", []):
        print(f"  - [{entry['context_type']}] {entry['content']}")
        print(f"    来源: {entry['source_agent']}")
    
    print_section("演示完成!")
    print("""
工作流程总结:
1. Orchestrator 创建任务并发送到消息队列
2. Agent 从消息队列接收任务
3. Agent 执行任务并更新共享记忆
4. Agent 将结果发送回 Orchestrator
5. Orchestrator 收集结果并更新 MCP 上下文
6. 所有 Agent 可以通过共享记忆了解项目状态

关键文件:
- 消息队列: shared_memory/messages.json
- 知识图谱: shared_memory/memory.db
- MCP上下文: shared_memory/mcp_context.json
""")


if __name__ == "__main__":
    demo_full_workflow()
