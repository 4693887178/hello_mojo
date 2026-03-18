"""
RQAlpha Mojo - User Module Base
Ported from rqalpha/user_module.py
"""

from rqmojo.const import EXIT_CODE
from rqmojo.interface import Mod
from rqmojo.environment import Environment


@fieldwise_init
struct UserModule(Movable):
    var name: String
    var enabled: Bool
    
    fn start_up(mut self, env: Environment, config: Dict[String, String]) -> None:
        pass
    
    fn tear_down(mut self, code: EXIT_CODE, exception: Optional[object]) -> None:
        pass


fn create_user_module(name: String = "user_module") -> UserModule:
    return UserModule(name=name, enabled=True)
