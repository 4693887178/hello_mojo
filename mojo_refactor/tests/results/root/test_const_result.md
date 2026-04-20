# RQMojo const.mojo 测试结果

## 测试信息

- **测试日期**: 2026-03-23
- **测试文件**: `tests/mojo/root/test_const.mojo`
- **源文件**: `rqmojo/const.mojo`
- **Mojo 版本**: 0.26.2.0

## 测试概要

| 项目 | 结果 |
|------|------|
| 总测试数 | 24 |
| 通过数 | 24 |
| 失败数 | 0 |
| 状态 | ✅ 全部通过 |

## 测试详情

### 1. 枚举类测试

#### EXECUTION_PHASE
- ✅ GLOBAL: name="GLOBAL", value="[全局]"
- ✅ ON_INIT: name="ON_INIT", value="[程序初始化]"
- ✅ BEFORE_TRADING: name="BEFORE_TRADING", value="[日内交易前]"
- ✅ OPEN_AUCTION: name="OPEN_AUCTION", value="[集合竞价]"
- ✅ ON_BAR: name="ON_BAR", value="[盘中 handle_bar 函数]"
- ✅ ON_TICK: name="ON_TICK", value="[盘中 handle_tick 函数]"
- ✅ AFTER_TRADING: name="AFTER_TRADING", value="[日内交易后]"
- ✅ FINALIZED: name="FINALIZED", value="[程序结束]"
- ✅ SCHEDULED: name="SCHEDULED", value="[scheduler函数内]"

#### RUN_TYPE
- ✅ BACKTEST: name="BACKTEST", value="BACKTEST"
- ✅ PAPER_TRADING: name="PAPER_TRADING", value="PAPER_TRADING"
- ✅ LIVE_TRADING: name="LIVE_TRADING", value="LIVE_TRADING"

#### DEFAULT_ACCOUNT_TYPE
- ✅ STOCK: name="STOCK", value="STOCK"
- ✅ FUTURE: name="FUTURE", value="FUTURE"
- ✅ BOND: name="BOND", value="BOND"

#### MATCHING_TYPE
- ✅ CURRENT_BAR_CLOSE: name="CURRENT_BAR_CLOSE", value="CURRENT_BAR_CLOSE"
- ✅ VWAP: name="VWAP", value="VWAP"
- ✅ COUNTERPARTY_OFFER: name="COUNTERPARTY_OFFER", value="COUNTERPARTY_OFFER"
- ✅ NEXT_BAR_OPEN: name="NEXT_BAR_OPEN", value="NEXT_BAR_OPEN"
- ✅ NEXT_TICK_LAST: name="NEXT_TICK_LAST", value="NEXT_TICK_LAST"
- ✅ NEXT_TICK_BEST_OWN: name="NEXT_TICK_BEST_OWN", value="NEXT_TICK_BEST_OWN"
- ✅ NEXT_TICK_BEST_COUNTERPARTY: name="NEXT_TICK_BEST_COUNTERPARTY", value="NEXT_TICK_BEST_COUNTERPARTY"

#### ORDER_TYPE
- ✅ MARKET: name="MARKET", value="MARKET"
- ✅ LIMIT: name="LIMIT", value="LIMIT"
- ✅ ALGO: name="ALGO", value="ALGO"

#### ALGO
- ✅ TWAP: name="TWAP", value="TWAP"
- ✅ VWAP: name="VWAP", value="VWAP"

#### ORDER_STATUS
- ✅ PENDING_NEW: name="PENDING_NEW", value="PENDING_NEW"
- ✅ ACTIVE: name="ACTIVE", value="ACTIVE"
- ✅ FILLED: name="FILLED", value="FILLED"
- ✅ REJECTED: name="REJECTED", value="REJECTED"
- ✅ PENDING_CANCEL: name="PENDING_CANCEL", value="PENDING_CANCEL"
- ✅ CANCELLED: name="CANCELLED", value="CANCELLED"

#### SIDE
- ✅ BUY: name="BUY", value="BUY"
- ✅ SELL: name="SELL", value="SELL"
- ✅ FINANCING: name="FINANCING", value="FINANCING"
- ✅ MARGIN: name="MARGIN", value="MARGIN"
- ✅ CONVERT_STOCK: name="CONVERT_STOCK", value="CONVERT_STOCK"

#### POSITION_EFFECT
- ✅ OPEN: name="OPEN", value="OPEN"
- ✅ CLOSE: name="CLOSE", value="CLOSE"
- ✅ CLOSE_TODAY: name="CLOSE_TODAY", value="CLOSE_TODAY"
- ✅ EXERCISE: name="EXERCISE", value="EXERCISE"
- ✅ MATCH: name="MATCH", value="MATCH"

#### POSITION_DIRECTION
- ✅ LONG: name="LONG", value="LONG"
- ✅ SHORT: name="SHORT", value="SHORT"

#### EXC_TYPE
- ✅ USER_EXC: name="USER_EXC", value="USER_EXC"
- ✅ SYSTEM_EXC: name="SYSTEM_EXC", value="SYSTEM_EXC"
- ✅ NOTSET: name="NOTSET", value="NOTSET"

