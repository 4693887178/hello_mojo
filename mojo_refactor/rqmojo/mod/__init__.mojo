"""
RQAlpha Mojo - Mod System
Ported from rqalpha/mod/__init__.py and rqalpha/mod/utils.py

Python originals:
  rqalpha/mod/__init__.py  -> ModHandler, SYSTEM_MOD_LIST
  rqalpha/mod/utils.py     -> mod_config_value_parse, inject_mod_commands

Key differences from Python:
  - mod_config_value_parse returns ConfigValue (Variant[Bool, Int, Float64, String])
    instead of Python's dynamic typing
  - inject_mod_commands requires Python interop (kept in mod/utils.mojo)
  - ModHandler uses Dict instead of OrderedDict (insertion-ordered in Mojo)
  - AbstractMod.start_up takes env_name + mod_config_name strings
    instead of Python's env object + mod_config RqAttrDict
"""

from std.collections import Dict, List
from std.utils import Variant
from rqmojo.const import EXIT_CODE
from rqmojo.utils.exception import CustomError


comptime ConfigValue = Variant[Bool, Int, Float64, String]


def _get_system_mod_names() -> List[String]:
    var names = List[String]()
    names.append("sys_accounts")
    names.append("sys_analyser")
    names.append("sys_progress")
    names.append("sys_risk")
    names.append("sys_simulation")
    names.append("sys_transaction_cost")
    names.append("sys_scheduler")
    return names^


comptime SYSTEM_MOD_COUNT: Int = 7


@fieldwise_init
struct ModInfo(Movable, Writable, Copyable, ImplicitlyCopyable):
    var name: String
    var version: String
    var enabled: Bool
    var priority: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ModInfo(", self.name, " v", self.version, ", priority=", String(self.priority), ")")


trait AbstractMod:
    def start_up(mut self, env_name: String, mod_config_name: String) -> None: ...
    def tear_down(mut self, code: EXIT_CODE, exception: Optional[CustomError]) -> Dict[String, String]: ...
    def get_name(self) -> String: ...


comptime Mod = AbstractMod


struct ModHandler(Movable, Writable):
    var _env: String
    var _started: Bool
    var _mod_list: List[ModInfo]
    var _mod_dict: Dict[String, String]

    def __init__(out self):
        self._env = ""
        self._started = False
        self._mod_list = List[ModInfo]()
        self._mod_dict = Dict[String, String]()
        for mod_name in _get_system_mod_names():
            self._mod_list.append(ModInfo(
                name=mod_name,
                version="0.1.0",
                enabled=True,
                priority=100,
            ))
            self._mod_dict[mod_name] = "0.1.0"

    def __init__(out self, *, copy: Self):
        self._env = copy._env
        self._started = copy._started
        self._mod_list = copy._mod_list.copy()
        self._mod_dict = Dict[String, String]()
        for entry in copy._mod_dict.items():
            self._mod_dict[entry.key] = entry.value

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ModHandler(mods=", String(len(self._mod_list)), ")")

    def set_env(mut self, env: String) -> None:
        self._env = env

    def start_up(mut self) -> None:
        self._started = True

    def tear_down(mut self, code: EXIT_CODE, exception: Optional[CustomError] = Optional[CustomError](None)) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        var exceptions = List[Error]()
        var idx = len(self._mod_list) - 1
        while idx >= 0:
            _ = self._mod_list[idx]
            idx -= 1
        self._started = False
        if len(exceptions) > 0:
            raise Error("Mod tear down failed with " + String(len(exceptions)) + " exceptions")
        return result^

    def add_mod(mut self, name: String, version: String = "1.0.0", enabled: Bool = True, priority: Int = 100) -> None:
        self._mod_list.append(ModInfo(name=name, version=version, enabled=enabled, priority=priority))
        self._mod_dict[name] = version

    def get_mod_count(self) -> Int:
        return len(self._mod_list)

    def is_started(self) -> Bool:
        return self._started

    def get_mod_list(self) -> List[ModInfo]:
        return self._mod_list.copy()

    def get_enabled_mod_list(self) -> List[ModInfo]:
        var result = List[ModInfo]()
        for mod in self._mod_list:
            if mod.enabled:
                result.append(mod)
        return result^

    def get_mod(self, name: String) -> Optional[ModInfo]:
        for mod in self._mod_list:
            if mod.name == name:
                return mod
        return None

    def register_mod(mut self, mod: ModInfo) -> None:
        self._mod_list.append(mod)
        self._mod_dict[mod.name] = mod.version

    def unregister_mod(mut self, name: String) raises -> Bool:
        var found = False
        var new_list = List[ModInfo]()
        for mod in self._mod_list:
            if mod.name != name:
                new_list.append(mod)
            else:
                found = True
        self._mod_list = new_list^
        if found:
            _ = self._mod_dict.pop(name)
        return found

    def sort_by_priority(mut self) -> None:
        var n = len(self._mod_list)
        for i in range(n):
            for j in range(i + 1, n):
                if self._mod_list[j].priority < self._mod_list[i].priority:
                    var temp = self._mod_list[i]
                    self._mod_list[i] = self._mod_list[j]
                    self._mod_list[j] = temp

    def contains_mod(self, name: String) -> Bool:
        return name in self._mod_dict

    def get_env(self) -> String:
        return self._env


