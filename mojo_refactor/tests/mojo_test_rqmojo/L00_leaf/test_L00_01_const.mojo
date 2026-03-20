from rqmojo.const import (
    EXECUTION_PHASE, RUN_TYPE, DEFAULT_ACCOUNT_TYPE, MATCHING_TYPE,
    ORDER_TYPE, ALGO, ORDER_STATUS, SIDE, POSITION_EFFECT,
    POSITION_DIRECTION, EXC_TYPE, INSTRUMENT_TYPE, PERSIST_MODE,
    COMMISSION_TYPE, EXIT_CODE, HEDGE_TYPE, DAYS_CNT, EXCHANGE,
    TRADING_CALENDAR_TYPE, MARKET
)

@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_execution_phase(mut self):
        var global_phase = EXECUTION_PHASE.GLOBAL
        self.check(global_phase.name == "GLOBAL", "EXECUTION_PHASE.GLOBAL name")
        
        var on_init = EXECUTION_PHASE.ON_INIT
        self.check(on_init.name == "ON_INIT", "EXECUTION_PHASE.ON_INIT name")
        
        var before_trading = EXECUTION_PHASE.BEFORE_TRADING
        self.check(before_trading.name == "BEFORE_TRADING", "EXECUTION_PHASE.BEFORE_TRADING name")
        
        var open_auction = EXECUTION_PHASE.OPEN_AUCTION
        self.check(open_auction.name == "OPEN_AUCTION", "EXECUTION_PHASE.OPEN_AUCTION name")
        
        var on_bar = EXECUTION_PHASE.ON_BAR
        self.check(on_bar.name == "ON_BAR", "EXECUTION_PHASE.ON_BAR name")
        
        var on_tick = EXECUTION_PHASE.ON_TICK
        self.check(on_tick.name == "ON_TICK", "EXECUTION_PHASE.ON_TICK name")
        
        var after_trading = EXECUTION_PHASE.AFTER_TRADING
        self.check(after_trading.name == "AFTER_TRADING", "EXECUTION_PHASE.AFTER_TRADING name")
        
        var finalized = EXECUTION_PHASE.FINALIZED
        self.check(finalized.name == "FINALIZED", "EXECUTION_PHASE.FINALIZED name")
        
        var scheduled = EXECUTION_PHASE.SCHEDULED
        self.check(scheduled.name == "SCHEDULED", "EXECUTION_PHASE.SCHEDULED name")

    fn test_run_type(mut self):
        var backtest = RUN_TYPE.BACKTEST
        self.check(backtest.value == "BACKTEST", "RUN_TYPE.BACKTEST value")
        self.check(backtest.name == "BACKTEST", "RUN_TYPE.BACKTEST name")
        
        var paper_trading = RUN_TYPE.PAPER_TRADING
        self.check(paper_trading.value == "PAPER_TRADING", "RUN_TYPE.PAPER_TRADING value")
        
        var live_trading = RUN_TYPE.LIVE_TRADING
        self.check(live_trading.value == "LIVE_TRADING", "RUN_TYPE.LIVE_TRADING value")

    fn test_default_account_type(mut self):
        var stock = DEFAULT_ACCOUNT_TYPE.STOCK
        self.check(stock.value == "STOCK", "DEFAULT_ACCOUNT_TYPE.STOCK value")
        
        var future = DEFAULT_ACCOUNT_TYPE.FUTURE
        self.check(future.value == "FUTURE", "DEFAULT_ACCOUNT_TYPE.FUTURE value")
        
        var bond = DEFAULT_ACCOUNT_TYPE.BOND
        self.check(bond.value == "BOND", "DEFAULT_ACCOUNT_TYPE.BOND value")

    fn test_matching_type(mut self):
        var current_bar_close = MATCHING_TYPE.CURRENT_BAR_CLOSE
        self.check(current_bar_close.value == "CURRENT_BAR_CLOSE", "MATCHING_TYPE.CURRENT_BAR_CLOSE value")
        
        var vwap = MATCHING_TYPE.VWAP
        self.check(vwap.value == "VWAP", "MATCHING_TYPE.VWAP value")
        
        var counterparty_offer = MATCHING_TYPE.COUNTERPARTY_OFFER
        self.check(counterparty_offer.value == "COUNTERPARTY_OFFER", "MATCHING_TYPE.COUNTERPARTY_OFFER value")
        
        var next_bar_open = MATCHING_TYPE.NEXT_BAR_OPEN
        self.check(next_bar_open.value == "NEXT_BAR_OPEN", "MATCHING_TYPE.NEXT_BAR_OPEN value")
        
        var next_tick_last = MATCHING_TYPE.NEXT_TICK_LAST
        self.check(next_tick_last.value == "NEXT_TICK_LAST", "MATCHING_TYPE.NEXT_TICK_LAST value")
        
        var next_tick_best_own = MATCHING_TYPE.NEXT_TICK_BEST_OWN
        self.check(next_tick_best_own.value == "NEXT_TICK_BEST_OWN", "MATCHING_TYPE.NEXT_TICK_BEST_OWN value")
        
        var next_tick_best_counterparty = MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY
        self.check(next_tick_best_counterparty.value == "NEXT_TICK_BEST_COUNTERPARTY", "MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY value")

    fn test_order_type(mut self):
        var market = ORDER_TYPE.MARKET
        self.check(market.value == "MARKET", "ORDER_TYPE.MARKET value")
        
        var limit = ORDER_TYPE.LIMIT
        self.check(limit.value == "LIMIT", "ORDER_TYPE.LIMIT value")
        
        var algo = ORDER_TYPE.ALGO
        self.check(algo.value == "ALGO", "ORDER_TYPE.ALGO value")

    fn test_algo(mut self):
        var twap = ALGO.TWAP
        self.check(twap.value == "TWAP", "ALGO.TWAP value")
        
        var vwap = ALGO.VWAP
        self.check(vwap.value == "VWAP", "ALGO.VWAP value")

    fn test_order_status(mut self):
        var pending_new = ORDER_STATUS.PENDING_NEW
        self.check(pending_new.value == "PENDING_NEW", "ORDER_STATUS.PENDING_NEW value")
        
        var active = ORDER_STATUS.ACTIVE
        self.check(active.value == "ACTIVE", "ORDER_STATUS.ACTIVE value")
        
        var filled = ORDER_STATUS.FILLED
        self.check(filled.value == "FILLED", "ORDER_STATUS.FILLED value")
        
        var rejected = ORDER_STATUS.REJECTED
        self.check(rejected.value == "REJECTED", "ORDER_STATUS.REJECTED value")
        
        var pending_cancel = ORDER_STATUS.PENDING_CANCEL
        self.check(pending_cancel.value == "PENDING_CANCEL", "ORDER_STATUS.PENDING_CANCEL value")
        
        var cancelled = ORDER_STATUS.CANCELLED
        self.check(cancelled.value == "CANCELLED", "ORDER_STATUS.CANCELLED value")

    fn test_side(mut self):
        var buy = SIDE.BUY
        self.check(buy.value == "BUY", "SIDE.BUY value")
        self.check(buy.name == "BUY", "SIDE.BUY name")
        
        var sell = SIDE.SELL
        self.check(sell.value == "SELL", "SIDE.SELL value")
        
        var financing = SIDE.FINANCING
        self.check(financing.value == "FINANCING", "SIDE.FINANCING value")
        
        var margin = SIDE.MARGIN
        self.check(margin.value == "MARGIN", "SIDE.MARGIN value")
        
        var convert_stock = SIDE.CONVERT_STOCK
        self.check(convert_stock.value == "CONVERT_STOCK", "SIDE.CONVERT_STOCK value")

    fn test_position_effect(mut self):
        var open_val = POSITION_EFFECT.OPEN
        self.check(open_val.value == "OPEN", "POSITION_EFFECT.OPEN value")
        
        var close = POSITION_EFFECT.CLOSE
        self.check(close.value == "CLOSE", "POSITION_EFFECT.CLOSE value")
        
        var close_today = POSITION_EFFECT.CLOSE_TODAY
        self.check(close_today.value == "CLOSE_TODAY", "POSITION_EFFECT.CLOSE_TODAY value")
        
        var exercise = POSITION_EFFECT.EXERCISE
        self.check(exercise.value == "EXERCISE", "POSITION_EFFECT.EXERCISE value")
        
        var match_val = POSITION_EFFECT.MATCH
        self.check(match_val.value == "MATCH", "POSITION_EFFECT.MATCH value")

    fn test_position_direction(mut self):
        var long_val = POSITION_DIRECTION.LONG
        self.check(long_val.value == "LONG", "POSITION_DIRECTION.LONG value")
        
        var short_val = POSITION_DIRECTION.SHORT
        self.check(short_val.value == "SHORT", "POSITION_DIRECTION.SHORT value")

    fn test_exc_type(mut self):
        var user_exc = EXC_TYPE.USER_EXC
        self.check(user_exc.value == "USER_EXC", "EXC_TYPE.USER_EXC value")
        
        var system_exc = EXC_TYPE.SYSTEM_EXC
        self.check(system_exc.value == "SYSTEM_EXC", "EXC_TYPE.SYSTEM_EXC value")
        
        var notset = EXC_TYPE.NOTSET
        self.check(notset.value == "NOTSET", "EXC_TYPE.NOTSET value")

    fn test_instrument_type(mut self):
        var cs = INSTRUMENT_TYPE.CS
        self.check(cs.value == "CS", "INSTRUMENT_TYPE.CS value")
        
        var future = INSTRUMENT_TYPE.FUTURE
        self.check(future.value == "Future", "INSTRUMENT_TYPE.FUTURE value")
        
        var option = INSTRUMENT_TYPE.OPTION
        self.check(option.value == "Option", "INSTRUMENT_TYPE.OPTION value")
        
        var etf = INSTRUMENT_TYPE.ETF
        self.check(etf.value == "ETF", "INSTRUMENT_TYPE.ETF value")
        
        var lof = INSTRUMENT_TYPE.LOF
        self.check(lof.value == "LOF", "INSTRUMENT_TYPE.LOF value")
        
        var indx = INSTRUMENT_TYPE.INDX
        self.check(indx.value == "INDX", "INSTRUMENT_TYPE.INDX value")
        
        var public_fund = INSTRUMENT_TYPE.PUBLIC_FUND
        self.check(public_fund.value == "PublicFund", "INSTRUMENT_TYPE.PUBLIC_FUND value")
        
        var fund = INSTRUMENT_TYPE.FUND
        self.check(fund.value == "Fund", "INSTRUMENT_TYPE.FUND value")
        
        var bond = INSTRUMENT_TYPE.BOND
        self.check(bond.value == "Bond", "INSTRUMENT_TYPE.BOND value")
        
        var convertible = INSTRUMENT_TYPE.CONVERTIBLE
        self.check(convertible.value == "Convertible", "INSTRUMENT_TYPE.CONVERTIBLE value")
        
        var spot = INSTRUMENT_TYPE.SPOT
        self.check(spot.value == "Spot", "INSTRUMENT_TYPE.SPOT value")
        
        var repo = INSTRUMENT_TYPE.REPO
        self.check(repo.value == "Repo", "INSTRUMENT_TYPE.REPO value")
        
        var reits = INSTRUMENT_TYPE.REITs
        self.check(reits.value == "REITs", "INSTRUMENT_TYPE.REITs value")

    fn test_persist_mode(mut self):
        var on_crash = PERSIST_MODE.ON_CRASH
        self.check(on_crash.value == "ON_CRASH", "PERSIST_MODE.ON_CRASH value")
        
        var real_time = PERSIST_MODE.REAL_TIME
        self.check(real_time.value == "REAL_TIME", "PERSIST_MODE.REAL_TIME value")
        
        var on_normal_exit = PERSIST_MODE.ON_NORMAL_EXIT
        self.check(on_normal_exit.value == "ON_NORMAL_EXIT", "PERSIST_MODE.ON_NORMAL_EXIT value")

    fn test_commission_type(mut self):
        var by_money = COMMISSION_TYPE.BY_MONEY
        self.check(by_money.value == "BY_MONEY", "COMMISSION_TYPE.BY_MONEY value")
        
        var by_volume = COMMISSION_TYPE.BY_VOLUME
        self.check(by_volume.value == "BY_VOLUME", "COMMISSION_TYPE.BY_VOLUME value")

    fn test_exit_code(mut self):
        var exit_success = EXIT_CODE.EXIT_SUCCESS
        self.check(exit_success.value == "EXIT_SUCCESS", "EXIT_CODE.EXIT_SUCCESS value")
        
        var exit_user_error = EXIT_CODE.EXIT_USER_ERROR
        self.check(exit_user_error.value == "EXIT_USER_ERROR", "EXIT_CODE.EXIT_USER_ERROR value")
        
        var exit_internal_error = EXIT_CODE.EXIT_INTERNAL_ERROR
        self.check(exit_internal_error.value == "EXIT_INTERNAL_ERROR", "EXIT_CODE.EXIT_INTERNAL_ERROR value")

    fn test_hedge_type(mut self):
        var hedge = HEDGE_TYPE.HEDGE
        self.check(hedge.value == "hedge", "HEDGE_TYPE.HEDGE value")
        
        var speculation = HEDGE_TYPE.SPECULATION
        self.check(speculation.value == "speculation", "HEDGE_TYPE.SPECULATION value")
        
        var arbitrage = HEDGE_TYPE.ARBITRAGE
        self.check(arbitrage.value == "arbitrage", "HEDGE_TYPE.ARBITRAGE value")

    fn test_days_cnt(mut self):
        self.check(DAYS_CNT.DAYS_A_YEAR == 365, "DAYS_CNT.DAYS_A_YEAR value")
        self.check(DAYS_CNT.TRADING_DAYS_A_YEAR == 252, "DAYS_CNT.TRADING_DAYS_A_YEAR value")

    fn test_exchange(mut self):
        var xshe = EXCHANGE.XSHE
        self.check(xshe.value == "XSHE", "EXCHANGE.XSHE value")
        
        var xshg = EXCHANGE.XSHG
        self.check(xshg.value == "XSHG", "EXCHANGE.XSHG value")
        
        var shfe = EXCHANGE.SHFE
        self.check(shfe.value == "SHFE", "EXCHANGE.SHFE value")
        
        var ine = EXCHANGE.INE
        self.check(ine.value == "INE", "EXCHANGE.INE value")
        
        var dce = EXCHANGE.DCE
        self.check(dce.value == "DCE", "EXCHANGE.DCE value")
        
        var czce = EXCHANGE.CZCE
        self.check(czce.value == "CZCE", "EXCHANGE.CZCE value")
        
        var cffex = EXCHANGE.CFFEX
        self.check(cffex.value == "CFFEX", "EXCHANGE.CFFEX value")
        
        var sgex = EXCHANGE.SGEX
        self.check(sgex.value == "SGEX", "EXCHANGE.SGEX value")
        
        var bjse = EXCHANGE.BJSE
        self.check(bjse.value == "BJSE", "EXCHANGE.BJSE value")

    fn test_trading_calendar_type(mut self):
        var cn_stock = TRADING_CALENDAR_TYPE.CN_STOCK
        self.check(cn_stock.value == "CN_STOCK", "TRADING_CALENDAR_TYPE.CN_STOCK value")
        
        var hk_stock = TRADING_CALENDAR_TYPE.HK_STOCK
        self.check(hk_stock.value == "HK_STOCK", "TRADING_CALENDAR_TYPE.HK_STOCK value")
        
        var southbound = TRADING_CALENDAR_TYPE.SOUTHBOUND
        self.check(southbound.value == "SOUTHBOUND", "TRADING_CALENDAR_TYPE.SOUTHBOUND value")
        
        var inter_bank = TRADING_CALENDAR_TYPE.INTER_BANK
        self.check(inter_bank.value == "INTERBANK", "TRADING_CALENDAR_TYPE.INTER_BANK value")

    fn test_market(mut self):
        var cn = MARKET.CN
        self.check(cn.value == "CN", "MARKET.CN value")
        
        var hk = MARKET.HK
        self.check(hk.value == "HK", "MARKET.HK value")

    fn test_equality(mut self):
        var buy1 = SIDE.BUY
        var buy2 = SIDE.BUY
        var sell = SIDE.SELL
        
        self.check(buy1 == buy2, "SIDE.BUY == SIDE.BUY")
        self.check(buy1 != sell, "SIDE.BUY != SIDE.SELL")

    fn test_string_representation(mut self) raises:
        var buy = SIDE.BUY
        self.check(String.write(buy) == "BUY", "SIDE.BUY string representation")
        
        var xshe = EXCHANGE.XSHE
        self.check(String.write(xshe) == "XSHE", "EXCHANGE.XSHE string representation")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L00_01_const Module Tests")
        print("=" * 60)
        
        self.test_execution_phase()
        self.test_run_type()
        self.test_default_account_type()
        self.test_matching_type()
        self.test_order_type()
        self.test_algo()
        self.test_order_status()
        self.test_side()
        self.test_position_effect()
        self.test_position_direction()
        self.test_exc_type()
        self.test_instrument_type()
        self.test_persist_mode()
        self.test_commission_type()
        self.test_exit_code()
        self.test_hedge_type()
        self.test_days_cnt()
        self.test_exchange()
        self.test_trading_calendar_type()
        self.test_market()
        self.test_equality()
        self.test_string_representation()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