#### INSTRUMENT_TYPE
- ✅ CS: name="CS", value="CS"
- ✅ FUTURE: name="FUTURE", value="Future"
- ✅ OPTION: name="OPTION", value="Option"
- ✅ ETF: name="ETF", value="ETF"
- ✅ LOF: name="LOF", value="LOF"
- ✅ INDX: name="INDX", value="INDX"
- ✅ PUBLIC_FUND: name="PUBLIC_FUND", value="PublicFund"
- ✅ FUND: name="FUND", value="Fund"
- ✅ BOND: name="BOND", value="Bond"
- ✅ CONVERTIBLE: name="CONVERTIBLE", value="Convertible"
- ✅ SPOT: name="SPOT", value="Spot"
- ✅ REPO: name="REPO", value="Repo"
- ✅ REITs: name="REITs", value="REITs"
- ✅ FutureArbitrage: name="FutureArbitrage", value="FutureArbitrage"

#### PERSIST_MODE
- ✅ ON_CRASH: name="ON_CRASH", value="ON_CRASH"
- ✅ REAL_TIME: name="REAL_TIME", value="REAL_TIME"
- ✅ ON_NORMAL_EXIT: name="ON_NORMAL_EXIT", value="ON_NORMAL_EXIT"

#### COMMISSION_TYPE
- ✅ BY_MONEY: name="BY_MONEY", value="BY_MONEY"
- ✅ BY_VOLUME: name="BY_VOLUME", value="BY_VOLUME"

#### EXIT_CODE
- ✅ EXIT_SUCCESS: name="EXIT_SUCCESS", value="EXIT_SUCCESS"
- ✅ EXIT_USER_ERROR: name="EXIT_USER_ERROR", value="EXIT_USER_ERROR"
- ✅ EXIT_INTERNAL_ERROR: name="EXIT_INTERNAL_ERROR", value="EXIT_INTERNAL_ERROR"

#### HEDGE_TYPE
- ✅ HEDGE: name="HEDGE", value="hedge"
- ✅ SPECULATION: name="SPECULATION", value="speculation"
- ✅ ARBITRAGE: name="ARBITRAGE", value="arbitrage"

#### DAYS_CNT
- ✅ DAYS_A_YEAR: 365
- ✅ TRADING_DAYS_A_YEAR: 252

#### EXCHANGE
- ✅ XSHE: name="XSHE", value="XSHE"
- ✅ XSHG: name="XSHG", value="XSHG"
- ✅ SHFE: name="SHFE", value="SHFE"
- ✅ INE: name="INE", value="INE"
- ✅ DCE: name="DCE", value="DCE"
- ✅ CZCE: name="CZCE", value="CZCE"
- ✅ CFFEX: name="CFFEX", value="CFFEX"
- ✅ SGEX: name="SGEX", value="SGEX"
- ✅ BJSE: name="BJSE", value="BJSE"

#### TRADING_CALENDAR_TYPE
- ✅ CN_STOCK: name="CN_STOCK", value="CN_STOCK"
- ✅ HK_STOCK: name="HK_STOCK", value="HK_STOCK"
- ✅ SOUTHBOUND: name="SOUTHBOUND", value="SOUTHBOUND"
- ✅ INTER_BANK: name="INTER_BANK", value="INTERBANK"
- ✅ EXCHANGE: name="CN_STOCK", value="CN_STOCK"

#### MARKET
- ✅ CN: name="CN", value="CN"
- ✅ HK: name="HK", value="HK"

### 2. 相等性测试

- ✅ EXECUTION_PHASE.GLOBAL == EXECUTION_PHASE.GLOBAL
- ✅ EXECUTION_PHASE.GLOBAL != EXECUTION_PHASE.ON_INIT
- ✅ RUN_TYPE.BACKTEST == RUN_TYPE.BACKTEST
- ✅ RUN_TYPE.BACKTEST != RUN_TYPE.PAPER_TRADING
- ✅ DEFAULT_ACCOUNT_TYPE.STOCK == DEFAULT_ACCOUNT_TYPE.STOCK
- ✅ DEFAULT_ACCOUNT_TYPE.STOCK != DEFAULT_ACCOUNT_TYPE.FUTURE
- ✅ ORDER_TYPE.MARKET == ORDER_TYPE.MARKET
- ✅ ORDER_TYPE.MARKET != ORDER_TYPE.LIMIT
- ✅ SIDE.BUY == SIDE.BUY
- ✅ SIDE.BUY != SIDE.SELL
- ✅ POSITION_EFFECT.OPEN == POSITION_EFFECT.OPEN
- ✅ POSITION_EFFECT.OPEN != POSITION_EFFECT.CLOSE
- ✅ POSITION_DIRECTION.LONG == POSITION_DIRECTION.LONG
- ✅ POSITION_DIRECTION.LONG != POSITION_DIRECTION.SHORT
- ✅ EXCHANGE.XSHE == EXCHANGE.XSHE
- ✅ EXCHANGE.XSHE != EXCHANGE.XSHG
- ✅ MARKET.CN == MARKET.CN
- ✅ MARKET.CN != MARKET.HK

