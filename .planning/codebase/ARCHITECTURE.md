# System Architecture

## Overview
The rqmojo trading framework follows a modular architecture designed for quantitative trading strategies. It separates concerns into distinct layers, providing a clean structure for strategy development, execution, and portfolio management.

## Architecture Layers

### 1. Core Layer
- **Strategy Core** - Defines the base strategy interface and execution logic
  - `mojo_refactor/rqmojo/core/strategy.mojo` - Base strategy class
  - `mojo_refactor/rqmojo/core/strategy_loader.mojo` - Strategy loading mechanism
  - `mojo_refactor/rqmojo/core/strategy_universe.mojo` - Strategy universe management

- **Execution Core** - Handles order execution and event processing
  - `mojo_refactor/rqmojo/core/executor.mojo` - Execution engine
  - `mojo_refactor/rqmojo/core/execution_context.mojo` - Execution context management
  - `mojo_refactor/rqmojo/core/events.mojo` - Event system

- **Global State** - Manages global variables and context
  - `mojo_refactor/rqmojo/core/gvar.mojo` - Global variables
  - `mojo_refactor/rqmojo/core/global_var.mojo` - Global variable management

### 2. Model Layer
- **Data Models** - Defines core data structures for trading
  - `mojo_refactor/rqmojo/model/instrument.mojo` - Instrument definitions
  - `mojo_refactor/rqmojo/model/bar.mojo` - OHLCV bar data
  - `mojo_refactor/rqmojo/model/tick.mojo` - Tick data
  - `mojo_refactor/rqmojo/model/order.mojo` - Order definitions
  - `mojo_refactor/rqmojo/model/trade.mojo` - Trade execution data

### 3. Portfolio Layer
- **Portfolio Management** - Handles portfolio construction and management
  - `mojo_refactor/rqmojo/portfolio/portfolio_manager.mojo` - Portfolio management
  - `mojo_refactor/rqmojo/portfolio/account.mojo` - Account management
  - `mojo_refactor/rqmojo/portfolio/position.mojo` - Position management
  - `mojo_refactor/rqmojo/portfolio/position_queue.mojo` - Position queue

### 4. API Layer
- **Data APIs** - Provides market data access
  - `mojo_refactor/rqmojo/apis/api_abstract.mojo` - Abstract API interface
  - `mojo_refactor/rqmojo/apis/api_base.mojo` - Base API implementation
  - `mojo_refactor/rqmojo/apis/api_rqdatac.mojo` - rqdatac API integration
  - `mojo_refactor/rqmojo/apis/names.mojo` - API naming conventions

### 5. Utility Layer
- **Utilities** - Helper functions and utilities
  - `mojo_refactor/rqmojo/utils/concurrent.mojo` - Concurrent processing
  - `mojo_refactor/rqmojo/utils/rq_json.mojo` - JSON handling
  - `mojo_refactor/rqmojo/utils/repr.mojo` - Object representation
  - `mojo_refactor/rqmojo/utils/risk_free_helper.mojo` - Risk-free rate calculations
  - `mojo_refactor/rqmojo/utils/strategy_loader_help.mojo` - Strategy loading helpers
  - `mojo_refactor/rqmojo/utils/datetime_func.mojo` - Date/time functions

### 6. Command Layer
- **CLI Commands** - Command-line interface
  - `mojo_refactor/rqmojo/cmds/` - Command implementations

## Data Flow

1. **Strategy Initialization** - Strategy is loaded and initialized
2. **Market Data Ingestion** - Data is fetched from APIs
3. **Strategy Execution** - Strategy processes data and generates signals
4. **Order Generation** - Signals are converted to orders
5. **Order Execution** - Orders are executed through the executor
6. **Portfolio Update** - Portfolio is updated with executed trades
7. **Performance Tracking** - Performance metrics are calculated

## Key Design Patterns

### 1. Strategy Pattern
- **Description**: Defines a family of algorithms, encapsulates each one, and makes them interchangeable
- **Implementation**: `strategy.mojo` defines the base strategy interface

### 2. Factory Pattern
- **Description**: Creates objects without exposing the instantiation logic
- **Implementation**: `strategy_loader.mojo` loads strategies dynamically

### 3. Observer Pattern
- **Description**: Defines a one-to-many dependency between objects
- **Implementation**: `events.mojo` implements event publishing and subscription

### 4. Context Pattern
- **Description**: Provides a way to access global state and dependencies
- **Implementation**: `execution_context.mojo` and `strategy_context.mojo`

### 5. Module System
- **Description**: Extensible module system for adding functionality
- **Implementation**: `mod_system.mojo` and `user_module.mojo`

## Entry Points

- **Main Entry** - `mojo_refactor/rqmojo/main.mojo`
- **Command Entry** - `mojo_refactor/rqmojo/cmds/entry.mojo`
- **Module Entry** - `mojo_refactor/rqmojo/mod_system.mojo`

## Extension Points

- **Custom Strategies** - Inherit from base strategy class
- **Custom APIs** - Implement abstract API interface
- **Custom Modules** - Extend via module system
