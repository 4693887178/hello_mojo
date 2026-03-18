"""
MCP (Model Context Protocol) Implementation
基于Anthropic MCP协议的上下文共享实现
"""

import json
from datetime import datetime
from dataclasses import dataclass, field
from typing import Any, Optional
from pathlib import Path
from enum import Enum


class ContextType(Enum):
    USER_INTENT = "user_intent"
    CONVERSATION = "conversation"
    FILE_CONTENT = "file_content"
    API_STATE = "api_state"
    PERMISSION = "permission"
    DECISION = "decision"


@dataclass
class ContextEntry:
    context_id: str
    context_type: str
    content: Any
    source_agent: str
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    expires_at: Optional[str] = None
    metadata: dict = field(default_factory=dict)
    
    def to_dict(self) -> dict:
        return {
            "context_id": self.context_id,
            "context_type": self.context_type,
            "content": self.content,
            "source_agent": self.source_agent,
            "created_at": self.created_at,
            "expires_at": self.expires_at,
            "metadata": self.metadata
        }


@dataclass
class MCPContext:
    model: str
    context_entries: list[ContextEntry] = field(default_factory=list)
    protocol_version: str = "1.0"
    
    def add_entry(self, entry: ContextEntry):
        self.context_entries.append(entry)
    
    def get_entries_by_type(self, context_type: str) -> list[ContextEntry]:
        return [e for e in self.context_entries if e.context_type == context_type]
    
    def to_dict(self) -> dict:
        return {
            "model": self.model,
            "protocol": self.protocol_version,
            "context": [e.to_dict() for e in self.context_entries]
        }


class ContextStore:
    def __init__(self, store_path: str):
        self.store_path = Path(store_path)
        self.store_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_store()
    
    def _init_store(self):
        if not self.store_path.exists():
            with open(self.store_path, "w") as f:
                json.dump({"contexts": {}}, f)
    
    def store_context(self, session_id: str, context: MCPContext) -> bool:
        with open(self.store_path) as f:
            data = json.load(f)
        
        data["contexts"][session_id] = context.to_dict()
        
        with open(self.store_path, "w") as f:
            json.dump(data, f, indent=2)
        
        return True
    
    def load_context(self, session_id: str) -> Optional[MCPContext]:
        with open(self.store_path) as f:
            data = json.load(f)
        
        context_data = data["contexts"].get(session_id)
        if not context_data:
            return None
        
        context = MCPContext(model=context_data["model"])
        for entry_data in context_data.get("context", []):
            context.add_entry(ContextEntry(
                context_id=entry_data["context_id"],
                context_type=entry_data["context_type"],
                content=entry_data["content"],
                source_agent=entry_data["source_agent"],
                created_at=entry_data["created_at"],
                expires_at=entry_data.get("expires_at"),
                metadata=entry_data.get("metadata", {})
            ))
        
        return context
    
    def update_context(self, session_id: str, entry: ContextEntry) -> bool:
        context = self.load_context(session_id)
        if not context:
            return False
        
        context.add_entry(entry)
        return self.store_context(session_id, context)
    
    def get_shared_context(self, agent_ids: list[str]) -> MCPContext:
        shared_context = MCPContext(model="shared")
        
        with open(self.store_path) as f:
            data = json.load(f)
        
        for session_id, context_data in data["contexts"].items():
            for entry_data in context_data.get("context", []):
                if entry_data["source_agent"] in agent_ids:
                    shared_context.add_entry(ContextEntry(
                        context_id=entry_data["context_id"],
                        context_type=entry_data["context_type"],
                        content=entry_data["content"],
                        source_agent=entry_data["source_agent"],
                        created_at=entry_data["created_at"],
                        metadata=entry_data.get("metadata", {})
                    ))
        
        return shared_context


class ContextPolicyEngine:
    def __init__(self):
        self.policies = {
            "max_age_hours": 24,
            "max_entries_per_type": 100,
            "sensitive_types": ["permission", "api_state"],
            "shareable_types": ["user_intent", "decision", "file_content"]
        }
    
    def should_retain(self, entry: ContextEntry) -> bool:
        if entry.expires_at:
            expires = datetime.fromisoformat(entry.expires_at)
            if datetime.now() > expires:
                return False
        return True
    
    def can_share(self, entry: ContextEntry, target_agent: str) -> bool:
        if entry.context_type in self.policies["sensitive_types"]:
            return entry.metadata.get("share_with", []) and target_agent in entry.metadata.get("share_with", [])
        return entry.context_type in self.policies["shareable_types"]
    
    def summarize(self, entries: list[ContextEntry]) -> str:
        summary_parts = []
        for entry in entries:
            summary_parts.append(f"[{entry.context_type}] from {entry.source_agent}: {str(entry.content)[:100]}")
        return "\n".join(summary_parts)


class MCPProtocol:
    def __init__(self, store_path: str):
        self.context_store = ContextStore(store_path)
        self.policy_engine = ContextPolicyEngine()
        self.current_session: Optional[str] = None
        self.current_model: str = "unknown"
    
    def create_session(self, model: str) -> str:
        import uuid
        session_id = str(uuid.uuid4())
        self.current_session = session_id
        self.current_model = model
        
        context = MCPContext(model=model)
        self.context_store.store_context(session_id, context)
        
        return session_id
    
    def add_context(self, context_type: str, content: Any, 
                    source_agent: str, metadata: dict = None) -> bool:
        if not self.current_session:
            return False
        
        import uuid
        entry = ContextEntry(
            context_id=str(uuid.uuid4()),
            context_type=context_type,
            content=content,
            source_agent=source_agent,
            metadata=metadata or {}
        )
        
        return self.context_store.update_context(self.current_session, entry)
    
    def get_context_for_agent(self, agent_id: str) -> dict:
        if not self.current_session:
            return {}
        
        context = self.context_store.load_context(self.current_session)
        if not context:
            return {}
        
        filtered_entries = [
            e for e in context.context_entries
            if self.policy_engine.can_share(e, agent_id)
        ]
        
        return {
            "session_id": self.current_session,
            "model": context.model,
            "context": [e.to_dict() for e in filtered_entries]
        }
    
    def sync_with_shared_memory(self, shared_memory) -> bool:
        if not self.current_session:
            return False
        
        graph = shared_memory.read_graph()
        
        for entity in graph.get("entities", []):
            self.add_context(
                context_type="decision",
                content={"entity": entity["name"], "observations": entity["observations"]},
                source_agent=entity.get("entityType", "unknown")
            )
        
        return True


if __name__ == "__main__":
    mcp = MCPProtocol("/home/zhou/hello-world/multi_agent_system/shared_memory/mcp_context.json")
    
    session_id = mcp.create_session("claude-3")
    print(f"Created session: {session_id}")
    
    mcp.add_context(
        context_type="user_intent",
        content="重构rqalpha框架到Mojo语言",
        source_agent="orchestrator"
    )
    
    mcp.add_context(
        context_type="decision",
        content={"decision": "使用MCP+A2A协议进行多Agent协作", "rationale": "标准化通信"},
        source_agent="trae-cn"
    )
    
    context_for_codebuddy = mcp.get_context_for_agent("codebuddy-cn")
    print("\nContext for codebuddy-cn:")
    print(json.dumps(context_for_codebuddy, indent=2, ensure_ascii=False))
