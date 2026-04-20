# Codebase Structure

**Analysis Date:** 2026-03-26

## Directory Layout

```
mojo_refactor/
├── rqmojo/                    # Main Mojo implementation
│   ├── __init__.mojo          # Package entry, public API
│   ├── __main__.mojo          # CLI entry point
│   ├── _version.mojo          # Version information
│   ├── main.mojo              # Main run() function
│   ├── environment.mojo       # Central state management
│   ├── interface.mojo         # Abstract interfaces
│   ├── const.mojo             # Constants and enums
│   ├── api.mojo               # API exports
│   ├── mod_system.mojo        # Mod handler
│   ├── user_module.mojo       # User module support
│   ├── portfolio_manager.mojo # Portfolio management
│   │
│   ├── core/                  # Core execution engine
│   │   ├── events.mojo        # Event system
│   │   ├── executor.mojo      # Strategy executor
│   │   ├── strategy.mojo      # Strategy base/trait
│   │   ├── strategy_context.mojo
│   │   ├── strategy_loader.mojo
│   │   ├── strategy_universe.mojo
│   │   ├── execution_context.mojo
│   │   ├── global_var.mojo
│   │   └── gvar.mojo
│   │
│   ├── data/                  # Data layer
│   │   ├── data_proxy.mojo    # Data access facade
│   │   ├── bundle.mojo        # Bundle management
│   │   ├── bar_dict_price_board.mojo
│   │   ├── instruments_mixin.mojo
│   │   ├── trading_dates_mixin.mojo
│   │   ├── auto_update_bundle_mixin.mojo
│   │   └── base_data_source/  # Data source implementations
│   │       ├── data_source.mojo
│   │       ├── h5_reader.mojo
│   │       ├── storages.mojo
│   │       ├── adjust.mojo
│   │       └── storage_interface.mojo
│   │
│   ├── model/                 # Data models
│   │   ├── instrument.mojo    # Instrument struct
│   │   ├── bar.mojo           # Bar object
│   │   ├── tick.mojo          # Tick object
│   │   ├── order.mojo         # Order struct
│   │   └── trade.mojo         # Trade struct
│   │
│   ├── portfolio/             # Portfolio management
│   │   ├── account.mojo       # Account struct
│   │   ├── position.mojo      # Position struct
│   │   ├── position_queue.mojo
│   │   └── portfolio_manager.mojo
│   │
│   ├── mod/                   # Mod system (plugins)
│   │   ├── rqmojo_mod_sys_accounts/
│   │   ├── rqmojo_mod_sys_simulation/
│   │   ├── rqmojo_mod_sys_risk/
│   │   ├── rqmojo_mod_sys_analyser/
│   │   ├── rqmojo_mod_sys_scheduler/
│   │   ├── rqmojo_mod_sys_progress/
│   │   └── rqmojo_mod_sys_transaction_cost/
│   │
│   ├── apis/                  # Public API implementations
│   │   ├── api_base.mojo
│   │   ├── api_abstract.mojo
│   │   └── api_rqdatac.mojo
│   │
│   ├── cmds/                  # CLI commands
│   │   ├── entry.mojo
│   │   ├── run.mojo
│   │   ├── bundle.mojo
│   │   └── mod.mojo
│   │
│   ├── utils/                 # Utilities
│   │   ├── config.mojo
│   │   ├── logger.mojo
│   │   ├── exception.mojo
│   │   ├── typing.mojo
│   │   ├── datetime_func.mojo
│   │   ├── testing/
│   │   └── translations/
│   │
│   ├── examples/              # Example strategies
│   │   ├── buy_and_hold.mojo
│   │   ├── golden_cross.mojo
│   │   ├── macd.mojo
│   │   └── turtle.mojo
│   │
│   └── third_party/           # Third-party Mojo packages
│       ├── argmojo/
│       ├── EmberJson/
│       ├── NuMojo/
│       ├── mojo-yaml/
│       └── morrow.mojo/
│
└── tests/                     # Test files
    ├── mojo/                  # Mojo tests
    └── python/                # Python comparison tests
```

