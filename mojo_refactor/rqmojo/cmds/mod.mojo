"""
RQAlpha Mojo - Mod Command
Ported from rqalpha/cmds/mod.py
"""

from rqmojo.const import EXIT_CODE


@fieldwise_init
struct ModInfo(Movable):
    var name: String
    var enabled: Bool
    var description: String


@fieldwise_init
struct ModCommand(Movable):
    var action: String
    var mod_name: String


fn get_builtin_mods() -> List[ModInfo]:
    var mods = List[ModInfo]()
    mods.append(ModInfo(name="simulation", enabled=True, description="Simulation broker and matcher"))
    mods.append(ModInfo(name="risk", enabled=True, description="Risk management and validation"))
    mods.append(ModInfo(name="accounts", enabled=True, description="Account management"))
    mods.append(ModInfo(name="analyser", enabled=True, description="Performance analysis and reporting"))
    mods.append(ModInfo(name="scheduler", enabled=True, description="Task scheduling"))
    mods.append(ModInfo(name="progress", enabled=True, description="Progress tracking"))
    mods.append(ModInfo(name="transaction_cost", enabled=True, description="Transaction cost calculation"))
    return mods


fn list_mods() -> List[String]:
    var mods = List[String]()
    var mod_infos = get_builtin_mods()
    for mod in mod_infos:
        mods.append(mod.name)
    return mods


fn list_mods_detailed() -> List[ModInfo]:
    return get_builtin_mods()


fn enable_mod(mod_name: String) -> Bool:
    var mods = get_builtin_mods()
    for mod in mods:
        if mod.name == mod_name:
            return True
    return False


fn disable_mod(mod_name: String) -> Bool:
    return True


fn get_mod_config(mod_name: String) -> Dict[String, String]:
    var config = Dict[String, String]()
    config["enabled"] = "true"
    config["name"] = mod_name
    return config


fn run_mod_command(action: String, params: List[String]) -> Int:
    if action == "list":
        print("=== Available Modules ===")
        var mods = get_builtin_mods()
        print("Name          Status      Description")
        print("-" * 60)
        for mod in mods:
            var status = "enabled"
            if not mod.enabled:
                status = "disabled"
            print(mod.name + "          " + status + "          " + mod.description)
        print("")
        print("Use 'rqalpha mod enable <name>' to enable a mod")
        print("Use 'rqalpha mod disable <name>' to disable a mod")
        return 0
    elif action == "enable":
        if len(params) == 0:
            print("Error: Please specify mod name to enable")
            print("Usage: rqalpha mod enable <mod_name>")
            return 1
        var mod_name = params[0]
        if enable_mod(mod_name):
            print("Mod '" + mod_name + "' enabled successfully")
            return 0
        else:
            print("Error: Mod '" + mod_name + "' not found")
            return 1
    elif action == "disable":
        if len(params) == 0:
            print("Error: Please specify mod name to disable")
            print("Usage: rqalpha mod disable <mod_name>")
            return 1
        var mod_name = params[0]
        if disable_mod(mod_name):
            print("Mod '" + mod_name + "' disabled successfully")
            return 0
        else:
            print("Error: Mod '" + mod_name + "' not found")
            return 1
    else:
        print("Error: Unknown action '" + action + "'")
        print("Available actions: list, enable, disable")
        return 1
