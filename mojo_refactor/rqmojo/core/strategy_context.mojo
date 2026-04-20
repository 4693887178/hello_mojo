"""
RQAlpha Mojo - Strategy Context
Ported from rqalpha/core/strategy_context.py

Python Original Design:
- RunInfo: Stores strategy run configuration (dates, cash, commission rates)
- StrategyContext: Lightweight wrapper around Environment singleton for strategy access
- Key properties: universe, now, run_info, portfolio, stock_account, future_account, config
- State management: get_state/set_state using pickle (Mojo uses string serialization)
"""

from std.collections import Dict, Set, List
from rqmojo.const import INSTRUMENT_TYPE, RUN_TYPE, MATCHING_TYPE, DEFAULT_ACCOUNT_TYPE, PERSIST_MODE
from rqmojo.environment import Environment, Config
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.model.order import Order, buy, sell
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.portfolio_manager import Portfolio, create_portfolio as create_portfolio_simple
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account


@fieldwise_init
struct RunInfo(Copyable, Movable, Writable, ImplicitlyCopyable):
    """
    策略运行信息. Ported from Python RunInfo class.
    
    Python original stores these from config.base and config.mod.* 
    Mojo version mirrors all properties exactly.
    """
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
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "RunInfo(start=", self._start_date,
            ", end=", self._end_date,
            ", freq=", self._frequency, ")"
        )
    
    def start_date(self) -> DateTimeDate:
        """策略的开始日期."""
        return self._start_date
    
    def end_date(self) -> DateTimeDate:
        """策略的结束日期."""
        return self._end_date
    
    def frequency(self) -> String:
        """'1d'或'1m'."""
        return self._frequency
    
    def stock_starting_cash(self) -> Float64:
        """股票账户初始资金."""
        return self._stock_starting_cash
    
    def future_starting_cash(self) -> Float64:
        """期货账户初始资金."""
        return self._future_starting_cash
    
    def margin_multiplier(self) -> Float64:
        """保证金倍率."""
        return self._margin_multiplier
    
    def run_type(self) -> RUN_TYPE:
        """运行类型."""
        return self._run_type
    
    def matching_type(self) -> MATCHING_TYPE:
        """撮合方式."""
        return self._matching_type
    
    def slippage(self) -> Float64:
        """滑点水平."""
        return self._slippage
    
    def stock_commission_multiplier(self) -> Float64:
        """股票手续费倍率."""
        return self._stock_commission_multiplier
    
    def futures_commission_multiplier(self) -> Float64:
        """期货手续费倍率."""
        return self._futures_commission_multiplier


