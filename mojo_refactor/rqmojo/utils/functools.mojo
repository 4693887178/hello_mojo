"""
RQAlpha Mojo - Function Tools
Ported from rqalpha/utils/functools.py

Faithful port of Python's functools module:
  1. lru_cache: LRU cache struct with generation-based invalidation.
     Python uses @lru_cache(maxsize) decorator; Mojo adapts as a struct
     since Mojo lacks first-class callable decorators.
  2. cached_functions / clear_all_cached_functions: Global cache registry.
     Python maintains a list of cached functions; Mojo uses an environment-
     variable generation counter for O(1) lazy invalidation.
  3. instype_singledispatch: Instrument-type-based single dispatch.
     Python returns a wrapper with .register(); Mojo returns an
     InstypeSingleDispatch struct with equivalent API.
  4. SingleDispatchProtocol / cast_singledispatch: Type markers.
"""

from std.collections import Dict, List
from std.os import getenv, setenv
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.exception import RQInvalidArgument, RQApiNotSupportedError
from rqmojo.utils.i18n import gettext
from rqmojo.environment import Environment


comptime __all__: List[String] = [
    "lru_cache",
    "memoize",
    "cached_functions",
    "clear_all_cached_functions",
    "InstypeSingleDispatch",
    "instype_singledispatch",
    "SingleDispatchProtocol",
    "cast_singledispatch",
]

comptime _GEN_KEY: String = "RQMOJO_CACHE_GEN"
comptime _COUNT_KEY: String = "RQMOJO_CACHE_COUNT"


def _read_gen() raises -> Int:
    var raw = getenv(_GEN_KEY)
    if len(raw) > 0:
        return Int(raw)
    return 0


def _read_count() raises -> Int:
    var raw = getenv(_COUNT_KEY)
    if len(raw) > 0:
        return Int(raw)
    return 0


def _bump_count() raises:
    var c = _read_count() + 1
    _ = setenv(_COUNT_KEY, String(c), True)


def cached_functions() raises -> Int:
    """Return the number of currently registered cached functions.

    Mirrors Python's ``len(cached_functions)``.
    """
    return _read_count()


@fieldwise_init
struct lru_cache(Movable, Copyable):
    """LRU cache with generation-based invalidation.

    Each instance tracks which generation it was created/last-cleared in.
    When clear_all_cached_functions() bumps the global generation,
    all existing instances detect staleness on next access and auto-clear.

    Mirrors Python's ``functools.lru_cache`` behavior:
      - LRU eviction when size exceeds max_size
      - Access promotes to most-recently-used
      - cache_clear() alias for clear()

    Mojo adaptation: String keys/values (sufficient for dispatch use case
    where keys are instrument type names and values are handler identifiers).
    """

    var cache: Dict[String, String]
    var _access_order: List[String]
    var max_size: Int
    var _generation: Int

    def __init__(max_size: Int = 128) raises -> Self:
        return Self(
            Dict[String, String](),
            List[String](),
            max_size,
            _read_gen(),
        )

    def get(mut self, key: String) raises -> Optional[String]:
        self._check_generation()
        if key in self.cache:
            self._touch(key)
            return Optional[String](self.cache[key])
        return Optional[String](None)

    def set(mut self, key: String, value: String) raises:
        self._check_generation()
        is_new = key not in self.cache
        self.cache[key] = value
        if is_new:
            self._access_order.append(key)
            self._evict_if_needed()
        else:
            self._touch(key)

    def contains(mut self, key: String) raises -> Bool:
        self._check_generation()
        return key in self.cache

    def clear(mut self):
        self.cache.clear()
        self._access_order.clear()

    def size(mut self) raises -> Int:
        self._check_generation()
        return len(self.cache)

    def cache_clear(mut self) raises:
        """Alias for clear() matching Python's lru_cache.cache_clear() API."""
        self.clear()

    def get_max_size(self) -> Int:
        return self.max_size

    def _check_generation(mut self) raises:
        if self._generation != _read_gen():
            self.clear()
            self._generation = _read_gen()

    def _touch(mut self, key: String):
        var idx = 0
        var found = False
        for i in range(len(self._access_order)):
            if self._access_order[i] == key:
                idx = i
                found = True
                break
        if found:
            _ = self._access_order.pop(idx)
        self._access_order.append(key)

    def _evict_if_needed(mut self) raises:
        if self.max_size <= 0:
            return
        while len(self.cache) > self.max_size:
            if len(self._access_order) > 0:
                oldest = self._access_order.pop(0)
                _ = self.cache.pop(oldest)


def memoize(max_size: Int = 128) raises -> lru_cache:
    """Create an LRU cache and register it globally.

    Mirrors Python's @lru_cache decorator wrapper:
      1. Creates an lru_cache instance
      2. Increments the global cached_functions counter
      3. Returns the cache for use by caller

    The returned cache will be auto-invalidated when clear_all_cached_functions()
    is called (via generation counter mechanism).
    """
    _bump_count()
    return lru_cache(max_size)


def clear_all_cached_functions() raises:
    """Clear all cached function results.

    This is called before running a new strategy to ensure fresh data.

    Mirrors Python behavior::

        for func in cached_functions:
            func.cache_clear()

    Pure Mojo implementation: bumps the global generation counter stored in
    process environment variable. Every lru_cache instance checks this counter
    on each access and auto-clears if stale. Also resets the registration count
    so cached_functions() returns 0 after clear.
    """
    var gen = _read_gen() + 1
    _ = setenv(_GEN_KEY, String(gen), True)
    _ = setenv(_COUNT_KEY, "0", True)


