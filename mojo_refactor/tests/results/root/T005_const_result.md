# root/const.mojo 测试结果

## 测试时间
2026-03-19

## 测试条件
- 输入: 常量枚举值测试
- 环境: Python 3.14 / Mojo 0.26.2.0

## Python 测试结果

```
============================================================
RQAlpha Python root/const.py Test
============================================================

=== Testing EXECUTION_PHASE ===
GLOBAL: name=GLOBAL, value=[全局]
ON_INIT: name=ON_INIT, value=[程序初始化]
BEFORE_TRADING: name=BEFORE_TRADING, value=[日内交易前]
ON_BAR: name=ON_BAR, value=[盘中 handle_bar 函数]
ON_TICK: name=ON_TICK, value=[盘中 handle_tick 函数]
AFTER_TRADING: name=AFTER_TRADING, value=[日内交易后]
FINALIZED: name=FINALIZED, value=[程序结束]
SCHEDULED: name=SCHEDULED, value=[scheduler函数内]

=== Testing RUN_TYPE ===
BACKTEST: name=BACKTEST, value=BACKTEST
PAPER_TRADING: name=PAPER_TRADING, value=PAPER_TRADING
LIVE_TRADING: name=LIVE_TRADING, value=LIVE_TRADING

=== Testing DEFAULT_ACCOUNT_TYPE ===
STOCK: name=STOCK, value=STOCK
FUTURE: name=FUTURE, value=FUTURE
BOND: name=BOND, value=BOND

=== Testing MATCHING_TYPE ===
CURRENT_BAR_CLOSE: name=CURRENT_BAR_CLOSE, value=CURRENT_BAR_CLOSE
VWAP: name=VWAP, value=VWAP
COUNTERPARTY_OFFER: name=COUNTERPARTY_OFFER, value=COUNTERPARTY_OFFER
NEXT_BAR_OPEN: name=NEXT_BAR_OPEN, value=NEXT_BAR_OPEN

=== Testing ORDER_TYPE ===
MARKET: name=MARKET, value=MARKET
LIMIT: name=LIMIT, value=LIMIT
ALGO: name=ALGO, value=ALGO

=== Testing ORDER_STATUS ===
PENDING_NEW: name=PENDING_NEW, value=PENDING_NEW
ACTIVE: name=ACTIVE, value=ACTIVE
FILLED: name=FILLED, value=FILLED
REJECTED: name=REJECTED, value=REJECTED
CANCELLED: name=CANCELLED, value=CANCELLED

=== Testing SIDE ===
BUY: name=BUY, value=BUY
SELL: name=SELL, value=SELL
FINANCING: name=FINANCING, value=FINANCING
MARGIN: name=MARGIN, value=MARGIN

=== Testing POSITION_EFFECT ===
OPEN: name=OPEN, value=OPEN
CLOSE: name=CLOSE, value=CLOSE
CLOSE_TODAY: name=CLOSE_TODAY, value=CLOSE_TODAY

=== Testing POSITION_DIRECTION ===
LONG: name=LONG, value=LONG
SHORT: name=SHORT, value=SHORT

=== Testing INSTRUMENT_TYPE ===
CS: name=CS, value=CS
FUTURE: name=FUTURE, value=Future
OPTION: name=OPTION, value=Option
ETF: name=ETF, value=ETF
LOF: name=LOF, value=LOF
INDX: name=INDX, value=INDX

=== Testing EXCHANGE ===
XSHE: name=XSHE, value=XSHE
XSHG: name=XSHG, value=XSHG
SHFE: name=SHFE, value=SHFE
DCE: name=DCE, value=DCE
CZCE: name=CZCE, value=CZCE
CFFEX: name=CFFEX, value=CFFEX

=== Testing DAYS_CNT ===
DAYS_A_YEAR: 365
TRADING_DAYS_A_YEAR: 252

=== Testing MARKET ===
CN: name=CN, value=CN
HK: name=HK, value=HK

=== Testing Equality ===
PASS: buy1 == buy2
PASS: buy1 != sell

============================================================
All tests completed!
============================================================
```