## Directory Purposes

**`rqmojo/core/`:**
- Purpose: Core execution engine
- Contains: Event system, executor, strategy base, context management
- Key files: `events.mojo`, `executor.mojo`, `strategy.mojo`

**`rqmojo/data/`:**
- Purpose: Market data access and storage
- Contains: DataProxy, data sources, bundle management
- Key files: `data_proxy.mojo`, `base_data_source/data_source.mojo`

**`rqmojo/model/`:**
- Purpose: Trading domain data structures
- Contains: Instrument, Bar, Tick, Order, Trade structs
- Key files: `instrument.mojo`, `bar.mojo`, `order.mojo`

**`rqmojo/mod/`:**
- Purpose: Plugin/mod system implementations
- Contains: System mods for accounts, simulation, risk, analysis
- Key files: Each mod has `mod.mojo` entry point

**`rqmojo/utils/`:**
- Purpose: Shared utilities and helpers
- Contains: Config, logging, exceptions, testing utilities
- Key files: `config.mojo`, `logger.mojo`, `exception.mojo`

**`rqmojo/third_party/`:**
- Purpose: Vendored third-party Mojo packages
- Contains: argmojo, EmberJson, NuMojo, mojo-yaml, morrow
- Note: These are modified for Mojo 0.26.2.0 compatibility

## Key File Locations

**Entry Points:**
- `rqmojo/__init__.mojo`: Public API (run, run_file, run_code, run_func)
- `rqmojo/main.mojo`: Main execution logic
- `rqmojo/__main__.mojo`: CLI entry

**Configuration:**
- `rqmojo/utils/config.mojo`: Config parsing and structures
- `rqmojo/const.mojo`: Constants and enums

**Core Logic:**
- `rqmojo/environment.mojo`: Central state management
- `rqmojo/core/events.mojo`: Event system
- `rqmojo/core/executor.mojo`: Strategy execution

**Testing:**
- `tests/mojo/`: Mojo test files
- `tests/python/`: Python comparison tests
- `tests/results/`: Test result markdown files

## Naming Conventions

**Files:**
- Snake_case: `data_proxy.mojo`, `strategy_loader.mojo`
- Init files: `__init__.mojo` (package initialization)
- Main files: `__main__.mojo` (CLI entry)

**Directories:**
- Snake_case: `rqmojo_mod_sys_accounts/`
- Mod directories: `rqmojo_mod_<mod_name>/`

**Structs:**
- PascalCase: `Environment`, `DataProxy`, `BaseStrategy`
- Field prefix: `_` for private fields (e.g., `_start_date`)

**Functions:**
- snake_case: `create_environment()`, `parse_config()`
- Factory pattern: `create_*` prefix for constructors

## Where to Add New Code

**New Feature:**
- Primary code: `rqmojo/<domain>/<feature>.mojo`
- Tests: `tests/mojo/<domain>/test_<feature>.mojo`

**New Component/Module:**
- Implementation: `rqmojo/<module_name>/`
- Init file: `rqmojo/<module_name>/__init__.mojo`

**New Mod:**
- Directory: `rqmojo/mod/rqmojo_mod_<mod_name>/`
- Entry: `rqmojo/mod/rqmojo_mod_<mod_name>/mod.mojo`
- Init: `rqmojo/mod/rqmojo_mod_<mod_name>/__init__.mojo`

**Utilities:**
- Shared helpers: `rqmojo/utils/<util_name>.mojo`

**Example Strategies:**
- Location: `rqmojo/examples/<strategy_name>.mojo`

## Special Directories

**`third_party/`:**
- Purpose: Vendored third-party Mojo packages
- Generated: No
- Committed: Yes
- Note: Modified for Mojo 0.26.2.0 compatibility

**`tests/results/`:**
- Purpose: Test result markdown files
- Generated: Yes (by test runs)
- Committed: Yes (for tracking)

---

*Structure analysis: 2026-03-26*
