"""
RQAlpha Mojo - Mod System
Ported from rqalpha/mod/__init__.py
"""

from std.collections import Dict, List
from rqmojo.const import EXIT_CODE
from rqmojo.utils.exception import CustomError


@fieldwise_init
struct ModInfo(Movable, Writable):
    var name: String
    var version: String
    var enabled: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ModInfo(", self.name, " v", self.version, ")")


trait Mod:
    def start_up(mut self) -> None: ...
    def tear_down(mut self, code: EXIT_CODE, exception: Optional[CustomError]) -> Dict[String, String]: ...
    def get_name(self) -> String: ...


@fieldwise_init
struct ModHandler(Movable, Writable):
    var _mod_count: Int
    var _env: String
    var _started: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ModHandler(mods=", String(self._mod_count), ")")

    def set_env(mut self, env: String) -> None:
        self._env = env

    def start_up(mut self) -> None:
        self._started = True

    def tear_down(mut self, code: EXIT_CODE, exception: Optional[CustomError] = Optional[CustomError](None)) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        self._started = False
        return result^

    def add_mod(mut self, name: String) -> None:
        self._mod_count += 1

    def get_mod_count(self) -> Int:
        return self._mod_count

    def is_started(self) -> Bool:
        return self._started


def create_mod_handler() -> ModHandler:
    return ModHandler(
        _mod_count=0,
        _env="",
        _started=False
    )