def create_mod_handler() -> ModHandler:
    return ModHandler()


def get_system_mod_list() -> List[ModInfo]:
    var handler = create_mod_handler()
    return handler.get_mod_list()


def get_system_mod(name: String) -> Optional[ModInfo]:
    var handler = create_mod_handler()
    return handler.get_mod(name)


def _is_digit_string(s: String) -> Bool:
    if s.count_codepoints() == 0:
        return False
    for cp in s.codepoints():
        var val = Int(cp)
        if val < 48 or val > 57:
            return False
    return True


def _codepoint_at(s: String, byte_idx: Int) -> Int:
    var cp_slice = s[byte=byte_idx:byte_idx+1]
    for cp in cp_slice.codepoints():
        return Int(cp)
    return -1


def _try_parse_int(s: String) raises -> Int:
    var result: Int = 0
    var sign = 1
    var idx = 0

    if len(s) == 0:
        raise Error("empty string")

    var first_cp = _codepoint_at(s, 0)
    if first_cp == 45:
        sign = -1
        idx = 1
    elif first_cp == 43:
        idx = 1

    if idx >= len(s):
        raise Error("no digits")

    var found_digit = False
    while idx < len(s):
        var cp_val = _codepoint_at(s, idx)
        if cp_val >= 48 and cp_val <= 57:
            result = result * 10 + (cp_val - 48)
            found_digit = True
        else:
            raise Error("invalid character")
        idx += 1

    if not found_digit:
        raise Error("no digits found")

    return result * sign


def _try_parse_float(s: String) raises -> Float64:
    var result: Float64 = 0.0
    var sign = 1.0
    var idx = 0
    var has_dot = False
    var decimal_places = 0

    if len(s) == 0:
        raise Error("empty string")

    var first_cp = _codepoint_at(s, 0)
    if first_cp == 45:
        sign = -1.0
        idx = 1
    elif first_cp == 43:
        idx = 1

    if idx >= len(s):
        raise Error("no digits")

    var found_digit = False
    while idx < len(s):
        var cp_val = _codepoint_at(s, idx)
        if cp_val >= 48 and cp_val <= 57:
            result = result * 10.0 + Float64(cp_val - 48)
            found_digit = True
            if has_dot:
                decimal_places += 1
        elif cp_val == 46 and not has_dot:
            has_dot = True
        else:
            raise Error("invalid character")
        idx += 1

    if not found_digit:
        raise Error("no digits found")

    for _ in range(decimal_places):
        result = result / 10.0

    return result * sign


def mod_config_value_parse(value: String) raises -> ConfigValue:
    if value == "True" or value == "true":
        return ConfigValue(True)

    if value == "False" or value == "false":
        return ConfigValue(False)

    if _is_digit_string(value):
        return ConfigValue(_try_parse_int(value))

    try:
        return ConfigValue(_try_parse_float(value))
    except:
        pass

    return ConfigValue(value)
