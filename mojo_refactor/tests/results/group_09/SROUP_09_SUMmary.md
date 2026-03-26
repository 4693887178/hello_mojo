# Group 09 Test Summary

Test Date: Wed Mar 26 2026

## Test Results

| File | Status |
|------|--------|
| test_account.mojo | PASSED |
| test_bar_dict.mojo | PASSED |
| test_base_data_source.mojo | PASSED |
| test_bundle.mojo | PASSED |
| test_bundle_data.mojo | PASSED |
| test_executor.mojo | PASSED |
| test_instrument.mojo | PASSED |
| test_portfolio.mojo | PASSED |
| test_price_validator.mojo | PASSED |
| test_report.mojo | PASSED |
| test_scheduler.mojo | PASSED |
| test_self_trade_validator.mojo | PASSED |
| test_signal_broker.mojo | PASSED |
| test_simulation_mod.mojo | PASSED |
| test_simulation_testing.mojo | PASSED |
| test_strategy.mojo | PASSED |

## Statistics

- **Total Tests:** 45
- **Passed:** 45
- **Failed:** 0
- **Pass Rate:** 100%

## Detailed Reports

See individual test result files in this directory:
- [01_bundle.md](./01_bundle.md)
- [02_bundle_data.md](./02_bundle_data.md)
- [03_bar_dict.md](./03_bar_dict.md)
- [04_base_data_source.md](./04_base_data_source.md)
- [05_executor.md](./05_executor.md)
- [06_instrument.md](./06_instrument.md)
- [07_portfolio.md](./07_portfolio.md)
- [08_price_validator.md](./08_price_validator.md)
- [09_report.md](./09_report.md)
- [10_scheduler.md](./10_scheduler.md)
- [11_self_trade_validator.md](./11_self_trade_validator.md)
- [12_signal_broker.md](./12_signal_broker.md)
- [13_simulation_mod.md](./13_simulation_mod.md)
- [14_simulation_testing.md](./14_simulation_testing.md)
- [15_strategy.md](./15_strategy.md)

## Test Categories

### Bundle Tests (6 tests)
- Bundle command module tests
- Bundle data tests

### Bar Dict Tests (3 tests)
- BarDictPriceBoard initialization and price retrieval
- Cache clearing

### Base Data Source Tests (3 tests)
- BaseDataSource initialization
- get_bar
- get_instrument

### Bundle Tests (3 tests)
- Bundle command tests
- Bundle data tests

### Instrument Tests (3 tests)
- Instrument struct verification
- Property verification (order_book_id, symbol, type)
- Exchange verification

### Portfolio Tests (3 tests)
- Portfolio initialization
- total_value
- get_account

### Price Validator Tests (3 tests)
- PriceValidator initialization and enabled/disabled states

### Report Tests (2 tests)
- Report initialization
- Summary generation

### Scheduler Tests (4 tests)
- Scheduler initialization
- schedule_daily functionality
- TimeRule market_open/market_close

### Self Trade Validator Tests (3 tests)
- SelfTradeValidator initialization and enabled/disabled states

### Signal Broker Tests (3 tests)
- SignalBroker initialization
- get_order_count
- get_open_orders

### Simulation Mod Tests (4 tests)
- SimulationMod initialization
- get_matching_type
- get_slippage

### Testing Module Tests (1 test)
- testing module existence verification

### Strategy Tests (3 tests)
- BaseStrategy initialization
- with name
- str representation
