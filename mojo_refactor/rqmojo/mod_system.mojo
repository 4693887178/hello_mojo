"""
RQAlpha Mojo - Mod System
Ported from rqalpha/mod/__init__.py
"""

from rqmojo.const import EXECUTION_PHASE
from rqmojo.core.events import EVENT, Event


@fieldwise_init
struct ModInfo(Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var version: String
    var enabled: Bool
    
    def __str__(self) -> String:
        return "Mod(" + self.name + ", v" + self.version + ")"


@fieldwise_init
struct ModHandler(Copyable, Movable, ImplicitlyCopyable):
    var mod_count: Int
    var enabled: Bool
    
    def start(self) -> None:
        pass
    
    def stop(self) -> None:
        pass
    
    def add_mod(mut self, mod_name: String) -> None:
        self.mod_count += 1
    
    def get_mod_count(self) -> Int:
        return self.mod_count
    
    def is_enabled(self) -> Bool:
        return self.enabled


def create_mod_handler() -> ModHandler:
    return ModHandler(mod_count=0, enabled=True)
