"""
RQAlpha Mojo - Strategy Context
Ported from rqalpha/core/strategy_context.py
"""

from std.collections import Dict, Set
from rqmojo.const import INSTRUMENT_TYPE, RUN_TYPE, MATCHING_TYPE, DEFAULT_ACCOUNT_TYPE, PERSIST_MODE, RUN_TYPE_BACKTEST, MATCHING_TYPE_CURRENT_BAR_CLOSE, PERSIST_MODE_ON_CRASH, RUN_TYPE_BACKTEST, MATCHING_TYPE_CURRENT_BAR_CLOSE, PERSIST_MODE_ON_CRASH
from rqmojo.environment import Environment, Config
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.model.order import Order, buy, sell, MarketOrder, LimitOrder
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.portfolio_manager import Portfolio
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.utils.config import RQAlphaConfig, BaseConfig, ExtraConfig, ModConfig, default_extra_config, default_mod_config


@fieldwise_init
struct RunInfo(Copyable, Movable, Stringable, ImplicitlyCopyable):
    var _start_date: DateTimeDate
    var _end_date: DateTimeDate
    var _frequency: String
    var _stock_starting_cash: Float64
    var _future_starting_cash: Float64
    var _margin_multiplier: Float64
    var _run_type: RUN_TYPE
    var _matching_type: MATCHING_TYPE
    var _slippage: Float64
    var _stock_commission_multiplier: Float64
    var _futures_commission_multiplier: Float64
    
    def __str__(self) -> String:
        return "RunInfo(" + self._start_date.__str__() + " to " + self._end_date.__str__() + ")"
    
    def start_date(self) -> DateTimeDate:
        return self._start_date
    
    def end_date(self) -> DateTimeDate:
        return self._end_date
    
    def frequency(self) -> String:
        return self._frequency
    
    def stock_starting_cash(self) -> Float64:
        return self._stock_starting_cash
    
    def future_starting_cash(self) -> Float64:
        return self._future_starting_cash
    
    def margin_multiplier(self) -> Float64:
        return self._margin_multiplier
    
    def run_type(self) -> RUN_TYPE:
        return self._run_type
    
    def matching_type(self) -> MATCHING_TYPE:
        return self._matching_type
    
    def slippage(self) -> Float64:
        return self._slippage
    
    def stock_commission_multiplier(self) -> Float64:
        return self._stock_commission_multiplier
    
    def futures_commission_multiplier(self) -> Float64:
        return self._futures_commission_multiplier


def create_run_info(
    start_date: DateTimeDate,
    end_date: DateTimeDate,
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
    
    def __str__(self) -> String:
        return "Context(now=" + self.current_dt().__str__() + ", universe_size=" + String(self._universe.__len__()) + ")"
    
    def current_dt(self) -> DateTime:
        return DateTime(self._start_year, self._start_month, self._start_day, 0, 0, 0, 0)
    
    def universe(self) -> Set[String]:
        return self._universe.copy()
    
    def now(self) -> DateTime:
        return self._env.calendar_dt()
    
    def run_info(self) -> RunInfo:
        var cfg = self._env.config()
        return create_run_info(
            start_date=cfg.base__start_date.date(),
            end_date=cfg.base__end_date.date(),
            frequency=cfg.base__frequency,
            stock_starting_cash=100000.0,
            future_starting_cash=0.0,
            run_type=cfg.base__run_type
        )
    
    def portfolio(self) -> Portfolio:
        return self._portfolio
    
    def stock_account(self) -> Account:
        return self._stock_account
    
    def future_account(self) -> Account:
        return self._future_account
    
    def config(self) -> RQAlphaConfig:
        return self._config
    
    def get_state(self) -> String:
        var result = "STATE_START\n"
        for key in self._state_data.keys():
            try:
                var value = self._state_data[key]
                result += key + "=" + value + "\n"
            except:
                pass
        result += "STATE_END"
        return result
    
    def set_state(mut self, state: String) -> None:
        var lines = state.split("\n")
        for line in lines:
            if line == "STATE_START" or line == "STATE_END":
                continue
            var parts = line.split("=", maxsplit=1)
            if len(parts) == 2:
                var key_str = String(parts[0])
                var val_str = String(parts[1])
                self._state_data[key_str] = val_str
    
    def get_instrument(self, order_book_id: String) -> Instrument:
        return self._data_proxy.get_instrument(order_book_id)
    
    def get_bar(self, order_book_id: String) -> BarObject:
        return self._data_proxy.get_bar(order_book_id, self.current_dt())
    
    def get_tick(self, order_book_id: String) -> TickObject:
        return self._data_proxy.get_tick(order_book_id, self.current_dt())
    
    def is_suspended(self, order_book_id: String) -> Bool:
        return self._data_proxy.is_suspended(order_book_id, self.current_dt())
    
    def order_shares(self, order_book_id: String, quantity: Int) -> Order:
        return buy(order_book_id, quantity)
    
    def order_percent(self, order_book_id: String, percent: Float64) -> Order:
        return buy(order_book_id, 100)
    
    def order_target_value(self, order_book_id: String, target_value: Float64) -> Order:
        return buy(order_book_id, 100)
    
    def cancel_order(self, order_id: Int) -> None:
        pass
    
    def update_universe(mut self, var universe: Set[String]) -> None:
        self._universe = universe^
    
    def subscribe(mut self, order_book_id: String) -> None:
        self._universe.add(order_book_id)
    
    def unsubscribe(mut self, order_book_id: String) -> None:
        self._universe.discard(order_book_id)


def create_strategy_context(var env: Environment, var data_proxy: DataProxy) -> StrategyContext:
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
        persist_mode=PERSIST_MODE.ON_CRASH,
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
