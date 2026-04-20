Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
============================================================
Running api_base.mojo Comprehensive Tests
============================================================

Test: assure_order_book_id returns input string
  PASSED
Test: cal_style with no price returns MarketOrder
  PASSED
Test: cal_style with price > 0 returns LimitOrder
  PASSED
Test: cal_style with price_or_style returns LimitOrder
  PASSED
Test: order_shares buy market order
  PASSED
Test: order_shares sell (negative quantity)
  PASSED
Test: order_shares with zero quantity returns None
  PASSED
Test: order_shares with LIMIT type creates LimitOrder
  PASSED
Test: order_value with positive amount buys shares
  PASSED
Test: order_value with zero returns None
  PASSED
Test: order_value with negative amount sells
  PASSED
Test: order_percent with valid percent (0, 1]
  PASSED
Test: order_percent with 0 returns None
  PASSED
Test: order_percent > 1 returns None
  PASSED
Test: order_percent negative returns None
  PASSED
Test: order_target_value increases position
  PASSED
Test: order_target_percent converts percent to value
  PASSED
Test: submit_order buy side
  PASSED
Test: submit_order sell side
  PASSED
Test: submit_order with zero amount returns None
  PASSED
Test: submit_order with negative amount returns None
  PASSED
Test: submit_order with price creates limit order
  PASSED
Test: cancel_order on active order returns order copy
  PASSED
Test: cancel_order on inactive order returns order copy
  PASSED
Test: history_bars with close field
  PASSED
Test: history_bars with open field
  PASSED
Test: history_bars with volume field
  PASSED
Test: history_bars with high and low fields
  PASSED
Test: history_bars defaults to close field
  PASSED
Test: history delegates to history_bars
  PASSED
Test: get_price returns values in date range
  PASSED
Test: current_snapshot returns None (stub)
  PASSED
Test: get_trading_dates generates dates in range
  PASSED
Test: get_previous_trading_date returns earlier date
  PASSED
Test: get_next_trading_date returns later date
  PASSED
Test: get_position returns None for empty position
  PASSED
Test: get_position uses LONG direction by default
  PASSED
Test: get_positions returns empty list
  PASSED
Test: get_portfolio returns Portfolio object
  PASSED
Test: instruments returns Instrument for valid id
  PASSED
Test: all_instruments returns empty list (stub)
  PASSED
Test: active_instrument returns instrument
  PASSED
Test: deposit is a no-op stub
  PASSED
Test: withdraw is a no-op stub
  PASSED
Test: subscribe is a no-op stub
  PASSED
Test: unsubscribe is a no-op stub
  PASSED

============================================================
All api_base tests completed successfully!
============================================================
