# Coding Conventions

**Analysis Date:** 2026-03-26

## Naming Patterns

**Files:**
- Snake_case: `data_proxy.mojo`, `strategy_loader.mojo`
- Test files: `test_<name>.mojo`
- Init files: `__init__.mojo`
- Main files: `__main__.mojo`

**Structs:**
- PascalCase: `Environment`, `DataProxy`, `BaseStrategy`
- Private field prefix: `_` (e.g., `_start_date`, `_event_bus`)

**Functions:**
- snake_case: `create_environment()`, `parse_config()`
- Factory functions: `create_*` prefix
- Static methods: PascalCase for factory methods on structs

**Variables:**
- snake_case: `order_book_id`, `start_date`
- Short names acceptable in small scopes: `dt`, `env`, `cfg`

**Traits:**
- PascalCase: `Strategy`, `Persistable`
- Often named as nouns or adjectives

**Enums:**
- PascalCase for enum type: `RUN_TYPE`, `EVENT`, `EXC_TYPE`
- UPPER_CASE for values: `RUN_TYPE.BACKTEST`, `EVENT.BAR`

## Code Style

**Formatting:**
- No external formatter (follow Mojo standard style)
- 4-space indentation
- Max line length: ~100 characters

**Decorators:**
- `@fieldwise_init` - Auto-generate `__init__` from fields
- `@value` - Generate __init__, __copyinit__, __moveinit__
- Used extensively for struct definitions

**Traits:**
- Use traits for interfaces: `Strategy`, `Persistable`
- Standard traits: `Stringable`, `Copyable`, `Movable`, `Equatable`, `Writable`

## Import Organization

**Order:**
1. Standard library imports
2. Third-party package imports
3. Local project imports

**Pattern:**
```mojo
from std.collections import Dict, List, Set, Optional
from std.python import Python, PythonObject

from rqmojo.const import RUN_TYPE, EXECUTION_PHASE
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.model.order import Order
```

**Path Aliases:**
- No path aliases used
- Full relative imports from project root

## Error Handling

**Patterns:**
- Use `raises` keyword for functions that can fail
- Custom exception structs: `CustomError`, `RQUserError`
- Try-except blocks for error handling

**Example:**
```mojo
def get_instrument(self, order_book_id: String) -> Instrument:
    try:
        return self._instruments[order_book_id]
    except:
        raise Error("Instrument not found: " + order_book_id)
```

**Exception Types:**
- `CustomError` - Base custom error with stack trace
- `RQUserError` - User-facing errors
- `RQInvalidArgument` - Invalid argument errors
- `InstrumentNotFound` - Domain-specific errors

## Logging

**Framework:** Custom logger in `rqmojo/utils/logger.mojo`

**Patterns:**
```mojo
from rqmojo.utils.logger import user_log, system_log, user_system_log

system_log().debug("Config: " + config.__str__())
user_system_log().error(e.msg)
```

**Log Levels:**
- DEBUG, INFO, WARNING, ERROR
- Separate loggers: user_log, system_log, user_system_log

## Comments

**When to Comment:**
- Docstrings at file top (triple quotes)
- Complex algorithm explanations
- TODO/FIXME markers for incomplete work

**Docstring Pattern:**
```mojo
"""
RQAlpha Mojo - Environment
Ported from rqalpha/environment.py
"""
```

**No JSDoc/TSDoc equivalent:**
- Mojo doesn't have standardized doc comments
- Use regular comments for inline documentation

## Function Design

**Size:** Functions should be focused and not too long

**Parameters:**
- Use default values where appropriate
- Group related parameters in structs

**Return Values:**
- Use `raises` for error handling
- Return `Optional[T]` for nullable results
- Use `Result[T, E]` pattern where appropriate

**Example:**
```mojo
def run(
    mut config: RQAlphaConfig,
    source_code: String = "",
    user_funcs: Dict[String, String] = Dict[String, String]()
) raises -> RunResult:
```

## Module Design

**Exports:**
- Use `comptime __all__` for explicit exports
- Factory functions for struct creation

**Barrel Files:**
- `__init__.mojo` files for package initialization
- Re-export key types and functions

**Pattern:**
```mojo
comptime __all__: List[String] = [
    "__version__",
    "run",
    "run_file",
    "run_code",
    "run_func",
]
```

## Mojo-Specific Patterns

**Memory Management:**
- Use `^` to transfer ownership: `return result^`
- Use `mut` for mutable parameters
- Use `ref self` for trait methods

**Traits:**
```mojo
trait Strategy:
    def init(ref self, context: StrategyContext) -> None:
        ...
    def handle_bar(ref self, context: StrategyContext, bar: BarObject) -> None:
        ...
```

**Comptime:**
- Use `comptime` for compile-time constants
- `comptime __all__`, `comptime VERSION`

**Field Decorators:**
```mojo
@fieldwise_init
struct Environment(Movable):
    var _start_date: DateTime
    var _event_bus: EventBus
```

---

*Convention analysis: 2026-03-26*
