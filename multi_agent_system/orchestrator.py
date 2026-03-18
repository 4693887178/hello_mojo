"""
Multi-Agent Orchestrator
多Agent协作协调器 - 负责任务分发、协调和结果整合
"""

import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional
from dataclasses import dataclass

sys.path.insert(0, str(Path(__file__).parent.parent))

from shared_memory.memory_store import SharedMemory, Entity, Relation
from protocols.a2a_protocol import A2AProtocol, A2AMessageBus, Task, TaskState
from protocols.mcp_protocol import MCPProtocol


@dataclass
class AgentInfo:
    agent_id: str
    name: str
    capabilities: list[str]
    workspace: str
    endpoint: str
    protocol: Optional[A2AProtocol] = None


class Orchestrator:
    def __init__(self, config_path: str):
        self.config_path = Path(config_path)
        self.base_path = self.config_path.parent.parent
        
        self.shared_memory = SharedMemory(
            str(self.base_path / "shared_memory" / "memory.db")
        )
        self.mcp = MCPProtocol(
            str(self.base_path / "shared_memory" / "mcp_context.json")
        )
        self.message_bus = A2AMessageBus(
            str(self.base_path / "shared_memory" / "messages.json")
        )
        
        self.agents: dict[str, AgentInfo] = {}
        self.task_queue: list[Task] = []
        self.completed_tasks: list[Task] = []
        
        self._load_agents()
        self._init_session()
    
    def _load_agents(self):
        agents_dir = self.base_path / "agents"
        for agent_dir in agents_dir.iterdir():
            if agent_dir.is_dir():
                card_path = agent_dir / "agent_card.json"
                if card_path.exists():
                    with open(card_path) as f:
                        card = json.load(f)
                    
                    agent_info = AgentInfo(
                        agent_id=card["agent_id"],
                        name=card["name"],
                        capabilities=card["capabilities"],
                        workspace=card["workspace"],
                        endpoint=card["protocols"]["a2a"]["endpoint"]
                    )
                    self.agents[agent_info.agent_id] = agent_info
                    
                    self.shared_memory.create_entity(Entity(
                        name=agent_info.agent_id,
                        entity_type="agent",
                        observations=[f"能力: {', '.join(agent_info.capabilities)}"]
                    ))
    
    def _init_session(self):
        self.mcp.create_session("orchestrator")
        self.mcp.add_context(
            context_type="user_intent",
            content="多Agent协作系统初始化",
            source_agent="orchestrator"
        )
    
    def find_agent_by_capability(self, capability: str) -> Optional[AgentInfo]:
        for agent in self.agents.values():
            if capability in agent.capabilities:
                return agent
        return None
    
    def create_task(self, task_type: str, description: str, 
                    input_data: dict, required_capability: str = None) -> Task:
        task = Task(
            task_type=task_type,
            description=description,
            input_data=input_data
        )
        
        if required_capability:
            agent = self.find_agent_by_capability(required_capability)
            if agent:
                task.assigned_to = agent.agent_id
        
        self.task_queue.append(task)
        
        self.shared_memory.create_entity(Entity(
            name=task.task_id,
            entity_type="task",
            observations=[
                f"类型: {task_type}",
                f"描述: {description}",
                f"状态: {task.state.value}"
            ]
        ))
        
        self.mcp.add_context(
            context_type="decision",
            content={"task_id": task.task_id, "assigned_to": task.assigned_to},
            source_agent="orchestrator"
        )
        
        return task
    
    def dispatch_task(self, task: Task) -> bool:
        if not task.assigned_to:
            return False
        
        agent = self.agents.get(task.assigned_to)
        if not agent:
            return False
        
        self.message_bus.send_message(
            from_agent="orchestrator",
            to_agent=task.assigned_to,
            message_type="task_assignment",
            payload=task.to_dict()
        )
        
        task.state = TaskState.WORKING
        self.shared_memory.add_observation(task.task_id, f"已分派给 {task.assigned_to}")
        
        return True
    
    def check_task_status(self, task_id: str) -> Optional[dict]:
        messages = self.message_bus.receive_messages("orchestrator")
        
        for msg in messages:
            if msg["type"] == "task_result" and msg["payload"].get("task_id") == task_id:
                return msg["payload"]
        
        return None
    
    def coordinate_agents(self, workflow: list[dict]) -> list[dict]:
        results = []
        
        for step in workflow:
            task_type = step.get("task_type")
            description = step.get("description", "")
            input_data = step.get("input_data", {})
            required_capability = step.get("required_capability")
            depends_on = step.get("depends_on", [])
            
            for dep_task_id in depends_on:
                dep_result = self.check_task_status(dep_task_id)
                if dep_result:
                    input_data["dependency_result"] = dep_result
            
            task = self.create_task(task_type, description, input_data, required_capability)
            
            if self.dispatch_task(task):
                results.append({
                    "step": step.get("name", "unnamed"),
                    "task_id": task.task_id,
                    "assigned_to": task.assigned_to,
                    "status": "dispatched"
                })
            else:
                results.append({
                    "step": step.get("name", "unnamed"),
                    "task_id": task.task_id,
                    "status": "failed_to_dispatch"
                })
        
        return results
    
    def get_project_status(self) -> dict:
        graph = self.shared_memory.read_graph()
        
        tasks = [e for e in graph["entities"] if e["entityType"] == "task"]
        agents = [e for e in graph["entities"] if e["entityType"] == "agent"]
        
        pending = len([t for t in tasks if "状态: pending" in str(t["observations"])])
        in_progress = len([t for t in tasks if "状态: in_progress" in str(t["observations"])])
        completed = len([t for t in tasks if "状态: completed" in str(t["observations"])])
        
        return {
            "total_agents": len(agents),
            "total_tasks": len(tasks),
            "pending_tasks": pending,
            "in_progress_tasks": in_progress,
            "completed_tasks": completed,
            "recent_context": self.mcp.get_context_for_agent("orchestrator")
        }
    
    def broadcast_update(self, message: str):
        self.message_bus.broadcast(
            from_agent="orchestrator",
            message_type="project_update",
            payload={"message": message, "timestamp": datetime.now().isoformat()},
            recipients=list(self.agents.keys())
        )


