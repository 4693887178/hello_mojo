# -*- coding: utf-8 -*-
"""
第四组测试 - Python测试运行脚本
运行所有Python测试并生成报告
"""

import subprocess
import sys
import os

TEST_DIR = "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/python/group_04"
RESULTS_DIR = "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/results/group_04"

PYTHON_PATH = "/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages"

test_files = [
    ("test_logger.py", "utils/logger.py"),
    ("test_rq_json.py", "utils/rq_json.py"),
    ("test_strategy_loader_help.py", "utils/strategy_loader_help.py"),
    ("test_testing_init.py", "utils/testing/__init__.py"),
    ("test_arg_checker.py", "utils/arg_checker.py"),
    ("test_class_helper.py", "utils/class_helper.py"),
    ("test_functools.py", "utils/functools.py"),
    ("test_tick.py", "model/tick.py"),
    ("test_progress_init.py", "mod/rqalpha_mod_sys_progress/__init__.py"),
    ("test_progress_mod.py", "mod/rqalpha_mod_sys_progress/mod.py"),
]


def run_single_test(test_file, source_file):
    """运行单个测试文件"""
    env = os.environ.copy()
    env["PYTHONPATH"] = PYTHON_PATH
    
    result = subprocess.run(
        [sys.executable, "-m", "pytest", test_file, "-v"],
        capture_output=True,
        text=True,
        env=env,
        cwd=TEST_DIR
    )
    return result.returncode, result.stdout.decode()


def main():
    print("=" * 70)
    print("第四组 Python 测试报告")
    print("=" * 70)
    print()
    
    results = []
    total_passed = 0
    total_failed = 0
    
    for test_file, source_file in test_files:
        print(f"\n{'=' * 50}")
        print(f"测试文件: {test_file}")
        print(f"对应源文件: {source_file}")
        print("=" * 50)
        
        returncode, output = run_single_test(
            os.path.join(TEST_DIR, test_file),
            source_file
        )
        
        passed = output.count(" passed")
        failed = output.count(" failed")
        errors = output.count(" error")
        
        total_passed += passed
        total_failed += failed
        
        result = {
            "file": test_file,
            "source": source_file,
            "passed": passed,
            "failed": failed,
            "errors": errors,
            "output": output,
        }
        results.append(result)
        
        print(f"\n结果: {passed} passed, {failed} failed, {errors} errors")
    
    print("\n" + "=" * 70)
    print(f"总计: {total_passed} passed, {total_failed} failed")
    print("=" * 70)
    
    with open(os.path.join(RESULTS_DIR, "python_test_summary.md"), "w") as f:
    # 第四组 Python 测试汇总报告

生成时间: {subprocess.check_output(["date", "-I", "+%Y-%m-%d"]).decode().strip()}
    
    ## 测试结果

    | 源文件 | 测试文件 | 通过 | 失败 | 错误 | 状态 |
    |------|----------|------|------|------|------|
    
    for r in results:
        status = "✅" if r["failed"] == 0 and r["errors"] == 0 else "❌"
        f.write(f"| {r['source']} | {r['file']} | {r['passed']} | {r['failed']} | {r['errors']} | {status} |\n")
    
    f.write(f"\n## 统计\n\n")
    f.write(f"- 总测试数: {total_passed + total_failed}\n")
    f.write(f"- 通过: {total_passed}\n")
    f.write(f"- 失败: {total_failed}\n")
    
    f.write("\n## 详细输出\n\n")
    for r in results:
        if r["failed"] > 0 or r["errors"] > 0:
            f.write(f"### {r['file']}\n\n")
            f.write("```\n")
            f.write(r["output"])
            f.write("```\n\n")


if __name__ == "__main__":
    main()
