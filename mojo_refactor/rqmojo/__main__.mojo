"""
RQAlpha Mojo - Entry Point
Ported from rqalpha/__main__.py

Python original:
    from rqalpha.cmds import cli
    def entry_point():
        from rqalpha.mod.utils import inject_mod_commands
        inject_mod_commands()
        cli(obj={})
    if __name__ == '__main__':
        entry_point()

Mojo equivalent follows the same two-phase pattern:
  Phase 1: inject_mod_commands() registers all subcommands
  Phase 2: parse sys.argv and dispatch to handlers
"""

from std.sys import exit
from rqmojo.cmds.entry import cli, inject_mod_commands, run_cli


def entry_point() raises -> Int:
    """Main entry point mirroring Python's entry_point().

    Python original does two things in order:
      1. inject_mod_commands() — register all mod subcommands onto cli
      2. cli(obj={})          — run Click's CLI dispatcher

    Mojo equivalent:
      1. inject_mod_commands() — create fully-wired Command with subcommands
      2. run_cli()             — parse sys.argv and dispatch

    Returns:
        Exit code (0 = success, non-zero = error).
    """
    _ = inject_mod_commands()
    return run_cli()


def main() raises:
    """Program entry point called by mojo runtime.

    Mirrors Python's ``if __name__ == '__main__': entry_point()``.
    Handles errors gracefully and exits with proper status code.
    """
    var exit_code = _safe_entry_point()
    exit(exit_code)


def _safe_entry_point() -> Int:
    """Wrap entry_point() with error handling, returning exit code."""
    try:
        return entry_point()
    except e:
        print("Error: ", String(e))
        return 1
