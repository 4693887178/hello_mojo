# External Integrations

## Overview
This document describes the external services, APIs, and dependencies integrated with the rqmojo trading framework.

## API Integrations

### rqdatac
- **Description**: Data API for quantitative trading
- **Location**: `mojo_refactor/rqmojo/apis/api_rqdatac.mojo`
- **Purpose**: Provides market data for strategy analysis and backtesting

## Third-Party Libraries

### Morrow
- **Description**: Time-related utilities library
- **Location**: `mojo_refactor/third_party/morrow/`
- **Components**:
  - `morrow.mojo` - Core functionality
  - `timedelta.mojo` - Time difference calculations
  - `timezone.mojo` - Timezone handling
  - `util.mojo` - Utility functions
  - `_libc.mojo` - C library integration
  - `constants.mojo` - Constant definitions
  - `formatter.mojo` - Time formatting
  - `__init__.mojo` - Module initialization
  - `_py.mojo` - Python integration

## Internal Integrations

### Testing Framework
- **Description**: Internal testing utilities
- **Location**: `mojo_refactor/rqmojo/utils/testing/`
- **Components**:
  - `integration.mojo` - Integration tests
  - `mocking.mojo` - Mocking utilities
  - `fixtures.mojo` - Test fixtures
  - `__init__.mojo` - Module initialization

### Concurrent Processing
- **Description**: Utilities for concurrent operations
- **Location**: `mojo_refactor/rqmojo/utils/concurrent.mojo`

### JSON Handling
- **Description**: JSON parsing and serialization
- **Location**: `mojo_refactor/rqmojo/utils/rq_json.mojo`

## Command-Line Interface
- **Description**: CLI commands for the trading framework
- **Location**: `mojo_refactor/rqmojo/cmds/`
- **Commands**:
  - `bundle.mojo` - Bundle creation
  - `run.mojo` - Strategy execution
  - `mod.mojo` - Module management
  - `misc.mojo` - Miscellaneous commands
  - `entry.mojo` - Entry point
  - `__init__.mojo` - Module initialization

## Execution Environment
- **Description**: Environment configuration for strategy execution
- **Location**: `mojo_refactor/rqmojo/environment.mojo`
