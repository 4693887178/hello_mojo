# Technology Stack

## Overview
This codebase is a Mojo project with Python integration, focusing on quantitative trading (rqmojo).

## Languages
- **Mojo** - Primary language for core functionality
- **Python** - Used for integration and potentially some utilities

## Dependencies
- **Morrow** - Third-party Mojo library for time-related functionality
  - `mojo_refactor/third_party/morrow/`

## Configuration
- **mojo.project** - Mojo project configuration file
  - `mojo_refactor/mojo.project`

## Key Components
- **rqmojo** - Main trading framework
  - Core components: strategy, execution, portfolio management
  - API integrations: rqdatac
  - Utilities: testing, concurrent processing, JSON handling

## File Structure
- `mojo_refactor/` - Main project directory
  - `rqmojo/` - Core trading framework
  - `third_party/` - External dependencies

## Build System
- Mojo build system via `mojo.project`

## Runtime Environment
- Mojo runtime
- Python runtime (for integration)

## Development Tools
- **GSD (Get Shit Done)** - Project management and workflow tool
  - `.trae/` and `.cursor/` directories contain GSD configuration
