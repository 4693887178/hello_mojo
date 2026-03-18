"""
A2A (Agent-to-Agent) Protocol Implementation
基于Google A2A协议的Agent间通信实现
"""

import json
import uuid
from datetime import datetime
from enum import Enum
from dataclasses import dataclass, field, asdict
from typing import Any, Optional, Callable
from pathlib import Path


class TaskState(Enum):
    SUBMITTED = "submitted"
    WORKING = "working"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELED = "canceled"


@dataclass
class AgentCard:
    agent_id: str
    name: str
    version: str
    description: str
    capabilities: list[str]
    workspace: str
    endpoint: str
    input_schema: dict
    output_schema: dict
    authentication: dict
    
    @classmethod
    def from_json(cls, path: str) -> "AgentCard":
        with open(path) as f:
            data = json.load(f)
        return cls(
            agent_id=data["agent_id"],
            name=data["name"],
            version=data["version"],
            description=data["description"],
            capabilities=data["capabilities"],
            workspace=data["workspace"],
            endpoint=data["protocols"]["a2a"]["endpoint"],
            input_schema=data["input_schema"],
            output_schema=data["output_schema"],
            authentication=data["authentication"]
        )
    
    def to_well_known(self) -> dict:
        return {
            "agent_id": self.agent_id,
            "name": self.name,
            "version": self.version,
            "capabilities": self.capabilities,
            "endpoint": self.endpoint
        }


@dataclass
class Task:
    task_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    task_type: str = ""
    description: str = ""
    input_data: dict = field(default_factory=dict)
    state: TaskState = TaskState.SUBMITTED
    assigned_to: str = ""
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    updated_at: str = field(default_factory=lambda: datetime.now().isoformat())
    result: Optional[dict] = None
    error: Optional[str] = None
    
    def to_dict(self) -> dict:
        return {
            "task_id": self.task_id,
            "task_type": self.task_type,
            "description": self.description,
            "input_data": self.input_data,
            "state": self.state.value,
            "assigned_to": self.assigned_to,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "result": self.result,
            "error": self.error
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> "Task":
        return cls(
            task_id=data.get("task_id", str(uuid.uuid4())),
            task_type=data.get("task_type", ""),
            description=data.get("description", ""),
            input_data=data.get("input_data", {}),
            state=TaskState(data.get("state", "submitted")),
            assigned_to=data.get("assigned_to", ""),
            created_at=data.get("created_at", datetime.now().isoformat()),
            updated_at=data.get("updated_at", datetime.now().isoformat()),
            result=data.get("result"),
            error=data.get("error")
        )


@dataclass
class AIC:
    """
    Agent Interface Contract - 语义化协商式契约
    """
    contract_id: str
    input_type: str
    output_type: str
    semantics: dict
    constraints: list[str] = field(default_factory=list)
    
    def validate_input(self, data: dict) -> bool:
        return True
    
    def validate_output(self, data: dict) -> bool:
        return True


class A2AProtocol:
    def __init__(self, agent_card_path: str):
        self.agent_card = AgentCard.from_json(agent_card_path)
        self.tasks: dict[str, Task] = {}
        self.handlers: dict[str, Callable] = {}
    
    def register_handler(self, task_type: str, handler: Callable):
        self.handlers[task_type] = handler
    
    def create_task(self, task_type: str, description: str, 
                    input_data: dict, assign_to: str = "") -> Task:
        task = Task(
            task_type=task_type,
            description=description,
            input_data=input_data,
            assigned_to=assign_to
        )
        self.tasks[task.task_id] = task
        return task
    
    def submit_task(self, task: Task, target_agent: AgentCard) -> dict:
        task.state = TaskState.SUBMITTED
        task.assigned_to = target_agent.agent_id
        task.updated_at = datetime.now().isoformat()
        
        return {
            "status": "submitted",
            "task_id": task.task_id,
            "target_agent": target_agent.agent_id,
            "endpoint": target_agent.endpoint
        }
    
    def receive_task(self, task_data: dict) -> Task:
        task = Task.from_dict(task_data)
        task.state = TaskState.WORKING
        task.updated_at = datetime.now().isoformat()
        self.tasks[task.task_id] = task
        return task
    
    def execute_task(self, task_id: str) -> dict:
        task = self.tasks.get(task_id)
        if not task:
            return {"error": "Task not found"}
        
        handler = self.handlers.get(task.task_type)
        if not handler:
            task.state = TaskState.FAILED
            task.error = f"No handler for task type: {task.task_type}"
            return task.to_dict()
        
        try:
            result = handler(task.input_data)
            task.state = TaskState.COMPLETED
            task.result = result
        except Exception as e:
            task.state = TaskState.FAILED
            task.error = str(e)
        
        task.updated_at = datetime.now().isoformat()
        return task.to_dict()
    
    def get_task_status(self, task_id: str) -> Optional[dict]:
        task = self.tasks.get(task_id)
        return task.to_dict() if task else None
    
    def get_agent_card(self) -> dict:
        return self.agent_card.to_well_known()


class A2AMessageBus:
    def __init__(self, storage_path: str = "/home/zhou/hello-world/multi_agent_system/shared_memory/messages.json"):
        self.storage_path = Path(storage_path)
        self.storage_path.parent.mkdir(parents=True, exist_ok=True)
        if not self.storage_path.exists():
            with open(self.storage_path, "w") as f:
                json.dump({"messages": []}, f)
    
    def send_message(self, from_agent: str, to_agent: str, 
                     message_type: str, payload: dict) -> str:
        message_id = str(uuid.uuid4())
        message = {
            "id": message_id,
            "from": from_agent,
            "to": to_agent,
            "type": message_type,
            "payload": payload,
            "timestamp": datetime.now().isoformat(),
            "read": False
        }
        
        with open(self.storage_path) as f:
            data = json.load(f)
        data["messages"].append(message)
        with open(self.storage_path, "w") as f:
            json.dump(data, f, indent=2)
        
        return message_id
    
    def receive_messages(self, agent_id: str) -> list[dict]:
        with open(self.storage_path) as f:
            data = json.load(f)
        
        messages = [
            msg for msg in data["messages"]
            if msg["to"] == agent_id and not msg["read"]
        ]
        
        for msg in messages:
            msg["read"] = True
        
        with open(self.storage_path, "w") as f:
            json.dump(data, f, indent=2)
        
        return messages
    
    def broadcast(self, from_agent: str, message_type: str, payload: dict, 
                  recipients: list[str]) -> list[str]:
        message_ids = []
        for recipient in recipients:
            msg_id = self.send_message(from_agent, recipient, message_type, payload)
            message_ids.append(msg_id)
        return message_ids


if __name__ == "__main__":
    protocol = A2AProtocol("/home/zhou/hello-world/multi_agent_system/agents/trae_cn/agent_card.json")
    
    print("Agent Card:")
    print(json.dumps(protocol.get_agent_card(), indent=2))
    
    task = protocol.create_task(
        task_type="code_review",
        description="Review the mojo refactored code",
        input_data={"files": ["rqmojo/utils/datetime_func.mojo"]}
    )
    
    print("\nCreated Task:")
    print(json.dumps(task.to_dict(), indent=2))
