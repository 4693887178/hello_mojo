"""
RQAlpha Mojo - Mod Command
Ported from rqalpha/cmds/mod.py

CLI commands:
  - list:    List all mod configuration with status (enabled/disabled)
  - enable:  Enable one or more mods by name
  - disable: Disable one or more mods by name

Core logic (matching Python original):
  - list:            Reads mod config, prints table of name + status
  - change_mod_status: Iterates mod names, strips "rqalpha_mod_" prefix,
                       checks module install via Python import_module,
                       updates user mod_config.yml
  - enable/disable:   Wrappers calling change_mod_status(True/False)

Uses argmojo for CLI (replacing click).
Uses std.python interop for import_module checks.
"""

from std.collections import Dict, List
from std.python import Python, PythonObject

from argmojo import Command, Argument, ParseResult
from rqmojo.const import EXIT_CODE
from rqmojo.utils.i18n import gettext
from rqmojo.mod import ModHandler, ModInfo, create_mod_handler


comptime RQALPHA_PATH = "~/.rqalpha"


@fieldwise_init
struct ModStatusEntry(Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var enabled: Bool
    var description: String


def _strip_mod_prefix(mod_name: String) -> String:
    """Strip 'rqalpha_mod_' prefix if present."""
    var prefix = "rqalpha_mod_"
    var idx = mod_name.find(prefix)
    if idx != -1:
        return mod_name[byte=0:idx] + mod_name[byte=idx + len(prefix):]
    return mod_name


def _resolve_module_name(mod_name: String) -> String:
    """Resolve full module name from short mod name."""
    var base_name = "rqalpha_mod_" + mod_name
    var sys_prefix = "rqalpha_mod_sys_"
    var idx = base_name.find(sys_prefix)
    if idx != -1:
        return "rqalpha.mod." + base_name
    return base_name


def _check_module_installed(module_name: String) raises -> Bool:
    """Check whether a mod module is installed via Python import_module."""
    try:
        _ = Python.import_module(module_name)
        return True
    except e:
        return False


def _get_user_mod_conf_path() raises -> String:
    """Get user mod config file path (~/.rqalpha/mod_config.yml)."""
    var py_os = Python.import_module("os")
    var expanded = String(py=py_os.path.expanduser(RQALPHA_PATH))
    return expanded + "/mod_config.yml"


def get_builtin_mods() -> List[ModStatusEntry]:
    """Get list of builtin system mods with their default status.

    Mirrors the mod_config.yml structure from Python.
    """
    var mods = List[ModStatusEntry]()
    mods.append(ModStatusEntry(name="sys_accounts", enabled=True, description="Account and Position Model"))
    mods.append(ModStatusEntry(name="sys_simulation", enabled=True, description="Simulation broker and matcher"))
    mods.append(ModStatusEntry(name="sys_progress", enabled=True, description="Progress tracking"))
    mods.append(ModStatusEntry(name="sys_risk", enabled=True, description="Risk management and validation"))
    mods.append(ModStatusEntry(name="sys_analyser", enabled=True, description="Performance analysis and reporting"))
    mods.append(ModStatusEntry(name="sys_scheduler", enabled=True, description="Task scheduling"))
    mods.append(ModStatusEntry(name="sys_transaction_cost", enabled=True, description="Transaction cost calculation"))
    return mods^


def get_mod_config_dict() -> Dict[String, Dict[String, String]]:
    """Get the full mod configuration as a nested dict matching mod_config.yml."""
    var result = Dict[String, Dict[String, String]]()
    var mod_entries = Dict[String, String]()
    var mods = get_builtin_mods()
    for mod in mods:
        var enabled_str = "true" if mod.enabled else "false"
        mod_entries[mod.name] = enabled_str
    result["mod"] = mod_entries^
    return result^


def list_mods() -> List[String]:
    """List all mod names (simple names only)."""
    var mods = List[String]()
    var mod_infos = get_builtin_mods()
    for mod in mod_infos:
        mods.append(mod.name)
    return mods^


def list_mods_detailed() -> List[ModStatusEntry]:
    """List all mods with detailed info (name, enabled, description)."""
    return get_builtin_mods()


def change_mod_status(mod_list: List[String], enabled: Bool) raises -> List[String]:
    """Change mod enable/disable status for a list of mod names.

    Ported from Python's change_mod_status(mod_list, enabled).
    """
    var handler = create_mod_handler()
    var processed = List[String]()
    for mod_name in mod_list:
        var clean_name = _strip_mod_prefix(mod_name)
        var module_name = _resolve_module_name(clean_name)

        if not _check_module_installed(module_name):
            print(gettext("can not find mod [{}], ignored").format(clean_name))
            continue

        var handler_mod = handler.get_mod(clean_name)
        if handler_mod != None:
            var mut_mod = handler_mod.or_else(ModInfo(name="", version="", enabled=False, priority=100))
            mut_mod.enabled = enabled

        processed.append(clean_name)
    return processed^


def enable_mod(mod_name: String) raises -> Bool:
    """Enable a single mod by name.

    Ported from Python's enable(params).
    """
    var mod_list = List[String]()
    mod_list.append(mod_name)
    var result = change_mod_status(mod_list, True)
    return len(result) > 0


def disable_mod(mod_name: String) raises -> Bool:
    """Disable a single mod by name.

    Ported from Python's disable(params).
    """
    var mod_list = List[String]()
    mod_list.append(mod_name)
    var result = change_mod_status(mod_list, False)
    return len(result) > 0


def get_mod_config(mod_name: String) -> Dict[String, String]:
    """Get config for a specific mod."""
    var config = Dict[String, String]()
    var mods = get_builtin_mods()
    for mod in mods:
        if mod.name == mod_name:
            config["enabled"] = "true" if mod.enabled else "false"
            config["name"] = mod_name
            return config^
    config["enabled"] = "false"
    config["name"] = mod_name
    return config^


def run_mod_command(action: String, params: List[String]) raises -> Int:
    """Execute a mod subcommand (list/enable/disable).

    Ported from Python's mod(cmd, params).
    """
    if action == "list":
        return run_list_mods()
    elif action == "enable":
        return run_enable_mod(params)
    elif action == "disable":
        return run_disable_mod(params)
    else:
        print(gettext("Error: Unknown action '{}'").format(action))
        print(gettext("Available actions: list, enable, disable"))
        return 1


def run_list_mods() raises -> Int:
    """Run the 'list' subcommand.

    Ported from Python's list(params).
    """
    print(gettext("=== Available Modules ==="))
    var mods = get_builtin_mods()

    var name_header = gettext("Name")
    var status_header = gettext("Status")
    var desc_header = gettext("Description")

    var name_len = max(len(name_header), 16)
    var status_len = max(len(status_header), 10)
    var desc_len = max(len(desc_header), 35)

    var header_line = name_header
    for _ in range(name_len - len(name_header)): header_line += " "
    header_line += " | "
    for _ in range(status_len - len(status_header)): header_line += " "
    header_line += status_header
    header_line += " | "
    header_line += desc_header

    var separator = ""
    for _ in range(name_len): separator += "-"
    separator += "-+-"
    for _ in range(status_len): separator += "-"
    separator += "-+-"
    for _ in range(desc_len): separator += "-"

    print(header_line)
    print(separator)

    for mod in mods:
        var status_str = "enabled" if mod.enabled else "disabled"
        var line = mod.name
        for _ in range(name_len - len(mod.name)): line += " "
        line += " | "
        for _ in range(status_len - len(status_str)): line += " "
        line += status_str
        line += " | "
        line += mod.description
        print(line)

    print("")
    print(gettext("You can use `rqalpha mod list/enable/disable` to manage your mods"))
    return 0


def run_enable_mod(params: List[String]) raises -> Int:
    """Run the 'enable' subcommand.

    Ported from Python's enable(params).
    """
    if len(params) == 0:
        print(gettext("Error: Please specify mod name to enable"))
        print(gettext("Usage: rqalpha mod enable <mod_name>"))
        return 1

    var processed = change_mod_status(params, True)
    if len(processed) == len(params):
        for name in processed:
            print(gettext("Mod '{}' enabled successfully").format(name))
        return 0
    else:
        for name in processed:
            print(gettext("Mod '{}' enabled successfully").format(name))
        return 1


def run_disable_mod(params: List[String]) raises -> Int:
    """Run the 'disable' subcommand.

    Ported from Python's disable(params).
    """
    if len(params) == 0:
        print(gettext("Error: Please specify mod name to disable"))
        print(gettext("Usage: rqalpha mod disable <mod_name>"))
        return 1

    var processed = change_mod_status(params, False)
    if len(processed) == len(params):
        for name in processed:
            print(gettext("Mod '{}' disabled successfully").format(name))
        return 0
    else:
        for name in processed:
            print(gettext("Mod '{}' disabled successfully").format(name))
        return 1


def detect_package_name_from_dir(dir_path: String) raises -> String:
    """Detect package name from directory containing setup.py.

    Ported from Python's _detect_package_name_from_dir(params).
    """
    var py_os = Python.import_module("os")
    var abs_path = String(py=py_os.path.abspath(dir_path))
    var setup_path = String(py=py_os.path.join(abs_path, "setup.py"))

    var py_os_path = Python.import_module("os.path")
    if not Bool(py=py_os_path.exists(setup_path)):
        return ""

    var dir_name = String(py=py_os.path.split(abs_path)[0])
    var package_name = String(py=py_os.path.split(dir_name)[1])
    return package_name


# ── argmojo CLI Commands (replacing @click decorators) ──────────────────


def create_mod_command() raises -> Command:
    """Create the 'mod' subcommand using argmojo.

    Replaces: @cli.command(context_settings=dict(ignore_unknown_options=True),
                            help=_("Mod management command"))
              @click.argument('cmd', nargs=1, type=click.Choice(['list', 'enable', 'disable']))
              @click.argument('params', nargs=-1)
    """
    var cmd = Command("mod", gettext("Mod management command"))
    cmd.add_argument(
        Argument("cmd", help="Subcommand: list, enable, or disable")
            .positional()
            .required()
            .choice["list"]()
            .choice["enable"]()
            .choice["disable"]()
    )
    cmd.add_argument(
        Argument("params", help="Mod names for enable/disable")
            .positional()
            .remainder()
    )
    return cmd^


def register_mod_commands(mut cli: Command) raises -> None:
    """Register the mod subcommand onto the main CLI group."""
    cli.add_subcommand(create_mod_command())


def dispatch_mod_command(result: ParseResult) raises -> Int:
    """Dispatch to the correct core function based on parsed subcommand result."""
    var sub_result = result.get_subcommand_result()
    var action = sub_result.get_string("cmd")

    var params_raw = sub_result.get_list("params")
    var params = List[String]()

    for i in range(len(params_raw)):
        params.append(params_raw[i])

    return run_mod_command(action, params)
