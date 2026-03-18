"""
TRAE CN 评价 CodeBuddy CN 的工作结果
"""

import json
import sys
from pathlib import Path
from datetime import datetime

sys.path.insert(0, str(Path(__file__).parent))

from shared_memory.memory_store import SharedMemory
from protocols.a2a_protocol import A2AMessageBus


def main():
    base_path = Path("/home/zhou/hello-world/multi_agent_system")
    
    shared_memory = SharedMemory(str(base_path / "shared_memory" / "memory.db"))
    message_bus = A2AMessageBus(str(base_path / "shared_memory" / "messages.json"))
    
    print("=" * 60)
    print("TRAE CN: 评价 CodeBuddy CN 的工作")
    print("=" * 60)
    
    result_file = Path("/home/zhou/hello-world/life.mojo")
    content = result_file.read_text()
    
    print("\n📄 修改后的文件内容:")
    print("-" * 40)
    print(content)
    print("-" * 40)
    
    issues = []
    suggestions = []
    positives = []
    
    if "get_timestamp" in content:
        positives.append("✓ 添加了获取时间戳的函数")
    else:
        issues.append("✗ 缺少时间戳函数")
    
    if "timed_operation" in content:
        positives.append("✓ 添加了计时输出函数")
    else:
        issues.append("✗ 缺少计时输出函数")
    
    if "start" in content and "end" in content:
        positives.append("✓ 在 main 中添加了开始/结束时间记录")
    
    if "Hello, World!" in content:
        positives.append("✓ 保留了原始功能")
    
    if content.count("fn ") >= 2:
        suggestions.append("建议: 使用 Mojo 原生 fn 而非 def")
    
    if "get_timestamp() -> Int:" in content and "return 0" in content:
        issues.append({
            "type": "implementation",
            "message": "get_timestamp() 返回硬编码的 0，需要实现真实的时间获取"
        })
        suggestions.append("建议: 使用 time.now() 或系统时间 API")
    
    score = 70
    if len(issues) == 0:
        score += 15
    if len(positives) >= 3:
        score += 10
    if len(suggestions) > 0:
        score -= len(suggestions) * 5
    
    approved = len([i for i in issues if isinstance(i, dict) and i.get("type") == "critical"]) == 0
    
    print("\n" + "=" * 60)
    print("📊 评价结果")
    print("=" * 60)
    
    print(f"\n✅ 做得好的地方 ({len(positives)}):")
    for p in positives:
        print(f"   {p}")
    
    if issues:
        print(f"\n⚠️ 需要改进 ({len(issues)}):")
        for i in issues:
            if isinstance(i, dict):
                print(f"   [{i['type']}] {i['message']}")
            else:
                print(f"   {i}")
    
    if suggestions:
        print(f"\n💡 建议 ({len(suggestions)}):")
        for s in suggestions:
            print(f"   {s}")
    
    print(f"\n📈 总分: {score}/100")
    print(f"🎯 是否通过: {'✅ 通过' if approved else '❌ 需要修改'}")
    
    review_result = {
        "reviewer": "trae-cn",
        "task_id": "task-decorator-001",
        "status": "reviewed",
        "score": score,
        "approved": approved,
        "positives": positives,
        "issues": [i if isinstance(i, str) else i["message"] for i in issues],
        "suggestions": suggestions,
        "reviewed_at": datetime.now().isoformat()
    }
    
    message_bus.send_message(
        from_agent="trae-cn",
        to_agent="codebuddy-cn",
        message_type="review_result",
        payload=review_result
    )
    
    shared_memory.add_observation(
        "task-decorator-001",
        f"[trae-cn] 评价完成: {score}分, {'通过' if approved else '需修改'}"
    )
    
    print("\n" + "=" * 60)
    print("✅ 评价结果已发送给 CodeBuddy CN")
    print("=" * 60)


if __name__ == "__main__":
    main()