def main():
    orchestrator = Orchestrator("/home/zhou/hello-world/multi_agent_system/config/orchestrator.yaml")
    
    print("=" * 60)
    print("Multi-Agent Orchestrator Initialized")
    print("=" * 60)
    
    print(f"\nRegistered Agents: {list(orchestrator.agents.keys())}")
    
    workflow = [
        {
            "name": "code_conversion",
            "task_type": "convert",
            "description": "将Python代码转换为Mojo",
            "input_data": {
                "source_file": "rqalpha/utils/datetime_func.py",
                "target_file": "rqmojo/utils/datetime_func.mojo"
            },
            "required_capability": "python_mojo_conversion"
        },
        {
            "name": "code_review",
            "task_type": "review",
            "description": "审查转换后的Mojo代码",
            "input_data": {
                "target_files": ["rqmojo/utils/datetime_func.mojo"]
            },
            "required_capability": "code_review",
            "depends_on": []
        }
    ]
    
    print("\n" + "=" * 60)
    print("Executing Workflow...")
    print("=" * 60)
    
    results = orchestrator.coordinate_agents(workflow)
    
    print("\nWorkflow Results:")
    print(json.dumps(results, indent=2, ensure_ascii=False))
    
    print("\n" + "=" * 60)
    print("Project Status")
    print("=" * 60)
    status = orchestrator.get_project_status()
    print(json.dumps(status, indent=2, ensure_ascii=False))
    
    print("\n" + "=" * 60)
    print("Shared Memory Graph")
    print("=" * 60)
    graph = orchestrator.shared_memory.read_graph()
    print(json.dumps(graph, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
