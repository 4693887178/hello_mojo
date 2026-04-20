"""
RQAlpha Mojo - Class Helper
Ported from rqalpha/utils/class_helper.py

Faithful port of Python's class_helper module:
  1. deprecated_property(): Returns DeprecatedProperty struct that carries
     deprecation metadata. Call .get_value(instance) to emit warning and
     redirect to the new attribute (mirrors Python's property descriptor).
  2. CachedProperty: Descriptor-style lazy caching using PythonObject for
     arbitrary-type support (matches Python's Generic[T]).
  3. cached_property: Factory function alias for CachedProperty (identical to
     Python's ``cached_property = CachedProperty``).
"""

from std.collections import List, Dict
from std.python import Python, PythonObject
from rqmojo.utils.logger import user_system_log
from rqmojo.utils.i18n import gettext


comptime __all__: List[String] = [
    "deprecated_property",
    "cached_property",
    "CachedProperty",
]


@fieldwise_init
struct DeprecatedProperty(Copyable, Movable):
    """Mirrors Python deprecated_property()'s return (a property descriptor).

    Python uses __get__ protocol: accessing the attribute triggers warn +
    getattr(self, new_name). Mojo lacks descriptors, so this struct provides
    get_value(instance) which performs the same logic on explicit call.
    """

    var _old_name: String
    var _new_name: String

    def old_name(self) -> String:
        return self._old_name

    def new_name(self) -> String:
        return self._new_name

    def get_value(self, instance: PythonObject) raises -> PythonObject:
        """Emit deprecation warning and return getattr(instance, new_name).

        Mirrors Python's getter(self): warn() + return getattr(self, new_name).
        Call this from your property getter to replicate descriptor behavior.
        """
        var msg = (
            gettext("\"")
            + self._old_name
            + gettext("\" is deprecated, please use \"")
            + self._new_name
            + gettext("\" instead, check the document for more information")
        )
        user_system_log().warn(msg)
        return instance.__getattr__(self._new_name)


def deprecated_property(
    property_name: String, instead_property_name: String
) raises -> DeprecatedProperty:
    """Create a deprecation redirector (mirrors Python's deprecated_property).

    Python returns property(getter) which auto-intercepts attribute access.
    Mojo returns DeprecatedProperty; call its .get_value(instance) method
    to emit the warning and retrieve the redirected value.

    Raises Error if both names are identical (mirrors Python's assert).
    """
    if property_name == instead_property_name:
        raise Error(
            gettext("property_name and instead_property_name must be different")
        )
    return DeprecatedProperty(property_name, instead_property_name)


def cached_property(getter: PythonObject) raises -> CachedProperty:
    """Factory / alias for CachedProperty constructor.

    Mirrors Python's ``cached_property = CachedProperty`` assignment.
    Usage:  cp = cached_property(fn)
    """
    return CachedProperty(getter)


@fieldwise_init
struct CachedProperty(Movable):
    """Mojo equivalent of Python's CachedProperty[T] descriptor.

    Python's CachedProperty:
      - Accepts a getter callable in __init__
      - __get__ computes lazily on first access, caches on instance
      - Returns self when accessed on class (instance=None)
      - Supports any return type via Generic[T]
      - Each instance has independent cache (setattr on instance)

    Mojo adaptation:
      - Stores getter as PythonObject (callable)
      - Uses per-instance cache via Dict[id(instance), value]
      - get_value(instance) mirrors __get__(instance, owner)
      - name() returns getter.__name__
      - is_cached(instance) checks cache state for a specific instance
    """

    var _getter: PythonObject
    var _name: String
    var _cache: Dict[Int, PythonObject]
    var _py_id: PythonObject

    def __init__(out self, getter: PythonObject) raises:
        self._getter = getter
        self._name = String(py=getter.__name__)
        self._cache = Dict[Int, PythonObject]()
        self._py_id = Python.evaluate("id")

    def name(self) -> String:
        """Return the getter function's __name__ (mirrors Python self._name)."""
        return self._name

    def is_cached(self, instance: PythonObject) raises -> Bool:
        """Whether the value has been computed and cached for this instance."""
        var key = Int(py=self._py_id(instance))
        return key in self._cache

    def is_cached(self) -> Bool:
        """Whether any value has been cached (convenience overload)."""
        return len(self._cache) > 0

    def get_value(mut self, instance: PythonObject) raises -> PythonObject:
        """Get cached value, computing it lazily on first call.

        Mirrors Python's __get__(self, instance, owner):
          - Per-instance cache (matches Python's setattr-on-instance behavior)
          - First call for an instance: compute, cache, return
          - Subsequent calls: return cached value
        """
        var key = Int(py=self._py_id(instance))
        if key in self._cache:
            return self._cache[key]
        var value = self._getter(instance)
        self._cache[key] = value
        return value

    def reset(mut self):
        """Clear all cached values, forcing recomputation."""
        self._cache.clear()

    def reset_instance(mut self, instance: PythonObject) raises:
        """Clear cache for a specific instance only."""
        var key = Int(py=self._py_id(instance))
        if key in self._cache:
            _ = self._cache.pop(key)
