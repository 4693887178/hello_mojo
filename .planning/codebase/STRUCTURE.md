# Directory Structure

## Overview
This document describes the directory structure and organization of the rqmojo trading framework.

## Root Structure

```
/home/zhou/hello_mojo/trae_cn_78/
├── mojo_refactor/          # Main project directory
│   ├── rqmojo/            # Core trading framework
│   ├── third_party/        # External dependencies
│   └── mojo.project        # Mojo project configuration
├── .trae/                  # GSD configuration and workflows
├── .cursor/                # Cursor IDE configuration
├── .agents/                # Agent configurations
├── install_gsd_trae.sh     # GSD installation script
├── main.py                 # Python entry point
├── pyproject.toml          # Python project configuration
├── .gitignore              # Git ignore file
├── .python-version         # Python version specification
└── README.md               # Project README
```

## mojo_refactor/ Directory

### rqmojo/ Subdirectory

```
rqmojo/
├── core/                  # Core functionality
│   ├── __init__.mojo      # Module initialization
│   ├── execution_context.mojo  # Execution context
│   ├── executor.mojo      # Execution engine
│   ├── events.mojo        # Event system
│   ├── gvar.mojo          # Global variables
│   ├── global_var.mojo    # Global variable management
│   ├── strategy.mojo      # Base strategy class
│   ├── strategy_loader.mojo  # Strategy loading
│   ├── strategy_universe.mojo  # Strategy universe
├── model/                 # Data models
│   ├── __init__.mojo      # Module initialization
│   ├── bar.mojo           # OHLCV bar data
│   ├── instrument.mojo    # Instrument definitions
│   ├── order.mojo         # Order definitions
│   ├── tick.mojo          # Tick data
│   └── trade.mojo         # Trade execution data
├── portfolio/             # Portfolio management
│   ├── __init__.mojo      # Module initialization
│   ├── account.mojo       # Account management
│   ├── portfolio_manager.mojo  # Portfolio management
│   ├── position.mojo      # Position management
│   └── position_queue.mojo  # Position queue
├── apis/                  # API integrations
│   ├── __init__.mojo      # Module initialization
│   ├── api_abstract.mojo  # Abstract API interface
│   ├── api_base.mojo      # Base API implementation
│   ├── api_rqdatac.mojo   # rqdatac API integration
│   └── names.mojo         # API naming conventions
├── utils/                 # Utilities
│   ├── concurrent.mojo    # Concurrent processing
│   ├── datetime_func.mojo # Date/time functions
│   ├── repr.mojo          # Object representation
│   ├── risk_free_helper.mojo  # Risk-free rate calculations
│   ├── rq_json.mojo       # JSON handling
│   ├── strategy_loader_help.mojo  # Strategy loading helpers
│   └── testing/           # Testing utilities
│       ├── __init__.mojo  # Module initialization
│       ├── fixtures.mojo  # Test fixtures
│       ├── integration.mojo  # Integration tests
│       └── mocking.mojo   # Mocking utilities
├── cmds/                  # Command-line interface
│   ├── __init__.mojo      # Module initialization
│   ├── bundle.mojo        # Bundle creation
│   ├── entry.mojo         # Command entry point
│   ├── misc.mojo          # Miscellaneous commands
│   ├── mod.mojo           # Module management
│   └── run.mojo           # Strategy execution
├── examples/              # Example strategies
│   ├── IF_macd.mojo       # MACD strategy for IF
│   ├── pair_trading.mojo  # Pair trading strategy
│   ├── rsi.mojo           # RSI strategy
│   ├── run_file_demo.mojo # Run file demo
│   ├── test_pt.mojo       # Pair trading test
│   └── extend_api/        # API extension example
├── __init__.mojo          # Module initialization
├── const.mojo             # Constants
├── environment.mojo       # Execution environment
├── main.mojo              # Main entry point
├── mod/                   # Module system
│   └── utils.mojo         # Module utilities
├── mod_system.mojo        # Module system
├── portfolio_manager.mojo # Portfolio manager (root level)
├── user_module.mojo       # User module system
└── _version.mojo          # Version information
```

### third_party/ Subdirectory

```
third_party/
├── __init__.mojo          # Module initialization
└── morrow/                # Time-related utilities
    ├── __init__.mojo      # Module initialization
    ├── _libc.mojo         # C library integration
    ├── _py.mojo           # Python integration
    ├── constants.mojo     # Constant definitions
    ├── formatter.mojo     # Time formatting
    ├── morrow.mojo        # Core functionality
    ├── timedelta.mojo     # Time difference calculations
    ├── timezone.mojo      # Timezone handling
    └── util.mojo          # Utility functions
```

## Key Directories and Their Purpose

### Core Directories
- **core/** - Contains the core functionality of the trading framework
- **model/** - Defines data models for trading entities
- **portfolio/** - Manages portfolio construction and management
- **apis/** - Provides integration with external data APIs
- **utils/** - Utility functions and helpers
- **cmds/** - Command-line interface commands
- **examples/** - Example trading strategies

### Third-Party Dependencies
- **third_party/** - External libraries and dependencies
  - **morrow/** - Time-related utilities library

## Naming Conventions

### File Naming
- **Snake_case** - Filenames use snake_case (e.g., `strategy_loader.mojo`)
- **Descriptive names** - Files are named to clearly indicate their purpose

### Directory Naming
- **Lowercase** - Directories use lowercase names
- **Singular or plural** - Directory names use singular or plural based on content

### Module Naming
- **Package structure** - Modules follow a hierarchical package structure
- **__init__.mojo** - Each directory has an `__init__.mojo` file for module initialization

## Key Files and Their Purpose

### Configuration Files
- `mojo_refactor/mojo.project` - Mojo project configuration
- `pyproject.toml` - Python project configuration
- `.gitignore` - Git ignore configuration
- `.python-version` - Python version specification

### Entry Points
- `mojo_refactor/rqmojo/main.mojo` - Main Mojo entry point
- `main.py` - Python entry point
- `mojo_refactor/rqmojo/cmds/entry.mojo` - Command-line entry point

### Documentation
- `README.md` - Project README
