"""
RQAlpha Mojo - Strategy Context
Ported from rqalpha/core/strategy_context.py
"""

from collections import Dict, Set
from rqmojo.const import INSTRUMENT_TYPE, RUN_TYPE, MATCHING_TYPE, DEFAULT_ACCOUNT_TYPE, PERSIST_MODE, RUN_TYPE_BACKTEST, MATCHING_TYPE_CURRENT_BAR_CLOSE, PERSIST_MODE_ON_CRASH, RUN_TYPE_BACKTEST, MATCHING_TYPE_CURRENT_BAR_CLOSE, PERSIST_MODE_ON_CRASH
from rqmojo.environment import Environment, Config
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.model.order import Order, buy, sell, MarketOrder, LimitOrder
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.portfolio_manager import Portfolio
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.utils.config import RQAlphaConfig, BaseConfig, ExtraConfig, ModConfig, default_extra_config, default_mod_config


@fieldwise_init
struct RunInfo(Copyable, Movable, Stringable, ImplicitlyCopyable):
    var _start_date: Date
    var _end_date: Date
    var _frequency: String
    var _stock_starting_cash: Float64
    var _future_starting_cash: Float64
    var _margin_multiplier: Float64
    var _run_type: RUN_TYPE
    var _matching_type: MATCHING_TYPE
    var _slippage: Float64
    var _stock_commission_multiplier: Float64
    var _futures_commission_multiplier: Float64
    
    fn __str__(self) -> String:
        return "RunInfo(" + self._start_date.__str__() + " to " + self._end_date.__str__() + ")"
    
    fn start_date(self) -> Date:
        return self._start_date
    
    fn end_date(self) -> Date:
        return self._end_date
    
    fn frequency(self) -> String:
        return self._frequency
    
    fn stock_starting_cash(self) -> Float64:
        return self._stock_starting_cash
    
    fn future_starting_cash(self) -> Float64:
        return self._future_starting_cash
    
    fn margin_multiplier(self) -> Float64:
        return self._margin_multiplier
    
    fn run_type(self) -> RUN_TYPE:
        return self._run_type
    
    fn matching_type(self) -> MATCHING_TYPE:
        return self._matching_type
    
    fn slippage(self) -> Float64:
        return self._slippage
    
    fn stock_commission_multiplier(self) -> Float64:
        return self._stock_commission_multiplier
    
    fn futures_commission_multiplier(self) -> Float64:
        return self._futures_commission_multiplier


fn create_run_info(
    start_date: Date,
    end_date: Date,
    frequency: String,
    stock_starting_cash: Float64 = 0.0,
    future_starting_cash: Float64 = 0.0,
    margin_multiplier: Float64 = 1.0,
    run_type: RUN_TYPE = RUN_TYPE_BACKTEST,
    matching_type: MATCHING_TYPE = MATCHING_TYPE_CURRENT_BAR_CLOSE,
    slippage: Float64 = 0.0,
    stock_commission_multiplier: Float64 = 0.0003,
    futures_commission_multiplier: Float64 = 0.0001
) -> RunInfo:
    return RunInfo(
        _start_date=start_date,
        _end_date=end_date,
        _frequency=frequency,
        _stock_starting_cash=stock_starting_cash,
        _future_starting_cash=future_starting_cash,
        _margin_multiplier=margin_multiplier,
        _run_type=run_type,
        _matching_type=matching_type,
        _slippage=slippage,
        _stock_commission_multiplier=stock_commission_multiplier,
        _futures_commission_multiplier=futures_commission_multiplier
    )