### 3. EnumRegistry.get() 测试 (通过 name 查找)

- ✅ registry.get[EXECUTION_PHASE]("GLOBAL") → EXECUTION_PHASE.GLOBAL
- ✅ registry.get[RUN_TYPE]("BACKTEST") → RUN_TYPE.BACKTEST
- ✅ registry.get[DEFAULT_ACCOUNT_TYPE]("STOCK") → DEFAULT_ACCOUNT_TYPE.STOCK
- ✅ registry.get[ORDER_TYPE]("MARKET") → ORDER_TYPE.MARKET
- ✅ registry.get[SIDE]("BUY") → SIDE.BUY
- ✅ registry.get[EXCHANGE]("XSHE") → EXCHANGE.XSHE
- ✅ registry.get[MARKET]("CN") → MARKET.CN

### 4. EnumRegistry.get() 测试 (通过 value 查找)

- ✅ registry.get[EXECUTION_PHASE]("[全局]") → EXECUTION_PHASE.GLOBAL
- ✅ registry.get[RUN_TYPE]("BACKTEST") → RUN_TYPE.BACKTEST
- ✅ registry.get[HEDGE_TYPE]("hedge") → HEDGE_TYPE.HEDGE
- ✅ registry.get[INSTRUMENT_TYPE]("Future") → INSTRUMENT_TYPE.FUTURE

### 5. Writable trait 测试

- ✅ SIDE.BUY 输出: SIDE.BUY
- ✅ ORDER_STATUS.FILLED 输出: ORDER_STATUS.FILLED
- ✅ RUN_TYPE.BACKTEST 输出: RUN_TYPE.BACKTEST
- ✅ EXCHANGE.XSHE 输出: EXCHANGE.XSHE
- ✅ MARKET.CN 输出: MARKET.CN
- ✅ HEDGE_TYPE.HEDGE 输出: HEDGE_TYPE.HEDGE
- ✅ INSTRUMENT_TYPE.FUTURE 输出: INSTRUMENT_TYPE.FUTURE

### 6. EnumRegistry 未找到测试

- ✅ registry.get[EXECUTION_PHASE]("NOT_EXIST") → None
- ✅ registry.get[RUN_TYPE]("NOT_EXIST") → None

## 测试输出

```
============================================================
RQMojo const.mojo Test Suite
============================================================

Testing EXECUTION_PHASE...
  EXECUTION_PHASE tests passed!
Testing RUN_TYPE...
  RUN_TYPE tests passed!
Testing DEFAULT_ACCOUNT_TYPE...
  DEFAULT_ACCOUNT_TYPE tests passed!
Testing MATCHING_TYPE...
  MATCHING_TYPE tests passed!
Testing ORDER_TYPE...
  ORDER_TYPE tests passed!
Testing ALGO...
  ALGO tests passed!
Testing ORDER_STATUS...
  ORDER_STATUS tests passed!
Testing SIDE...
  SIDE tests passed!
Testing POSITION_EFFECT...
  POSITION_EFFECT tests passed!
Testing POSITION_DIRECTION...
  POSITION_DIRECTION tests passed!
Testing EXC_TYPE...
  EXC_TYPE tests passed!
Testing INSTRUMENT_TYPE...
  INSTRUMENT_TYPE tests passed!
Testing PERSIST_MODE...
  PERSIST_MODE tests passed!
Testing COMMISSION_TYPE...
  COMMISSION_TYPE tests passed!
Testing EXIT_CODE...
  EXIT_CODE tests passed!
Testing HEDGE_TYPE...
  HEDGE_TYPE tests passed!
Testing DAYS_CNT...
  DAYS_CNT tests passed!
Testing EXCHANGE...
  EXCHANGE tests passed!
Testing TRADING_CALENDAR_TYPE...
  TRADING_CALENDAR_TYPE tests passed!
Testing MARKET...
  MARKET tests passed!
Testing equality...
  Equality tests passed!
Testing EnumRegistry.get()...
  EnumRegistry.get() tests passed!
Testing EnumRegistry.get() by value...
  EnumRegistry.get() by value tests passed!
Testing Writable trait (print output)...
  SIDE.BUY =  SIDE.BUY
  ORDER_STATUS.FILLED =  ORDER_STATUS.FILLED
  RUN_TYPE.BACKTEST =  RUN_TYPE.BACKTEST
  EXCHANGE.XSHE =  EXCHANGE.XSHE
  MARKET.CN =  MARKET.CN
  HEDGE_TYPE.HEDGE =  HEDGE_TYPE.HEDGE
  INSTRUMENT_TYPE.FUTURE =  INSTRUMENT_TYPE.FUTURE
  Writable trait tests passed!
Testing EnumRegistry not found cases...
  EnumRegistry not found tests passed!

============================================================
All tests passed!
============================================================
```

## 备注

- `get` 方法同时支持通过 `name` 和 `value` 查找枚举值
- 所有枚举类都实现了 `Equatable`, `ImplicitlyCopyable`, `Hashable`, `Writable` trait
- `DAYS_CNT` 是常量结构体，包含两个编译时常量
