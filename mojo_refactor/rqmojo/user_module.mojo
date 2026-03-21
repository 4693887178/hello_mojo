"""
RQAlpha Mojo - User Module Base
Ported from rqalpha/user_module.py
"""

from std.collections import Dict
from rqmojo.const import EXIT_CODE
from rqmojo.environment import Environment


@fieldwise_init
struct UserModule(Movable):
    var name: String
    var enabled: Bool
    
    def start_up(mut self, env: Environment, config: Dict[String, String]) -> None:
        pass
    
    def tear_down(mut self, code: EXIT_CODE, exception: Optional[String]) -> None:
        pass


def create_user_module(name: String = "user_module") -> UserModule:
    return UserModule(name=name, enabled=True)
