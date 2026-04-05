# -*- coding: utf-8 -*-
"""
RQMojo Test Suite - Group 01
File: cmds/entry.py vs cmds/entry.mojo (Python side)
Tests the ORIGINAL Python entry.py behavior.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


def test_python_entry():
    """Test Python rqalpha/cmds/entry.py cli() behavior."""
    import click
    from rqalpha.cmds.entry import cli

    result = {
        "module": "cmds/entry.py",
        "tests": []
    }

    # Test 1: cli is callable
    t = {"name": "cli is callable", "expected": True, "actual": callable(cli), "passed": callable(cli)}
    result["tests"].append(t)

    # Test 2: cli is a click.Group instance
    t = {"name": "cli is click.Group", "expected": True, "actual": isinstance(cli, click.Group), "passed": isinstance(cli, click.Group)}
    result["tests"].append(t)

    # Test 3: cli.name == 'cli'
    actual_name = cli.name if hasattr(cli, 'name') else str(getattr(cli, '__name__', 'N/A'))
    t = {"name": "cli name", "expected": "cli", "actual": actual_name, "passed": actual_name == "cli"}
    result["tests"].append(t)

    # Test 4: cli has --help option (click auto-adds)
    has_help = any(p.name in ('help', '--help', '-h') for p in cli.params)
    t = {"name": "has help option (-h/--help)", "expected": True, "actual": has_help, "passed": has_help}
    result["tests"].append(t)

    # Test 5: cli.invoke with --help returns 0 exit code
    try:
        from click.testing import CliRunner as ClickRunner
        cr = ClickRunner()
        r = cr.invoke(cli, ['--help'])
        help_ok = r.exit_code == 0 and len(r.output) > 0
        t = {"name": "--help exits cleanly", "expected": True, "actual": help_ok, "passed": help_ok}
        result["tests"].append(t)
        # capture help output for comparison
        result["_help_output"] = r.output
    except Exception as e:
        t = {"name": "--help exits cleanly", "expected": True, "actual": f"ERROR: {e}", "passed": False}
        result["tests"].append(t)
        result["_help_output"] = ""

    # Test 6: no args -> shows help (group behavior, may exit non-zero)
    try:
        cr = ClickRunner()
        r = cr.invoke(cli, [])
        # Click group with invoke_without_context=False exits non-zero when no command given
        # This is expected behavior - it prints help then exits
        t = {"name": "no-args shows output", "expected": True, "actual": len(r.output) > 0, "passed": len(r.output) > 0}
        result["tests"].append(t)
    except Exception as e:
        t = {"name": "no-args shows output", "expected": True, "actual": f"ERROR: {e}", "passed": False}
        result["tests"].append(t)

    return result


def main():
    print("=" * 60)
    print("Test: cmds/entry.py (Python Original)")
    print("=" * 60)

    result = test_python_entry()

    total = len(result["tests"])
    passed = sum(1 for t in result["tests"] if t["passed"])

    for t in result["tests"]:
        status = "PASS" if t["passed"] else "FAIL"
        print(f"  [{status}] {t['name']}")
        if not t["passed"]:
            print(f"         Expected: {t.get('expected')}")
            print(f"         Actual:   {t.get('actual')}")

    print(f"\n{'=' * 60}")
    print(f"Result: {passed}/{total} tests passed")
    print(f"{'=' * 60}")

    if "_help_output" in result:
        print("\n--- Python cli --help output ---")
        print(result["_help_output"][:500])

    return result


if __name__ == "__main__":
    main()
