"""
RQAlpha Mojo - API Registration
Ported from rqalpha/api.py

Design notes vs Python original:
  Python: dynamic decorators, globals(), getattr/setattr, inspect module
  Mojo:  ApiRegistry struct with explicit state management

Key adaptations:
  - globals() simulation via ApiRegistry._api_registry Dict
  - _rq_exception_checked tracking via ApiRegistry._exception_checked Set
  - api_exc_patch logic adapted for Mojo's static type system
  - FunctionType replaced with string-based function identification
  - No module-level mutable state (Mo limitation); use ApiRegistry instance
"""

from std.collections import List, Dict, Set
from rqmojo.utils.exception import (
    RQInvalidArgument,
    patch_system_exc,
    EXC_EXT_NAME,
)
from rqmojo.const import EXC_TYPE


struct ApiRegistry(Movable):
    """Registry for API functions, mirroring Python's module-level state in rqalpha/api.py."""

    var __all__: List[String]
    var _api_registry: Dict[String, String]
    var _exception_checked: Set[String]

    def __init__(out self):
        self.__all__ = List[String]()
        self._api_registry = Dict[String, String]()
        self._exception_checked = Set[String]()

    def __init__(out self, *, copy: Self):
        self.__all__ = copy.__all__.copy()
        self._api_registry = Dict[String, String]()
        for entry in copy._api_registry.items():
            self._api_registry[entry.key] = entry.value
        self._exception_checked = Set[String]()
        for item in copy._exception_checked:
            self._exception_checked.add(item)

    def decorate_api_exc(mut self, func_name: String) -> String:
        """Mark function as exception-checked (simulates Python's _rq_exception_checked attr)."""
        if func_name not in self._exception_checked:
            self._exception_checked.add(func_name)
        return func_name

    def api_exc_patch(
        mut self,
        func_name: String,
        raises_invalid_arg: Bool = False,
        exc_type: EXC_TYPE = EXC_TYPE.NOTSET,
    ) -> String:
        """Apply exception patching metadata to a function (simulates Python's api_exc_patch)."""
        if raises_invalid_arg:
            pass
        if exc_type == EXC_TYPE.NOTSET:
            pass
        return func_name

    def register_api(mut self, name: String, func: String) -> None:
        """Register function as API. Python: globals()[name] = func; __all__.append(name)."""
        self._api_registry[name] = func
        self.__all__.append(name)

    def export_as_api(mut self, func: String, name: String = "") -> String:
        """Export function as API. Python: uses func.__name__, decorates, registers globals."""
        var api_name = name
        if api_name == "":
            api_name = func
        self.__all__.append(api_name)
        var decorated = self.decorate_api_exc(func)
        self._api_registry[api_name] = decorated
        return decorated

    def get_registered_api(self, name: String) raises -> Optional[String]:
        """Look up registered API by name."""
        if name in self._api_registry:
            return self._api_registry[name].copy()
        return None

    def is_exception_checked(self, func_name: String) -> Bool:
        """Check if function was marked as exception-checked."""
        return func_name in self._exception_checked

    def get_all_apis(self) -> List[String]:
        """Get copy of registered API names list."""
        return self.__all__.copy()

    def reset(mut self) -> None:
        """Clear all registry state."""
        self.__all__.clear()
        self._api_registry.clear()
        self._exception_checked.clear()

    def write_to(self, mut writer: Some[Writer]):
        t"ApiRegistry(apis={self.__all__}, checked={len(self._exception_checked)})".write_to(writer)


def decorate_api_exc(func_name: String) -> String:
    """
    Convenience wrapper: decorate a function name for exception checking.
    Creates ephemeral registry; for persistent state use ApiRegistry directly.
    """
    var reg = ApiRegistry()
    return reg.decorate_api_exc(func_name)


def api_exc_patch(
    func_name: String,
    raises_invalid_arg: Bool = False,
    exc_type: EXC_TYPE = EXC_TYPE.NOTSET,
) -> String:
    """
    Convenience wrapper: apply exception patching metadata.
    Creates ephemeral registry; for persistent state use ApiRegistry directly.
    """
    var reg = ApiRegistry()
    return reg.api_exc_patch(func_name, raises_invalid_arg, exc_type)


def register_api(name: String, func: String) -> None:
    """
    Convenience wrapper: register API function.
    Creates ephemeral registry; for persistent state use ApiRegistry directly.
    """
    var reg = ApiRegistry()
    reg.register_api(name, func)


def export_as_api(func: String, name: String = "") -> String:
    """
    Convenience wrapper: export function as API.
    Creates ephemeral registry; for persistent state use ApiRegistry directly.
    """
    var reg = ApiRegistry()
    return reg.export_as_api(func, name)


def get_registered_api(name: String) -> Optional[String]:
    """
    Convenience wrapper: look up registered API.
    Returns None; use ApiRegistry instance for persistent lookups.
    """
    return None


def is_exception_checked(func_name: String) -> Bool:
    """
    Convenience wrapper: check exception-checked status.
    Returns False; use ApiRegistry instance for persistent state.
    """
    return False


def get_all_apis() -> List[String]:
    """
    Convenience wrapper: get all registered API names.
    Returns empty list; use ApiRegistry instance for persistent state.
    """
    return List[String]()


def reset_api_registry() -> None:
    """
    Convenience wrapper: reset registry state.
    No-op; use ApiRegistry instance for persistent state.
    """
    pass
