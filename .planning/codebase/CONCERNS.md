# Codebase Concerns

**Analysis Date:** 2026-03-26

## Tech Debt

**Incomplete Python Port:**
- Issue: Many functions are stubs returning empty/default values
- Files: `rqmojo/environment.mojo`, `rqmojo/data/data_proxy.mojo`
- Impact: Backtests may not produce accurate results
- Fix approach: Complete implementation by referencing Python rqalpha

**Third-Party Package TODOs:**
- Issue: NuMojo has many TODOs and FIXMEs
- Files: `rqmojo/third_party/NuMojo/numojo/core/ndarray.mojo`
- Impact: Potential bugs in numerical computations
- Fix approach: Monitor NuMojo upstream updates, apply fixes locally

**order_target_portfolio Logic:**
- Issue: Complex logic with edge case handling issues
- Files: `rqmojo/mod/rqmojo_mod_sys_accounts/api/order_target_portfolio.mojo`
- Impact: May produce incorrect order quantities
- Fix approach: Add input validation, handle NaN/None cases

## Known Bugs

**Empty Return Values:**
- Symptoms: Functions return empty lists/dicts instead of actual data
- Files: `rqmojo/environment.mojo` (history_bars, get_trading_dates)
- Trigger: Calling data access methods
- Workaround: Use Python interop for data access

**Missing Validation:**
- Symptoms: No validation for price > 0, quantity limits
- Files: `rqmojo/mod/rqmojo_mod_sys_accounts/api/order_target_portfolio.mojo`
- Trigger: Invalid input data
- Workaround: Validate inputs before calling API

## Security Considerations

**Python Interop:**
- Risk: Arbitrary Python code execution through interop
- Files: All files using `std.python`
- Current mitigation: None (development environment)
- Recommendations: Sandbox Python execution in production

**File Path Handling:**
- Risk: No path validation for strategy files
- Files: `rqmojo/core/strategy_loader.mojo`
- Current mitigation: None
- Recommendations: Validate file paths, restrict to allowed directories

## Performance Bottlenecks

**Data Loading:**
- Problem: HDF5 data loading may be slow
- Files: `rqmojo/data/base_data_source/h5_reader.mojo`
- Cause: No caching, repeated reads
- Improvement path: Implement data caching layer

**Event Processing:**
- Problem: Sequential event processing
- Files: `rqmojo/core/events.mojo`
- Cause: No parallel event handling
- Improvement path: Consider parallel event dispatch for independent handlers

## Fragile Areas

**Environment Struct:**
- Files: `rqmojo/environment.mojo`
- Why fragile: Large struct with many fields, complex initialization
- Safe modification: Use factory functions, add fields at end
- Test coverage: Limited

**Strategy Loader:**
- Files: `rqmojo/core/strategy_loader.mojo`
- Why fragile: Multiple loader types, Python interop dependency
- Safe modification: Test thoroughly with different strategy types
- Test coverage: Needs improvement

**Mod System:**
- Files: `rqmojo/mod_system.mojo`, `rqmojo/mod/*/mod.mojo`
- Why fragile: Interdependencies between mods
- Safe modification: Test mod startup/shutdown sequence
- Test coverage: Minimal

## Scaling Limits

**Data Bundle Size:**
- Current capacity: Limited by memory
- Limit: Large bundles may cause memory issues
- Scaling path: Implement streaming data loading

**Strategy Complexity:**
- Current capacity: Simple strategies work
- Limit: Complex strategies with many instruments may be slow
- Scaling path: Optimize event loop, add parallel processing

## Dependencies at Risk

**NuMojo:**
- Risk: Active development, API changes
- Impact: Numerical computation failures
- Migration plan: Pin version, monitor upstream

**Mojo Standard Library:**
- Risk: Evolving API, breaking changes
- Impact: Compilation errors after updates
- Migration plan: Test with each Mojo update, maintain compatibility layer

**morrow (DateTime):**
- Risk: Third-party library, may not track Mojo updates
- Impact: Date/time handling failures
- Migration plan: Consider stdlib datetime when available

## Missing Critical Features

**Complete Data Layer:**
- Problem: DataProxy returns stub data
- Blocks: Accurate backtesting

**Strategy Execution:**
- Problem: Executor.run() is stub
- Blocks: Running actual strategies

**Mod Integration:**
- Problem: Mods not fully integrated
- Blocks: Risk management, analysis, reporting

**Python Strategy Loading:**
- Problem: Cannot load Python strategy files
- Blocks: Using existing Python strategies

## Test Coverage Gaps

**Core Execution:**
- What's not tested: Executor, strategy lifecycle
- Files: `rqmojo/core/executor.mojo`, `rqmojo/core/strategy.mojo`
- Risk: Execution errors not caught
- Priority: High

**Data Layer:**
- What's not tested: DataProxy, HDF5 reading
- Files: `rqmojo/data/data_proxy.mojo`, `rqmojo/data/base_data_source/`
- Risk: Data access errors
- Priority: High

**Mod System:**
- What's not tested: Mod lifecycle, inter-mod communication
- Files: `rqmojo/mod/*/`
- Risk: Mod integration failures
- Priority: Medium

**Portfolio Management:**
- What's not tested: Position tracking, P&L calculation
- Files: `rqmojo/portfolio/`
- Risk: Incorrect portfolio state
- Priority: High

## Code Quality Issues

**Large Files:**
- Files: `rqmojo/environment.mojo` (568 lines), `rqmojo/core/events.mojo` (341 lines)
- Impact: Hard to navigate and maintain
- Recommendation: Split into smaller modules

**Inconsistent Error Handling:**
- Issue: Mix of Error raises and silent failures
- Files: Throughout codebase
- Impact: Debugging difficulty
- Recommendation: Standardize on raises pattern

**Missing Documentation:**
- Issue: No inline documentation for complex functions
- Files: Throughout codebase
- Impact: Hard for new contributors
- Recommendation: Add docstrings to public APIs

---

*Concerns audit: 2026-03-26*
