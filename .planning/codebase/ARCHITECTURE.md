# Architecture

**Analysis Date:** 2026-03-26

## Pattern Overview

**Overall:** Event-Driven Architecture with Mod System

**Key Characteristics:**
- Environment singleton pattern for global state management
- Event bus for decoupled component communication
- Mod/plugin system for extensibility
- Strategy lifecycle callbacks (init, before_trading, handle_bar, after_trading)
- Data proxy abstraction for market data access

## Layers

**Core Layer:**
- Purpose: Strategy execution engine and event system
- Location: `rqmojo/core/`
- Contains: Executor, Strategy, StrategyContext, Events, StrategyLoader
- Depends on: Data layer, Portfolio layer, Utils
- Used by: Main entry point, Mods

**Data Layer:**
- Purpose: Market data access and storage
- Location: `rqmojo/data/`
- Contains: DataProxy, BaseDataSource, Bundle, PriceBoard
- Depends on: Model layer, Utils
- Used by: Core layer, Mods

**Model Layer:**
- Purpose: Data structures for trading domain
- Location: `rqmojo/model/`
- Contains: Instrument, Bar, Tick, Order, Trade
- Depends on: Utils
- Used by: All layers

**Portfolio Layer:**
- Purpose: Account and position management
- Location: `rqmojo/portfolio/`
- Contains: Account, Position, PositionQueue
- Depends on: Model layer
- Used by: Core layer, Mods

**Mod Layer:**
- Purpose: Extensible plugin system
- Location: `rqmojo/mod/`
- Contains: System mods (accounts, simulation, risk, analyser, scheduler, progress, transaction_cost)
- Depends on: Core, Data, Portfolio
- Used by: Main entry point

**API Layer:**
- Purpose: Public API for strategy development
- Location: `rqmojo/apis/`
- Contains: Base API, RQDatac API
- Depends on: Core, Model
- Used by: User strategies

**Utils Layer:**
- Purpose: Shared utilities and helpers
- Location: `rqmojo/utils/`
- Contains: Config, Logger, Exception, Testing, DateTime functions
- Depends on: Standard library, Third-party packages
- Used by: All layers

## Data Flow

**Backtest Execution Flow:**

1. `main.run()` creates Environment and ModHandler
2. ModHandler.start_up() initializes system mods
3. DataProxy is created and attached to Environment
4. Strategy is loaded (file/code/func)
5. Event POST_SYSTEM_INIT is published
6. Executor.run() starts main loop:
   - For each trading date:
     - PRE_BEFORE_TRADING → BEFORE_TRADING → POST_BEFORE_TRADING
     - PRE_BAR → BAR (handle_bar) → POST_BAR
     - PRE_AFTER_TRADING → AFTER_TRADING → POST_AFTER_TRADING
7. POST_STRATEGY_RUN event published
8. ModHandler.tear_down() cleans up

**State Management:**
- Environment struct holds all global state
- No singleton pattern in Mojo (passed explicitly)
- StrategyContext provides context to strategy callbacks

## Key Abstractions

**Environment:**
- Purpose: Central registry for all system components
- Examples: `rqmojo/environment.mojo`
- Pattern: Struct with comprehensive state management
- Key fields: event_bus, data_proxy, portfolio, config

**EventBus:**
- Purpose: Decoupled event-driven communication
- Examples: `rqmojo/core/events.mojo`
- Pattern: Observer pattern with listener registration
- Key methods: add_listener, publish_event

**Strategy Trait:**
- Purpose: Define strategy interface
- Examples: `rqmojo/core/strategy.mojo`
- Pattern: Trait with lifecycle methods
- Key methods: init, before_trading, handle_bar, after_trading

**DataProxy:**
- Purpose: Abstract market data access
- Examples: `rqmojo/data/data_proxy.mojo`
- Pattern: Facade pattern for data sources
- Key methods: get_bar, get_instrument, get_last_price

## Entry Points

**Main Entry:**
- Location: `rqmojo/main.mojo`
- Triggers: CLI command or programmatic call
- Responsibilities: Initialize environment, run backtest, handle errors

**CLI Entry:**
- Location: `rqmojo/__main__.mojo`
- Triggers: `mojo run rqmojo` command
- Responsibilities: Parse CLI args, dispatch to subcommands

**API Entry:**
- Location: `rqmojo/__init__.mojo`
- Triggers: `from rqmojo import run, run_file, run_code, run_func`
- Responsibilities: Provide clean API for programmatic use

## Error Handling

**Strategy:** Struct-based exception handling

**Patterns:**
- Custom exception types: CustomError, RQUserError, RQInvalidArgument
- Error types enum: EXC_TYPE (USER_EXC, SYSTEM_EXC, NOTSET)
- Stack trace capture in CustomError
- Exception groups for multiple errors

**Key Files:**
- `rqmojo/utils/exception.mojo`
- `rqmojo/const.mojo` (EXC_TYPE enum)

## Cross-Cutting Concerns

**Logging:** Custom logger with multiple levels
- Files: `rqmojo/utils/logger.mojo`
- Loggers: user_log, system_log, user_system_log

**Validation:** Frontend validators for order submission
- Files: `rqmojo/mod/rqmojo_mod_sys_risk/`
- Validators: cash, price, self-trade, is_trading

**Configuration:** YAML-based with hierarchy
- Files: `rqmojo/utils/config.mojo`
- Hierarchy: CLI args > strategy __config__ > config file > defaults

---

*Architecture analysis: 2026-03-26*
