"""
共享记忆层实现 - Shared Memory Layer
基于知识图谱的多Agent共享记忆系统
"""

import json
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Any, Optional
from dataclasses import dataclass, field, asdict
from enum import Enum


class EntityType(Enum):
    PROJECT_CONTEXT = "project_context"
    TASK = "task"
    DECISION = "decision"
    PROGRESS = "progress"
    AGENT = "agent"


class TaskStatus(Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"


@dataclass
class Entity:
    name: str
    entity_type: str
    observations: list[str] = field(default_factory=list)
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())


@dataclass
class Relation:
    from_entity: str
    to_entity: str
    relation_type: str
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())


class SharedMemory:
    def __init__(self, db_path: str):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()
    
    def _init_db(self):
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS entities (
                    name TEXT PRIMARY KEY,
                    entity_type TEXT NOT NULL,
                    observations TEXT,
                    created_at TEXT
                )
            """)
            conn.execute("""
                CREATE TABLE IF NOT EXISTS relations (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    from_entity TEXT NOT NULL,
                    to_entity TEXT NOT NULL,
                    relation_type TEXT NOT NULL,
                    created_at TEXT,
                    FOREIGN KEY (from_entity) REFERENCES entities(name),
                    FOREIGN KEY (to_entity) REFERENCES entities(name)
                )
            """)
            conn.commit()
    
    def create_entity(self, entity: Entity) -> bool:
        with sqlite3.connect(self.db_path) as conn:
            try:
                conn.execute(
                    "INSERT OR REPLACE INTO entities VALUES (?, ?, ?, ?)",
                    (entity.name, entity.entity_type, 
                     json.dumps(entity.observations), entity.created_at)
                )
                conn.commit()
                return True
            except Exception as e:
                print(f"Error creating entity: {e}")
                return False
    
    def add_observation(self, entity_name: str, observation: str) -> bool:
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                "SELECT observations FROM entities WHERE name = ?",
                (entity_name,)
            )
            row = cursor.fetchone()
            if row:
                observations = json.loads(row[0])
                observations.append(observation)
                conn.execute(
                    "UPDATE entities SET observations = ? WHERE name = ?",
                    (json.dumps(observations), entity_name)
                )
                conn.commit()
                return True
            return False
    
    def create_relation(self, relation: Relation) -> bool:
        with sqlite3.connect(self.db_path) as conn:
            try:
                conn.execute(
                    "INSERT INTO relations (from_entity, to_entity, relation_type, created_at) VALUES (?, ?, ?, ?)",
                    (relation.from_entity, relation.to_entity, 
                     relation.relation_type, relation.created_at)
                )
                conn.commit()
                return True
            except Exception as e:
                print(f"Error creating relation: {e}")
                return False
    
    def get_entity(self, name: str) -> Optional[Entity]:
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                "SELECT name, entity_type, observations, created_at FROM entities WHERE name = ?",
                (name,)
            )
            row = cursor.fetchone()
            if row:
                return Entity(
                    name=row[0],
                    entity_type=row[1],
                    observations=json.loads(row[2]),
                    created_at=row[3]
                )
            return None
    
    def get_relations(self, entity_name: str) -> list[dict]:
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                "SELECT from_entity, to_entity, relation_type FROM relations WHERE from_entity = ? OR to_entity = ?",
                (entity_name, entity_name)
            )
            return [
                {"from": row[0], "to": row[1], "type": row[2]}
                for row in cursor.fetchall()
            ]
    
    def read_graph(self) -> dict:
        with sqlite3.connect(self.db_path) as conn:
            entities_cursor = conn.execute("SELECT name, entity_type, observations, created_at FROM entities")
            entities = [
                {
                    "name": row[0],
                    "entityType": row[1],
                    "observations": json.loads(row[2])
                }
                for row in entities_cursor.fetchall()
            ]
            
            relations_cursor = conn.execute("SELECT from_entity, to_entity, relation_type FROM relations")
            relations = [
                {"from": row[0], "to": row[1], "relationType": row[2]}
                for row in relations_cursor.fetchall()
            ]
            
            return {"entities": entities, "relations": relations}
    
    def delete_entity(self, name: str) -> bool:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("DELETE FROM relations WHERE from_entity = ? OR to_entity = ?", (name, name))
            conn.execute("DELETE FROM entities WHERE name = ?", (name,))
            conn.commit()
            return True


if __name__ == "__main__":
    memory = SharedMemory("/home/zhou/hello-world/multi_agent_system/shared_memory/memory.db")
    
    memory.create_entity(Entity(
        name="rqmojo-project",
        entity_type="project_context",
        observations=["Python rqalpha框架用Mojo语言重构项目", "使用Mojo 0.26.1版本"]
    ))
    
    memory.create_entity(Entity(
        name="trae-cn",
        entity_type="agent",
        observations=["代码审查专家", "负责Mojo代码重构审查"]
    ))
    
    memory.create_entity(Entity(
        name="codebuddy-cn",
        entity_type="agent",
        observations=["代码编写专家", "负责Python到Mojo的代码转换"]
    ))
    
    memory.create_relation(Relation(
        from_entity="trae-cn",
        to_entity="rqmojo-project",
        relation_type="works_on"
    ))
    
    memory.create_relation(Relation(
        from_entity="codebuddy-cn",
        to_entity="rqmojo-project",
        relation_type="works_on"
    ))
    
    print("Shared memory initialized!")
    print(json.dumps(memory.read_graph(), indent=2, ensure_ascii=False))