@fieldwise_init
struct StrategyContext(Movable):
    var _start_year: Int
    var _start_month: Int
    var _start_day: Int
    var _env: Environment
    var _data_proxy: DataProxy
    var _universe: Set[String]
    var _portfolio: Portfolio
    var _stock_account: Account
    var _future_account: Account
    var _config: RQAlphaConfig
    var _state_data: Dict[String, String]
    
    fn __str__(self) -> String:
        return "Context(now=" + self.current_dt().__str__() + ", universe_size=" + String(self._universe.__len__()) + ")"
    
    fn current_dt(self) -> DateTime:
        return DateTime(self._start_year, self._start_month, self._start_day, 0, 0, 0, 0)
    
    fn universe(self) -> Set[String]:
        return self._universe.copy()
    
    fn now(self) -> DateTime:
        return self._env.calendar_dt()
    
    fn run_info(self) -> RunInfo:
        var cfg = self._env.config()
        return create_run_info(
            start_date=cfg.base__start_date.date(),
            end_date=cfg.base__end_date.date(),
            frequency=cfg.base__frequency,
            stock_starting_cash=100000.0,
            future_starting_cash=0.0,
            run_type=cfg.base__run_type
        )
    
    fn portfolio(self) -> Portfolio:
        return self._portfolio
    
    fn stock_account(self) -> Account:
        return self._stock_account
    
    fn future_account(self) -> Account:
        return self._future_account
    
    fn config(self) -> RQAlphaConfig:
        return self._config
    
    fn get_state(self) -> String:
        var result = "STATE_START\n"
        for key in self._state_data.keys():
            try:
                var value = self._state_data[key]
                result += key + "=" + value + "\n"
            except:
                pass
        result += "STATE_END"
        return result
    
    fn set_state(mut self, state: String) -> None:
        var lines = state.split("\n")
        for line in lines:
            if line == "STATE_START" or line == "STATE_END":
                continue
            var parts = line.split("=", maxsplit=1)
            if len(parts) == 2:
                var key_str = String(parts[0])
                var val_str = String(parts[1])
                self._state_data[key_str] = val_str
    
    fn get_instrument(self, order_book_id: String) -> Instrument:
        return self._data_proxy.get_instrument(order_book_id)
    
    fn get_bar(self, order_book_id: String) -> BarObject:
        return self._data_proxy.get_bar(order_book_id, self.current_dt())
    
    fn get_tick(self, order_book_id: String) -> TickObject:
        return self._data_proxy.get_tick(order_book_id, self.current_dt())
    
    fn is_suspended(self, order_book_id: String) -> Bool:
        return self._data_proxy.is_suspended(order_book_id, self.current_dt())
    
    fn order_shares(self, order_book_id: String, quantity: Int) -> Order:
        return buy(order_book_id, quantity)
    
    fn order_percent(self, order_book_id: String, percent: Float64) -> Order:
        return buy(order_book_id, 100)
    
    fn order_target_value(self, order_book_id: String, target_value: Float64) -> Order:
        return buy(order_book_id, 100)
    
    fn cancel_order(self, order_id: Int) -> None:
        pass
    
    fn update_universe(mut self, var universe: Set[String]) -> None:
        self._universe = universe^
    
    fn subscribe(mut self, order_book_id: String) -> None:
        self._universe.add(order_book_id)
    
    fn unsubscribe(mut self, order_book_id: String) -> None:
        self._universe.discard(order_book_id)


fn create_strategy_context(var env: Environment, var data_proxy: DataProxy) -> StrategyContext:
    var start = env.start_date()
    var universe = Set[String]()
    var portfolio = Portfolio(
        total_value=100000.0,
        daily_pnl=0.0,
        total_pnl=0.0,
        annualized_returns=0.0,
        unit_net_value=1.0,
        cash=100000.0,
        positions_count=0,
        start_cash=100000.0
    )
    var stock_account = create_stock_account(100000.0)
    var future_account = create_future_account(0.0)
    var env_config = env.config()
    var base_cfg = BaseConfig(
        start_date=env_config.base__start_date,
        end_date=env_config.base__end_date,
        frequency=env_config.base__frequency,
        run_type=env_config.base__run_type,
        data_bundle_path="~/.rqalpha/bundle",
        strategy_file="",
        persist_mode=PERSIST_MODE_ON_CRASH,
        initial_cash=100000.0,
        rqdatac_uri=""
    )
    var config = RQAlphaConfig(
        base=base_cfg,
        extra=default_extra_config(),
        mod=default_mod_config()
    )
    var state_data = Dict[String, String]()
    
    return StrategyContext(
        _start_year=start.year,
        _start_month=start.month,
        _start_day=start.day,
        _env=env^,
        _data_proxy=data_proxy^,
        _universe=universe^,
        _portfolio=portfolio,
        _stock_account=stock_account^,
        _future_account=future_account^,
        _config=config^,
        _state_data=state_data^
    )
