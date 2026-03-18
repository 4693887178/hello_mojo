"""
Agent Worker - Agent工作脚本基类
每个Agent需要实现这个基类来接入协作系统
"""

import json
import time
import sys
from pathlib import Path
from datetime import datetime
from typing import Optional, Callable
from abc import ABC, abstractmethod

sys.path.insert(0, str(Path(__file__).parent.parent))

from shared_memory.memory_store import SharedMemory, Entity
from protocols.a2a_protocol import A2AMessageBus, Task, TaskState


class AgentWorker(ABC):
    def __init__(self, agent_id: str, base_path: str = "/home/zhou/hello-world/multi_agent_system"):
        self.agent_id = agent_id
        self.base_path = Path(base_path)
        
        self.shared_memory = SharedMemory(
            str(self.base_path / "shared_memory" / "memory.db")
        )
        self.message_bus = A2AMessageBus(
            str(self.base_path / "shared_memory" / "messages.json")
        )
        
        self.workspace = self.base_path / "workspaces" / agent_id.replace("-", "_")
        self.workspace.mkdir(parents=True, exist_ok=True)
        
        self.task_handlers: dict[str, Callable] = {}
        self.current_task: Optional[Task] = None
        
        self._register_handlers()
    
    @abstractmethod
    def _register_handlers(self):
        pass
    
    def register_handler(self, task_type: str, handler: Callable):
        self.task_handlers[task_type] = handler
    
    def poll_for_tasks(self) -> list[dict]:
        messages = self.message_bus.receive_messages(self.agent_id)
        tasks = []
        for msg in messages:
            if msg["type"] == "task_assignment":
                tasks.append(msg["payload"])
        return tasks
    
    def receive_task(self, task_data: dict) -> Task:
        task = Task.from_dict(task_data)
        task.state = TaskState.WORKING
        task.updated_at = datetime.now().isoformat()
        self.current_task = task
        
        self.shared_memory.add_observation(
            task.task_id, 
            f"[{self.agent_id}] 开始处理任务"
        )
        
        return task
    
    def execute_task(self, task: Task) -> dict:
        handler = self.task_handlers.get(task.task_type)
        
        if not handler:
            return self._fail_task(task, f"No handler for task type: {task.task_type}")
        
        try:
            result = handler(task.input_data)
            return self._complete_task(task, result)
        except Exception as e:
            return self._fail_task(task, str(e))
    
    def _complete_task(self, task: Task, result: dict) -> dict:
        task.state = TaskState.COMPLETED
        task.result = result
        task.updated_at = datetime.now().isoformat()
        
        self.shared_memory.add_observation(
            task.task_id,
            f"[{self.agent_id}] 任务完成: {result.get('summary', 'done')}"
        )
        
        self._report_result(task)
        return task.to_dict()
    
    def _fail_task(self, task: Task, error: str) -> dict:
        task.state = TaskState.FAILED
        task.error = error
        task.updated_at = datetime.now().isoformat()
        
        self.shared_memory.add_observation(
            task.task_id,
            f"[{self.agent_id}] 任务失败: {error}"
        )
        
        self._report_result(task)
        return task.to_dict()
    
    def _report_result(self, task: Task):
        self.message_bus.send_message(
            from_agent=self.agent_id,
            to_agent="orchestrator",
            message_type="task_result",
            payload=task.to_dict()
        )
    
    def update_progress(self, progress: str):
        if self.current_task:
            self.shared_memory.add_observation(
                self.current_task.task_id,
                f"[{self.agent_id}] {progress}"
            )
    
    def run_once(self) -> Optional[dict]:
        tasks = self.poll_for_tasks()
        
        if not tasks:
            return None
        
        task_data = tasks[0]
        task = self.receive_task(task_data)
        return self.execute_task(task)
    
    def run_forever(self, poll_interval: float = 5.0):
        print(f"[{self.agent_id}] Agent started, polling for tasks...")
        
        while True:
            try:
                result = self.run_once()
                if result:
                    print(f"[{self.agent_id}] Task completed: {result.get('task_id')}")
                else:
                    print(f"[{self.agent_id}] No tasks, waiting...")
            except Exception as e:
                print(f"[{self.agent_id}] Error: {e}")
            
            time.sleep(poll_interval)
    
    def get_shared_context(self) -> dict:
        graph = self.shared_memory.read_graph()
        return graph
