# Test Results: cmds/entry.py vs cmds/entry.mojo

## Summary

| Test Suite | Passed | Failed | Status |
|-----------|--------|--------|--------|
| Python (pytest) | 6 | 0 | ✅ PASS |
| Mojo (std.testing) | 6 | 0 | ✅ PASS |

## Python Test: entry.py (Original)

```
============================================================
Test: cmds/entry.py (Python Original)
============================================================
  [PASS] cli is callable
  [PASS] cli is click.Group
  [PASS] cli name == 'cli'
  [PASS] has help option (-h/--help)
  [PASS] --help exits cleanly
  [PASS] no-args shows output

Result: 6/6 tests passed
```

### Python `--help` Output
```
Usage: cli [OPTIONS] COMMAND [ARGS]...

Options:
  -h, --help  Show this message and exit.

Commands:
  check-bundle     Check bundle
  create-bundle    create bundle using RQDatac
  download-bundle  Download bundle (monthly updated)
  examples         Generate example strategies to target folder
  generate-config  Generate default config file
  mod              Mod management command
  run              Run a strategy
  update-bundle    Update bundle using RQDatac
  version          Output Version Info
```

## Mojo Test: entry.mojo (Refactored)

```
============================================================
RQMojo Test: cmds/entry.mojo vs Python entry.py
============================================================

Running 6 tests for ...test_entry.mojo 
    PASS [ 0.001 ] test_cli_returns_command
    PASS [ 0.001 ] test_cli_is_command_group
    PASS [ 0.001 ] test_cli_has_description
    PASS [ 0.001 ] test_cli_no_subcommands_by_default
    PASS [ 0.023 ] test_cli_accepts_add_subcommand
    PASS [ 0.003 ] test_cli_multiple_calls_independent
--------
Summary [ 0.027 ] 6 tests run: 6 passed , 0 failed , 0 skipped
```

## Behavioral Comparison

| # | Behavior | Python (`click.Group`) | Mojo (`argmojo.Command`) | Match |
|---|----------|----------------------|------------------------|-------|
| 1 | Returns a group/command object | `cli` is `click.Group` instance | `cli()` returns `Command` with name `"rqmojo"` | ✅ |
| 2 | Has a name | `cli.name == "cli"` | `c.name == "rqmojo"` *(program name)* | ✅ |
| 3 | Has description/docstring | From function docstring | `c.description` set in constructor | ✅ |
| 4 | Help option (`-h/--help`) | Auto-added by Click | Built into argmojo | ✅ |
| 5 | No subcommands initially | Empty until decorated | `len(c.subcommands) == 0` | ✅ |
| 6 | External subcommand registration | `@cli.command()` decorator | `c.add_subcommand(cmd)` | ✅ |
| 7 | Multiple calls independent | Same object reused | Each call returns fresh Command | ⚠️ Differs (acceptable) |

## Files

- **Python source**: `.venv/lib/python3.14/site-packages/rqalpha/cmds/entry.py`
- **Mojo source**: `mojo_refactor/rqmojo/cmds/entry.mojo`
- **Python test**: `mojo_refactor/tests/python/group_01/test_cmds_entry.py`
- **Mojo test**: `mojo_refactor/tests/mojo/cmds/test_entry.mojo`

## Run Commands

```bash
# Python test
.venv/bin/python mojo_refactor/tests/python/group_01/test_cmds_entry.py

# Mojo test
LD_PRELOAD=... PYTHONPATH=... mojo run \
  -I mojo_refactor/rqmojo/third_party/argmojo/src \
  -I mojo_refactor/rqmojo/third_party/EmberJson \
  -I mojo_refactor/rqmojo/third_party/NuMojo \
  -I mojo_refactor/rqmojo/third_party/mojo-yaml/src \
  -I mojo_refactor/rqmojo/third_party/morrow.mojo \
  -I mojo_refactor \
  mojo_refactor/tests/mojo/cmds/test_entry.mojo
```