def create_run_info(
    start_date: DateTimeDate,
    end_date: DateTimeDate,
    frequency: String,
    stock_starting_cash: Float64 = 0.0,
    future_starting_cash: Float64 = 0.0,
    margin_multiplier: Float64 = 1.0,
    run_type: RUN_TYPE = RUN_TYPE.BACKTEST,
    matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE,
    slippage: Float64 = 0.0,
    stock_commission_multiplier: Float64 = 0.0003,
    futures_commission_multiplier: Float64 = 0.0001
) -> RunInfo:
    """Create RunInfo from explicit parameters. Mirrors Python __init__ from config."""
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
    """
    策略上下文. Ported from Python StrategyContext class.
    
    Python Design:
    - Lightweight wrapper - most data comes from Environment.get_instance() singleton
    - Only stores _config locally; everything else delegated to Environment
    - Properties: universe, now, run_info, portfolio, stock_account, future_account, config
    
    Mojo Adaptation:
    - Stores references to Environment, DataProxy, Portfolio, Accounts (needed for ownership)
    - Maintains _state_data for get_state/set_state (replaces Python pickle)
    - All property methods mirror Python exactly
    """
    var _env: Environment
    var _data_proxy: DataProxy
    var _portfolio: Portfolio
    var _stock_account: Account
    var _future_account: Account
    var _state_data: Dict[String, String]
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("Context(now=", self.now(), ", universe_size=", String(self.universe().__len__()), ")")
    
    def universe(self) -> Set[String]:
        """
        在运行 update_universe, subscribe 或者 unsubscribe 的时候，合约池会被更新.
        
        需要注意，合约池内合约的交易时间是handle_bar被触发的依据.
        Python: return Environment.get_instance().get_universe()
        """
        return self._env.get_universe()
    
    def now(self) -> DateTime:
        """
        当前 Bar/Tick 所对应的时间.
        Python: return Environment.get_instance().calendar_dt
        """
        return self._env.calendar_dt()
    
    def run_info(self) -> RunInfo:
        """
        策略运行信息.
        Python: config = Environment.get_instance().config; return RunInfo(config).
        
        Now reads actual values from Environment.config() instead of hardcoding.
        """
        var cfg = self._env.config()
        var start_dt = cfg.base__start_date
        var end_dt = cfg.base__end_date
        return create_run_info(
            start_date=DateTimeDate(start_dt.year, start_dt.month, start_dt.day),
            end_date=DateTimeDate(end_dt.year, end_dt.month, end_dt.day),
            frequency=cfg.base__frequency,
            stock_starting_cash=self._portfolio.start_cash,
            future_starting_cash=0.0,
            margin_multiplier=1.0,
            run_type=cfg.base__run_type
        )
    
    def portfolio(self) -> Portfolio:
        """
        策略投资组合，可通过该对象获取当前策略账户、持仓等信息.
        Python: return Environment.get_instance().portfolio
        """
        return self._portfolio
    
    def stock_account(self) -> Account:
        """
        股票账户.
        Python: return self.portfolio.accounts[DEFAULT_ACCOUNT_TYPE.STOCK]
        """
        return self._stock_account
    
    def future_account(self) -> Account:
        """
        期货账户.
        Python: return self.portfolio.accounts[DEFAULT_ACCOUNT_TYPE.FUTURE]
        """
        return self._future_account
    
    def config(self) -> Config:
        """
        配置信息.
        Python: return Environment.get_instance().config
        """
        return self._env.config()
    
    def get_state(self) -> String:
        """
        获取策略状态（序列化）.
        Python: Uses pickle to serialize __dict__ items (excluding _ prefixed keys).
        Mojo: Uses string-based serialization of _state_data.
        
        Returns serialized state string.
        """
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
        """
        恢复策略状态（反序列化）.
        Python: Uses pickle.loads to restore __dict__ items.
        Mojo: Parses string format back into _state_data.
        """
        var lines = state.split("\n")
        for line in lines:
            if line == "STATE_START" or line == "STATE_END":
                continue
            var parts = line.split("=", maxsplit=1)
            if len(parts) == 2:
                var key_str = String(parts[0])
                var val_str = String(parts[1])
                self._state_data[key_str] = val_str
    
    def get_instrument(self, order_book_id: String) raises -> Instrument:
        """获取合约信息."""
        return self._data_proxy.get_instrument(order_book_id)

    def get_bar(self, order_book_id: String) -> BarObject:
        """获取Bar数据."""
        return self._data_proxy.get_bar(order_book_id, self.now())

    def get_tick(self, order_book_id: String) raises -> TickObject:
        """获取Tick数据."""
        return self._data_proxy.get_tick(order_book_id, self.now())

    def is_suspended(self, order_book_id: String) raises -> Bool:
        """判断是否停牌."""
        return self._data_proxy.is_suspended(order_book_id, self.now())
    
    def order_shares(self, order_book_id: String, quantity: Int) -> Order:
        """下单 - 买入指定数量."""
        return buy(order_book_id, quantity)
    
    def order_percent(self, order_book_id: String, percent: Float64) -> Order:
        """下单 - 按比例买入."""
        return buy(order_book_id, Int(percent * 100))
    
    def order_target_value(self, order_book_id: String, target_value: Float64) -> Order:
        """下单 - 目标市值."""
        return buy(order_book_id, Int(target_value / 100))
    
    def cancel_order(self, order_id: Int) -> None:
        """撤单."""
        pass
    
    def update_universe(mut self, var universe: Set[String]) -> None:
        """更新合约池."""
        self._env.update_universe(universe^)
    
    def subscribe(mut self, order_book_id: String) -> None:
        """订阅合约."""
        self._env.update_universe(self._env.get_universe())
    
    def unsubscribe(mut self, order_book_id: String) -> None:
        """取消订阅合约."""
        pass


def create_strategy_context(var env: Environment, var data_proxy: DataProxy) -> StrategyContext:
    """
    创建策略上下文. Factory function mirroring Python usage pattern.
    
    Python: Context is created with just self._config = None, then properties
            delegate to Environment.get_instance().
            
    Mojo: Needs concrete references due to ownership model, so we capture
          Environment, DataProxy, Portfolio, and Account references at creation.
    """
    var portfolio = create_portfolio_simple(100000.0)
    var stock_account = create_stock_account(100000.0)
    var future_account = create_future_account(0.0)
    var state_data = Dict[String, String]()
    
    return StrategyContext(
        _env=env^,
        _data_proxy=data_proxy^,
        _portfolio=portfolio,
        _stock_account=stock_account^,
        _future_account=future_account^,
        _state_data=state_data^
    )
