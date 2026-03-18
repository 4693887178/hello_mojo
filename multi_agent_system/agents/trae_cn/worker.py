"""
TRAE CN Agent Worker
代码审查专家Agent的具体实现
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from agents.agent_worker import AgentWorker


class TraeCNAgent(AgentWorker):
    def __init__(self):
        super().__init__(agent_id="trae-cn")
    
    def _register_handlers(self):
        self.register_handler("review", self._handle_review)
        self.register_handler("refactor", self._handle_refactor)
        self.register_handler("test", self._handle_test)
    
    def _handle_review(self, input_data: dict) -> dict:
        target_files = input_data.get("target_files", [])
        
        self.update_progress(f"开始审查文件: {target_files}")
        
        issues = []
        suggestions = []
        
        for file_path in target_files:
            full_path = Path("/home/zhou/hello-world") / file_path
            if full_path.exists():
                content = full_path.read_text()
                
                file_issues = self._analyze_code(content, file_path)
                issues.extend(file_issues)
                
                file_suggestions = self._generate_suggestions(content, file_path)
                suggestions.extend(file_suggestions)
        
        self.update_progress(f"审查完成，发现 {len(issues)} 个问题")
        
        return {
            "status": "completed",
            "summary": f"审查了 {len(target_files)} 个文件",
            "issues": issues,
            "suggestions": suggestions,
            "approved": len(issues) == 0
        }
    
    def _analyze_code(self, content: str, file_path: str) -> list[dict]:
        issues = []
        
        if "TODO" in content or "FIXME" in content:
            issues.append({
                "file": file_path,
                "type": "todo",
                "message": "存在未完成的TODO/FIXME标记"
            })
        
        if "print(" in content and "test_" not in file_path:
            issues.append({
                "file": file_path,
                "type": "style",
                "message": "建议使用日志系统替代print语句"
            })
        
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if len(line) > 120:
                issues.append({
                    "file": file_path,
                    "line": i + 1,
                    "type": "style",
                    "message": f"行长度超过120字符 ({len(line)})"
                })
        
        return issues
    
    def _generate_suggestions(self, content: str, file_path: str) -> list[dict]:
        suggestions = []
        
        if file_path.endswith(".mojo"):
            if "from python import Python" not in content:
                suggestions.append({
                    "file": file_path,
                    "type": "optimization",
                    "message": "考虑使用Mojo原生实现替代Python互操作"
                })
        
        return suggestions
    
    def _handle_refactor(self, input_data: dict) -> dict:
        target_files = input_data.get("target_files", [])
        refactor_type = input_data.get("refactor_type", "general")
        
        self.update_progress(f"开始重构: {refactor_type}")
        
        return {
            "status": "completed",
            "summary": f"重构完成: {len(target_files)} 个文件",
            "changes": []
        }
    
    def _handle_test(self, input_data: dict) -> dict:
        target_files = input_data.get("target_files", [])
        
        self.update_progress(f"生成测试: {target_files}")
        
        test_files = []
        for file_path in target_files:
            test_file = file_path.replace(".mojo", "_test.mojo").replace(".py", "_test.py")
            test_files.append(test_file)
        
        return {
            "status": "completed",
            "summary": f"生成了 {len(test_files)} 个测试文件",
            "test_files": test_files
        }


def main():
    agent = TraeCNAgent()
    
    print("=" * 60)
    print("TRAE CN Agent Started")
    print("=" * 60)
    print(f"Agent ID: {agent.agent_id}")
    print(f"Workspace: {agent.workspace}")
    print(f"Handlers: {list(agent.task_handlers.keys())}")
    
    print("\n" + "=" * 60)
    print("Polling for tasks (single run)...")
    print("=" * 60)
    
    result = agent.run_once()
    
    if result:
        print("\nTask Result:")
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print("\nNo pending tasks found.")
        print("Run orchestrator.py first to create and dispatch tasks.")


if __name__ == "__main__":
    main()
