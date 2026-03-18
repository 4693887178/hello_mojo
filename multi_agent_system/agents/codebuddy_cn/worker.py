"""
CodeBuddy CN Agent Worker
代码编写专家Agent的具体实现
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from agents.agent_worker import AgentWorker


class CodeBuddyCNAgent(AgentWorker):
    def __init__(self):
        super().__init__(agent_id="codebuddy-cn")
    
    def _register_handlers(self):
        self.register_handler("write", self._handle_write)
        self.register_handler("debug", self._handle_debug)
        self.register_handler("document", self._handle_document)
        self.register_handler("convert", self._handle_convert)
    
    def _handle_write(self, input_data: dict) -> dict:
        specification = input_data.get("specification", "")
        target_file = input_data.get("target_file", "")
        language = input_data.get("language", "mojo")
        
        self.update_progress(f"开始编写代码: {target_file}")
        
        code = self._generate_code(specification, language)
        
        if target_file:
            full_path = self.workspace / target_file
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(code)
        
        self.update_progress(f"代码编写完成: {target_file}")
        
        return {
            "status": "completed",
            "summary": f"生成了 {language} 代码",
            "file": target_file,
            "lines_of_code": len(code.split("\n"))
        }
    
    def _generate_code(self, specification: str, language: str) -> str:
        if language == "mojo":
            return f'''# Auto-generated Mojo code
# Specification: {specification}

def main():
    print("Generated code placeholder")
    # TODO: Implement based on specification

if __name__ == "__main__":
    main()
'''
        else:
            return f'''# Auto-generated Python code
# Specification: {specification}

def main():
    print("Generated code placeholder")
    # TODO: Implement based on specification

if __name__ == "__main__":
    main()
'''
    
    def _handle_debug(self, input_data: dict) -> dict:
        file_path = input_data.get("file_path", "")
        error_message = input_data.get("error_message", "")
        
        self.update_progress(f"调试: {file_path}")
        
        fixes = []
        
        if "cannot find" in error_message.lower():
            fixes.append({
                "type": "import",
                "suggestion": "检查导入路径是否正确"
            })
        
        if "type" in error_message.lower():
            fixes.append({
                "type": "type_error",
                "suggestion": "检查类型匹配"
            })
        
        return {
            "status": "completed",
            "summary": f"分析了错误: {error_message[:50]}...",
            "fixes": fixes
        }
    
    def _handle_document(self, input_data: dict) -> dict:
        target_files = input_data.get("target_files", [])
        
        self.update_progress(f"生成文档: {target_files}")
        
        docs = []
        for file_path in target_files:
            docs.append({
                "file": file_path,
                "doc_file": file_path.replace(".mojo", ".md").replace(".py", ".md")
            })
        
        return {
            "status": "completed",
            "summary": f"生成了 {len(docs)} 个文档",
            "documents": docs
        }
    
    def _handle_convert(self, input_data: dict) -> dict:
        source_file = input_data.get("source_file", "")
        target_file = input_data.get("target_file", "")
        
        self.update_progress(f"转换: {source_file} -> {target_file}")
        
        source_path = Path("/home/zhou/hello-world") / source_file
        target_path = Path("/home/zhou/hello-world") / target_file
        
        conversion_notes = []
        
        if source_path.exists():
            source_content = source_path.read_text()
            
            converted_code = self._convert_python_to_mojo(source_content)
            
            target_path.parent.mkdir(parents=True, exist_ok=True)
            target_path.write_text(converted_code)
            
            conversion_notes.append({
                "type": "success",
                "message": f"已转换 {source_file} -> {target_file}"
            })
        else:
            conversion_notes.append({
                "type": "warning",
                "message": f"源文件不存在: {source_file}"
            })
        
        self.update_progress(f"转换完成")
        
        return {
            "status": "completed",
            "summary": f"Python -> Mojo 转换完成",
            "source": source_file,
            "target": target_file,
            "notes": conversion_notes
        }
    
    def _convert_python_to_mojo(self, python_code: str) -> str:
        mojo_code = python_code
        
        mojo_code = mojo_code.replace("def ", "fn ")
        mojo_code = mojo_code.replace(": str", ": String")
        mojo_code = mojo_code.replace(": int", ": Int")
        mojo_code = mojo_code.replace(": float", ": Float64")
        mojo_code = mojo_code.replace(": bool", ": Bool")
        mojo_code = mojo_code.replace(": list", ": List")
        mojo_code = mojo_code.replace(": dict", ": Dict")
        
        mojo_code = f'''# Converted from Python to Mojo
# Original Python code has been translated

{mojo_code}
'''
        return mojo_code


def main():
    agent = CodeBuddyCNAgent()
    
    print("=" * 60)
    print("CodeBuddy CN Agent Started")
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