## Mojo 测试结果

```
============================================================
RQAlpha Mojo root/const.mojo Test
============================================================

=== Testing EXECUTION_PHASE ===
GLOBAL: name=GLOBAL, value=[全局]
ON_INIT: name=ON_INIT, value=[程序初始化]
BEFORE_TRADING: name=BEFORE_TRADING, value=[日内交易前]
ON_BAR: name=ON_BAR, value=[盘中 handle_bar 函数]
ON_TICK: name=ON_TICK, value=[盘中 handle_tick 函数]
AFTER_TRADING: name=AFTER_TRADING, value=[日内交易后]
FINALIZED: name=FINALIZED, value=[程序结束]
SCHEDULED: name=SCHEDULED, value=[scheduler函数内]

=== Testing RUN_TYPE ===
BACKTEST: name=BACKTEST, value=BACKTEST
PAPER_TRADING: name=PAPER_TRADING, value=PAPER_TRADING
LIVE_TRADING: name=LIVE_TRADING, value=LIVE_TRADING

=== Testing DEFAULT_ACCOUNT_TYPE ===
STOCK: name=STOCK, value=STOCK
FUTURE: name=FUTURE, value=FUTURE
BOND: name=BOND, value=BOND

=== Testing MATCHING_TYPE ===
CURRENT_BAR_CLOSE: name=CURRENT_BAR_CLOSE, value=CURRENT_BAR_CLOSE
VWAP: name=VWAP, value=VWAP
COUNTERPARTY_OFFER: name=COUNTERPARTY_OFFER, value=COUNTERPARTY_OFFER
NEXT_BAR_OPEN: name=NEXT_BAR_OPEN, value=NEXT_BAR_OPEN

=== Testing ORDER_TYPE ===
MARKET: name=MARKET, value=MARKET
LIMIT: name=LIMIT, value=LIMIT
ALGO: name=ALGO, value=ALGO

=== Testing ORDER_STATUS ===
PENDING_NEW: name=PENDING_NEW, value=PENDING_NEW
ACTIVE: name=ACTIVE, value=ACTIVE
FILLED: name=FILLED, value=FILLED
REJECTED: name=REJECTED, value=REJECTED
CANCELLED: name=CANCELLED, value=CANCELLED

=== Testing SIDE ===
BUY: name=BUY, value=BUY
SELL: name=SELL, value=SELL
FINANCING: name=FINANCING, value=FINANCING
MARGIN: name=MARGIN, value=MARGIN

=== Testing POSITION_EFFECT ===
OPEN: name=OPEN, value=OPEN
CLOSE: name=CLOSE, value=CLOSE
CLOSE_TODAY: name=CLOSE_TODAY, value=CLOSE_TODAY

=== Testing POSITION_DIRECTION ===
LONG: name=LONG, value=LONG
SHORT: name=SHORT, value=SHORT

=== Testing INSTRUMENT_TYPE ===
CS: name=CS, value=CS
FUTURE: name=FUTURE, value=Future
OPTION: name=OPTION, value=Option
ETF: name=ETF, value=ETF
LOF: name=LOF, value=LOF
INDX: name=INDX, value=INDX

=== Testing EXCHANGE ===
XSHE: name=XSHE, value=XSHE
XSHG: name=XSHG, value=XSHG
SHFE: name=SHFE, value=SHFE
DCE: name=DCE, value=DCE
CZCE: name=CZCE, value=CZCE
CFFEX: name=CFFEX, value=CFFEX

=== Testing DAYS_CNT ===
DAYS_A_YEAR: 365
TRADING_DAYS_A_YEAR: 252

=== Testing MARKET ===
CN: name=CN, value=CN
HK: name=HK, value=HK

=== Testing Equality ===
PASS: buy1 == buy2
PASS: buy1 != sell

============================================================
All tests completed!
============================================================
```

## 对比结果
- [x] 输出一致
- [x] 功能正确
- [x] 所有枚举值正确

## 结论
**通过** ✅