struct SingleDispatchProtocol:
    """Type marker mirroring Python's SingleDispatchProtocol.

    Python uses typing.Protocol for structural subtyping. Mojo has no
    protocol/trait-of-traits, so this is a marker struct used for
    type documentation only.
    """
    pass


def cast_singledispatch(func: InstypeSingleDispatch) -> InstypeSingleDispatch:
    """Type cast helper making static analysis aware of .register() method.

    Mirrors Python::

        def cast_singledispatch(func: Callable) -> SingleDispatchProtocol:
            return cast(SingleDispatchProtocol, func)  # make IDE happy

    At runtime this is effectively an identity operation (copy).
    """
    return func.copy()


@fieldwise_init
struct InstypeSingleDispatch(Movable, Copyable):
    """Instrument-type-based single dispatch.

    Mirrors Python's instype_singledispatch(func) which:
      1. Accepts Instrument object OR order_book_id string
      2. Resolves INSTRUMENT_TYPE from the input
      3. Dispatches to the registered handler via internal lru_cache(1024)
      4. Raises RQInvalidArgument for unknown types (with i18n message)
      5. Raises RQApiNotSupportedError when registry is empty

    Python usage::

        @instype_singledispatch
        def get_bar(order_book_id):
            ...

        get_bar.register(CS)(cs_impl)
        get_bar.register(FUTURE)(future_impl)

    Mojo adaptation::

        var sd = instype_singledispatch("get_bar", "order_book_id")
        sd.register_single(INSTRUMENT_TYPE.CS, "cs_impl")
        sd.register_single(INSTRUMENT_TYPE.FUTURE, "future_impl")
        var handler = sd.dispatch("CS")  # or sd.dispatch_by_instrument(ins)
    """

    var func_name: String
    var arg_name: String
    var registry: Dict[INSTRUMENT_TYPE, String]
    var _dispatch_cache: lru_cache

    def __init__(func_name: String, arg_name: String) raises -> Self:
        return Self(
            func_name,
            arg_name,
            Dict[INSTRUMENT_TYPE, String](),
            lru_cache(1024),
        )

    def register(mut self, instypes: List[INSTRUMENT_TYPE], handler_name: String):
        """Register a handler for multiple instrument types."""
        for it in instypes:
            self.registry[it] = handler_name

    def register_single(mut self, instype: INSTRUMENT_TYPE, handler_name: String):
        """Register a handler for a single instrument type."""
        self.registry[instype] = handler_name

    def dispatch_by_instrument(mut self, ins: Instrument) raises -> String:
        """Dispatch by extracting type directly from an Instrument object."""
        var instype = ins.type_val
        return self._resolve_dispatch(instype)

    def dispatch_by_id(mut self, order_book_id: String, env: Environment) raises -> String:
        """Dispatch by looking up order_book_id through Environment."""
        var ins = env.get_instrument(order_book_id)
        var instype = ins.type_val
        return self._resolve_dispatch(instype)

    def dispatch(mut self, instype_name: String) raises -> String:
        """Dispatch by instrument type name string."""
        var opt_it = INSTRUMENT_TYPE.__getitem__(instype_name)
        if opt_it:
            return self._resolve_dispatch(opt_it.value())
        if len(self.registry) == 0:
            raise RQApiNotSupportedError.create(
                gettext("function {} is not supported, please check your account or mod config").format(
                    self.func_name,
                )
            )
        raise RQInvalidArgument.create(
            gettext(
                "function {}: invalid {} argument, "
                "expected an order_book_id or instrument with types {}, got {}"
            ).format(
                self.func_name,
                self.arg_name,
                self._format_registry(),
                instype_name,
            )
        )

    def has_handler(self, instype: INSTRUMENT_TYPE) -> Bool:
        """Check if a handler is registered for the given instrument type."""
        return instype in self.registry

    def registered_types(self) -> List[String]:
        """Return names of all registered instrument types."""
        var result = List[String]()
        for key in self.registry:
            result.append(key.name)
        return result^

    def clear_dispatch_cache(mut self) raises:
        """Clear internal dispatch cache (equivalent to clearing the @lru_cache(1024))."""
        self._dispatch_cache.clear()

    def _resolve_dispatch(mut self, instype: INSTRUMENT_TYPE) raises -> String:
        """Resolve handler for instrument type, using cache when possible."""
        var cache_key = instype.name
        var cached = self._dispatch_cache.get(cache_key)
        if cached:
            return cached.value()

        if len(self.registry) == 0:
            raise RQApiNotSupportedError.create(
                gettext("function {} is not supported, please check your account or mod config").format(
                    self.func_name,
                )
            )

        if instype not in self.registry:
            raise RQInvalidArgument.create(
                gettext(
                    "function {}: invalid {} argument, "
                    "expected an order_book_id or instrument with types {}, got {}"
                ).format(
                    self.func_name,
                    self.arg_name,
                    self._format_registry(),
                    instype.name,
                )
            )

        var handler = self.registry[instype]
        self._dispatch_cache.set(cache_key, handler)
        return handler

    def _format_registry(self) -> String:
        """Format registry contents for error messages."""
        var parts = List[String]()
        for key in self.registry:
            parts.append(key.name)
        return ", ".join(parts)


def instype_singledispatch(func_name: String, arg_name: String) raises -> InstypeSingleDispatch:
    """Create an instrument-type single dispatcher.

    Mirrors Python's ``@instype_singledispatch`` decorator.

    Python extracts func.__name__ and first parameter name via inspect.signature;
    Mojo requires explicit arguments since it lacks reflection APIs.
    """
    return InstypeSingleDispatch(func_name, arg_name)
