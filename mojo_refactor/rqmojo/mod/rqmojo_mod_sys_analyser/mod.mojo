"""
RQAlpha Mojo - Analyser Mod
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/mod.py

This module provides portfolio analysis functionality including:
- Benchmark portfolio calculation
- Performance metrics calculation
- Trade/order/daily data collection
- Portfolio/account/position record generation
- State serialization (get_state/set_state)
- Pressure test periods
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE, EXIT_CODE, INSTRUMENT_TYPE, POSITION_DIRECTION, TRADING_CALENDAR_TYPE
from rqmojo.interface import ModInterface
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.portfolio.position import Position
from rqmojo.portfolio.account import Account
from rqmojo.mod.rqmojo_mod_sys_analyser.plot_store import PlotStore, create_plot_store
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import calculate_max_drawdown, max_ddd
from std.collections import Dict, List, Optional, Set
from std.math import sqrt, pow, abs


@fieldwise_init
struct BenchmarkPortfolio(Copyable, Movable, ImplicitlyCopyable, Writable):
    var date: DateTime
    var unit_net_value: Float64
    var total_value: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BenchmarkPortfolio(date=", String(self.date), ", nav=", String(self.unit_net_value), ")")


@fieldwise_init
struct PortfolioRecord(Copyable, Movable, Writable):
    var date: String
    var cash: Float64
    var total_value: Float64
    var market_value: Float64
    var unit_net_value: Float64
    var units: Float64
    var static_unit_net_value: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PortfolioRecord(date=", self.date, ", nav=", String(self.unit_net_value), ")")


@fieldwise_init
struct AccountRecord(Copyable, Movable, Writable):
    var date: String
    var cash: Float64
    var transaction_cost: Float64
    var market_value: Float64
    var total_value: Float64
    var position_pnl: Float64
    var trading_pnl: Float64
    var daily_pnl: Float64
    var margin: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("AccountRecord(date=", self.date, ", value=", String(self.total_value), ")")


@fieldwise_init
struct PositionRecord(Copyable, Movable, Writable):
    var order_book_id: String
    var symbol: String
    var date: String
    var quantity: Float64
    var last_price: Float64
    var avg_price: Float64
    var market_value: Float64
    var LONG_pnl: Float64
    var LONG_margin: Float64
    var LONG_market_value: Float64
    var LONG_quantity: Float64
    var LONG_avg_open_price: Float64
    var SHORT_pnl: Float64
    var SHORT_margin: Float64
    var SHORT_market_value: Float64
    var SHORT_quantity: Float64
    var SHORT_avg_open_price: Float64
    var margin: Float64
    var contract_multiplier: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PositionRecord(", self.order_book_id, ", date=", self.date, ")")


@fieldwise_init
struct TradeRecord(Copyable, Movable, Writable):
    var datetime: String
    var trading_datetime: String
    var order_book_id: String
    var symbol: String
    var side: String
    var position_effect: String
    var exec_id: String
    var tax: Float64
    var commission: Float64
    var last_quantity: Int
    var last_price: Float64
    var order_id: Int
    var transaction_cost: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TradeRecord(", self.order_book_id, ", ", self.side, ", qty=", String(self.last_quantity), ")")


@fieldwise_init
struct PressureTestPeriod(Copyable, Movable, Writable):
    var title: String
    var start_date: String
    var end_date: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.title, "(", self.start_date, "~", self.end_date, ")")


@fieldwise_init
struct AnalyserMod(ModInterface, Movable, Writable):
    var name: String
    var enabled: Bool
    var _benchmark_config: String
    var _benchmark_daily_returns: List[Float64]
    var _total_benchmark_portfolios: List[BenchmarkPortfolio]
    var _data_proxy: DataProxy
    var _start_date: DateTime
    var _end_date: DateTime
    var _initial_cash: Float64
    var _orders: List[Order]
    var _trades: List[TradeRecord]
    var _total_portfolios: List[PortfolioRecord]
    var _sub_accounts: Dict[String, List[AccountRecord]]
    var _positions: Dict[String, List[PositionRecord]]
    var _daily_pnl: List[Float64]
    var _portfolio_daily_returns: List[Float64]
    var _benchmark: Optional[List[Tuple[String, Float64]]]
    var _plot_store: PlotStore
    var _strategy_name: String
    var _strategy_file: String
    var _run_type: String
    var _accounts_config: Dict[String, Float64]
    var _trading_days_a_year: Int
    var _result: Dict[String, String]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("AnalyserMod(", self.name, ")")

    def start_up(mut self, env_name: String, mod_config_name: String):
        self.enabled = True
        self._plot_store = create_plot_store()

    def tear_down(mut self, code: EXIT_CODE, exception_msg: Optional[String]):
        self._result = Dict[String, String]()
        if code != EXIT_CODE.EXIT_SUCCESS:
            return
        if not self.enabled:
            return
        if len(self._total_portfolios) == 0:
            return

        var strategy_name = self._strategy_name
        if len(strategy_name) == 0:
            strategy_name = "strategy"

        self._result["strategy_name"] = strategy_name
        self._result["start_date"] = _format_date(self._start_date)
        self._result["end_date"] = _format_date(self._end_date)
        self._result["strategy_file"] = self._strategy_file
        self._result["run_type"] = self._run_type

        for entry in self._accounts_config.items():
            self._result[entry.key] = String(entry.value)

        if self._benchmark is not None:
            var benchmark = self._benchmark.value().copy()
            if len(benchmark) == 1:
                self._result["benchmark"] = benchmark[0][0]
            else:
                var benchmark_str = String()
                for i in range(len(benchmark)):
                    if i > 0:
                        benchmark_str += ","
                    benchmark_str += benchmark[i][0] + ":" + String(benchmark[i][1])
                self._result["benchmark"] = benchmark_str

        var summary = self.calculate_summary()
        for entry in summary.items():
            self._result[entry.key] = String(entry.value)

        if len(self._total_portfolios) > 0:
            var last_portfolio = self._total_portfolios[len(self._total_portfolios) - 1].copy()
            self._result["total_value"] = String(last_portfolio.total_value)
            self._result["cash"] = String(last_portfolio.cash)

        self._result["total_trades"] = String(len(self._trades))
        self._result["total_orders"] = String(len(self._orders))

    def set_benchmark(mut self, benchmark_config: String) -> None:
        self._benchmark_config = benchmark_config
        var parsed = self._parse_benchmark(benchmark_config)
        if len(parsed) > 0:
            self._benchmark = Optional[List[Tuple[String, Float64]]](parsed^)
        else:
            self._benchmark = Optional[List[Tuple[String, Float64]]](None)
        self._generate_benchmark_portfolios()

    @staticmethod
    def _parse_benchmark(config: String) -> List[Tuple[String, Float64]]:
        var result = List[Tuple[String, Float64]]()

        if len(config) == 0:
            return result^

        var config_str = config
        var parts = config_str.split(",")
        if len(parts) == 1:
            var part_str = String(parts[0].strip())
            if len(part_str) == 0:
                return result^
            var sub_parts = part_str.split(":")
            if len(sub_parts) > 1:
                var order_book_id = String(sub_parts[0].strip())
                var weight_str = String(sub_parts[1].strip())
                try:
                    var weight = Float64(weight_str)
                    result.append(Tuple[String, Float64](order_book_id, weight))
                except:
                    result.append(Tuple[String, Float64](order_book_id, 1.0))
                return result^
            result.append(Tuple[String, Float64](part_str, 1.0))
            return result^

        for i in range(len(parts)):
            var part_str = String(parts[i].strip())
            if len(part_str) == 0:
                continue

            var sub_parts = part_str.split(":")
            if len(sub_parts) == 2:
                var order_book_id = String(sub_parts[0].strip())
                var weight_str = String(sub_parts[1].strip())
                try:
                    var weight = Float64(weight_str)
                    result.append(Tuple[String, Float64](order_book_id, weight))
                except:
                    result.append(Tuple[String, Float64](order_book_id, 1.0))
            else:
                result.append(Tuple[String, Float64](part_str, 1.0))

        return result^

    @staticmethod
    def _parse_benchmark_from_dict(entries: List[Tuple[String, Float64]]) -> List[Tuple[String, Float64]]:
        var result = List[Tuple[String, Float64]]()
        for i in range(len(entries)):
            result.append(entries[i].copy())
        return result^

    @staticmethod
    def _safe_convert(value: Float64, ndigits: Int = 4) -> Float64:
        var multiplier = pow(10.0, Float64(ndigits))
        var scaled = value * multiplier
        var truncated = Float64(Int(scaled))
        var diff = scaled - truncated
        if diff > 0.5 or (diff == 0.5 and Int(truncated) % 2 != 0):
            truncated = truncated + 1.0
        elif diff < -0.5 or (diff == -0.5 and Int(truncated) % 2 != 0):
            truncated = truncated - 1.0
        return truncated / multiplier

    def _is_null_oid(self, order_book_id: String) -> Bool:
        return order_book_id == "null" or order_book_id == "NULL"

    def _generate_benchmark_portfolios(mut self) -> None:
        if self._benchmark is None:
            return

        var benchmark = self._benchmark.value().copy()
        if len(benchmark) == 0:
            return

        var trading_dates = self._data_proxy.get_trading_dates(self._start_date, self._end_date)

        if len(trading_dates) == 0:
            self._benchmark_daily_returns = List[Float64]()
            return

        var daily_returns = List[Float64]()
        for _ in range(len(trading_dates)):
            daily_returns.append(0.0)

        var weights = 0.0

        var prev_trading_date = self._data_proxy.get_previous_trading_date(self._start_date)
        var trading_dates_with_extra = self._data_proxy.get_trading_dates(prev_trading_date, self._end_date)

        for i in range(len(benchmark)):
            var order_book_id = benchmark[i][0]
            var weight = benchmark[i][1]

            if self._is_null_oid(order_book_id):
                for j in range(len(daily_returns)):
                    daily_returns[j] = daily_returns[j] + 0.0 * weight
            else:
                var ins = self._data_proxy.get_instrument(order_book_id)
                var bars = self._data_proxy.history_bars(
                    ins, len(trading_dates_with_extra), "1d", "close", self._end_date
                )

                if len(bars) >= 2:
                    var offset = len(bars) - len(trading_dates)
                    for j in range(len(trading_dates)):
                        if offset + j - 1 >= 0 and offset + j < len(bars):
                            var prev_close = bars[offset + j - 1].close()
                            var curr_close = bars[offset + j].close()
                            if prev_close > 0:
                                var ret = (curr_close - prev_close) / prev_close
                                daily_returns[j] = daily_returns[j] + ret * weight

            weights = weights + weight

        if weights != 0:
            for i in range(len(daily_returns)):
                daily_returns[i] = daily_returns[i] / weights

        self._benchmark_daily_returns = daily_returns.copy()

        self._total_benchmark_portfolios = List[BenchmarkPortfolio]()
        var unit_net_value = 1.0
        for i in range(len(trading_dates)):
            unit_net_value = unit_net_value * (1.0 + daily_returns[i])
            self._total_benchmark_portfolios.append(BenchmarkPortfolio(
                date=trading_dates[i],
                unit_net_value=unit_net_value,
                total_value=unit_net_value * self._initial_cash
            ))

    def collect_order(mut self, order: Order) -> None:
        self._orders.append(order.copy())

    def collect_trade(mut self, trade: Trade) -> None:
        var record = self._to_trade_record(trade)
        self._trades.append(record^)

    def collect_daily(mut self, calendar_dt: DateTime, trading_dt: DateTime, portfolio_cash: Float64, portfolio_total_value: Float64, portfolio_market_value: Float64, portfolio_unit_net_value: Float64, portfolio_units: Float64, portfolio_static_unit_net_value: Float64, portfolio_daily_returns: Float64, portfolio_daily_pnl: Float64) -> None:
        var date_str = _format_date(calendar_dt)
        self._portfolio_daily_returns.append(portfolio_daily_returns)
        self._total_portfolios.append(PortfolioRecord(
            date=date_str,
            cash=self._safe_convert(portfolio_cash),
            total_value=self._safe_convert(portfolio_total_value),
            market_value=self._safe_convert(portfolio_market_value),
            unit_net_value=self._safe_convert(portfolio_unit_net_value, 6),
            units=portfolio_units,
            static_unit_net_value=self._safe_convert(portfolio_static_unit_net_value),
        ))
        self._daily_pnl.append(portfolio_daily_pnl)

    def collect_account_daily(mut self, account_type: String, date_str: String, cash: Float64, transaction_cost: Float64, market_value: Float64, total_value: Float64, position_pnl: Float64 = 0.0, trading_pnl: Float64 = 0.0, daily_pnl: Float64 = 0.0, margin: Float64 = 0.0) raises -> None:
        var record = AccountRecord(
            date=date_str,
            cash=self._safe_convert(cash),
            transaction_cost=self._safe_convert(transaction_cost),
            market_value=self._safe_convert(market_value),
            total_value=self._safe_convert(total_value),
            position_pnl=self._safe_convert(position_pnl),
            trading_pnl=self._safe_convert(trading_pnl),
            daily_pnl=self._safe_convert(daily_pnl),
            margin=self._safe_convert(margin),
        )
        if account_type not in self._sub_accounts:
            self._sub_accounts[account_type] = List[AccountRecord]()
        self._sub_accounts[account_type].append(record^)

    def collect_position_daily(mut self, account_type: String, order_book_id: String, symbol: String, date_str: String, long_pos: Optional[Position], short_pos: Optional[Position], instrument_type: INSTRUMENT_TYPE) raises -> None:
        var record = PositionRecord(
            order_book_id=order_book_id,
            symbol=symbol,
            date=date_str,
            quantity=0.0,
            last_price=0.0,
            avg_price=0.0,
            market_value=0.0,
            LONG_pnl=0.0,
            LONG_margin=0.0,
            LONG_market_value=0.0,
            LONG_quantity=0.0,
            LONG_avg_open_price=0.0,
            SHORT_pnl=0.0,
            SHORT_margin=0.0,
            SHORT_market_value=0.0,
            SHORT_quantity=0.0,
            SHORT_avg_open_price=0.0,
            margin=0.0,
            contract_multiplier=0.0,
        )

        var is_long_only = _is_long_only_instrument(instrument_type)

        if is_long_only or instrument_type == INSTRUMENT_TYPE.REPO:
            if long_pos is not None:
                var lp = long_pos.value()
                record.quantity = self._safe_convert(Float64(lp.quantity))
                record.last_price = self._safe_convert(lp.last_price)
                record.avg_price = self._safe_convert(lp.avg_price)
                record.market_value = self._safe_convert(lp.market_value)
        else:
            var position = long_pos
            if position is None:
                position = short_pos
            if position is not None:
                var p = position.value()
                record.margin = self._safe_convert(p.margin())
                record.contract_multiplier = self._safe_convert(p._contract_multiplier)
                record.last_price = self._safe_convert(p.last_price)

            if long_pos is not None:
                var lp = long_pos.value()
                record.LONG_pnl = self._safe_convert(lp.pnl())
                record.LONG_margin = self._safe_convert(lp.margin())
                record.LONG_market_value = self._safe_convert(lp.market_value)
                record.LONG_quantity = self._safe_convert(Float64(lp.quantity))
                record.LONG_avg_open_price = self._safe_convert(lp.avg_price)

            if short_pos is not None:
                var sp = short_pos.value()
                record.SHORT_pnl = self._safe_convert(sp.pnl())
                record.SHORT_margin = self._safe_convert(sp.margin())
                record.SHORT_market_value = self._safe_convert(sp.market_value)
                record.SHORT_quantity = self._safe_convert(Float64(sp.quantity))
                record.SHORT_avg_open_price = self._safe_convert(sp.avg_price)

        if account_type not in self._positions:
            self._positions[account_type] = List[PositionRecord]()
        self._positions[account_type].append(record^)

    def _to_trade_record(self, trade: Trade) -> TradeRecord:
        return TradeRecord(
            datetime=_format_datetime(trade.datetime),
            trading_datetime=_format_datetime(trade.trading_datetime),
            order_book_id=trade.order_book_id,
            symbol=trade.order_book_id,
            side=trade.side.value,
            position_effect=trade.position_effect.value,
            exec_id=trade.exec_id,
            tax=trade.tax,
            commission=trade.commission,
            last_quantity=trade.quantity,
            last_price=self._safe_convert(trade.price),
            order_id=trade.order_id,
            transaction_cost=trade.commission + trade.tax,
        )

    def get_benchmark_portfolios(self) -> List[BenchmarkPortfolio]:
        return self._total_benchmark_portfolios.copy()

    def get_benchmark_daily_returns(self) -> List[Float64]:
        return self._benchmark_daily_returns.copy()

    def get_portfolio_daily_returns(self) -> List[Float64]:
        return self._portfolio_daily_returns.copy()

    def get_orders(self) -> List[Order]:
        return self._orders.copy()

    def get_trades(self) -> List[TradeRecord]:
        return self._trades.copy()

    def get_total_portfolios(self) -> List[PortfolioRecord]:
        return self._total_portfolios.copy()

    def get_daily_pnl(self) -> List[Float64]:
        return self._daily_pnl.copy()

    def get_sub_accounts(self) -> Dict[String, List[AccountRecord]]:
        return self._sub_accounts.copy()

    def get_positions(self) -> Dict[String, List[PositionRecord]]:
        return self._positions.copy()

    def get_result(self) -> Dict[String, String]:
        return self._result.copy()

    def get_state(self) -> String:
        var parts = List[String]()
        parts.append("{\"benchmark_daily_returns\":[")
        for i in range(len(self._benchmark_daily_returns)):
            if i > 0:
                parts.append(",")
            parts.append(String(self._benchmark_daily_returns[i]))
        parts.append("],\"portfolio_daily_returns\":[")
        for i in range(len(self._portfolio_daily_returns)):
            if i > 0:
                parts.append(",")
            parts.append(String(self._portfolio_daily_returns[i]))
        parts.append("],\"daily_pnl\":[")
        for i in range(len(self._daily_pnl)):
            if i > 0:
                parts.append(",")
            parts.append(String(self._daily_pnl[i]))
        parts.append("],\"total_portfolios\":[")
        for i in range(len(self._total_portfolios)):
            if i > 0:
                parts.append(",")
            var p = self._total_portfolios[i].copy()
            parts.append("{\"date\":\"" + p.date + "\",\"cash\":" + String(p.cash) + ",\"total_value\":" + String(p.total_value) + ",\"market_value\":" + String(p.market_value) + ",\"unit_net_value\":" + String(p.unit_net_value) + ",\"units\":" + String(p.units) + ",\"static_unit_net_value\":" + String(p.static_unit_net_value) + "}")
        parts.append("],\"orders_count\":" + String(len(self._orders)))
        parts.append(",\"trades_count\":" + String(len(self._trades)))
        parts.append("}")
        var result = String()
        for p in parts:
            result += p
        return result

    def set_state(mut self, state: String) -> None:
        self._benchmark_daily_returns = _parse_float_list_from_json(state, "benchmark_daily_returns")
        self._portfolio_daily_returns = _parse_float_list_from_json(state, "portfolio_daily_returns")
        self._daily_pnl = _parse_float_list_from_json(state, "daily_pnl")
        var total_portfolios_data = _parse_float_list_from_json(state, "total_portfolios")
        if len(total_portfolios_data) == 0:
            self._total_portfolios = List[PortfolioRecord]()

    def calculate_summary(self) -> Dict[String, Float64]:
        var summary = Dict[String, Float64]()

        if len(self._portfolio_daily_returns) == 0:
            return summary^

        var total_returns = 1.0
        for i in range(len(self._portfolio_daily_returns)):
            total_returns = total_returns * (1.0 + self._portfolio_daily_returns[i])
        total_returns = total_returns - 1.0
        summary["total_returns"] = total_returns

        var n = len(self._portfolio_daily_returns)
        if n > 0 and total_returns > -1.0:
            var trading_days_a_year = Float64(self._trading_days_a_year)
            if trading_days_a_year == 0:
                trading_days_a_year = 252.0
            var annualized_returns = pow(total_returns + 1.0, trading_days_a_year / Float64(n)) - 1.0
            summary["annualized_returns"] = annualized_returns
        else:
            summary["annualized_returns"] = 0.0

        var nav_list = List[Float64]()
        var nav = 1.0
        nav_list.append(nav)
        for i in range(len(self._portfolio_daily_returns)):
            nav = nav * (1.0 + self._portfolio_daily_returns[i])
            nav_list.append(nav)
        summary["max_drawdown"] = calculate_max_drawdown(nav_list)

        var avg_return = 0.0
        for i in range(len(self._portfolio_daily_returns)):
            avg_return = avg_return + self._portfolio_daily_returns[i]
        if n > 0:
            avg_return = avg_return / Float64(n)

        var variance = 0.0
        for i in range(len(self._portfolio_daily_returns)):
            var diff = self._portfolio_daily_returns[i] - avg_return
            variance = variance + diff * diff
        if n > 0:
            variance = variance / Float64(n)
        var std_dev = sqrt(variance)

        var risk_free_rate = 0.03
        if std_dev > 0:
            summary["sharpe"] = (avg_return - risk_free_rate / 252.0) / std_dev * sqrt(252.0)
        else:
            summary["sharpe"] = 0.0

        var win_count = 0
        for i in range(len(self._portfolio_daily_returns)):
            if self._portfolio_daily_returns[i] > 0:
                win_count += 1
        if n > 0:
            summary["win_rate"] = Float64(win_count) / Float64(n)
        else:
            summary["win_rate"] = 0.0

        if len(self._daily_pnl) > 0:
            var profit_sum = 0.0
            var loss_sum = 0.0
            var profit_count = 0
            var loss_count = 0
            for i in range(len(self._daily_pnl)):
                if self._daily_pnl[i] > 0:
                    profit_sum += self._daily_pnl[i]
                    profit_count += 1
                elif self._daily_pnl[i] < 0:
                    loss_sum += self._daily_pnl[i]
                    loss_count += 1
            var avg_profit = 0.0
            var avg_loss = 0.0
            if profit_count > 0:
                avg_profit = profit_sum / Float64(profit_count)
            if loss_count > 0:
                avg_loss = loss_sum / Float64(loss_count)
            if avg_loss != 0:
                summary["profit_loss_rate"] = abs(avg_profit / avg_loss)
            else:
                summary["profit_loss_rate"] = 0.0
        else:
            summary["profit_loss_rate"] = 0.0

        if len(self._benchmark_daily_returns) > 0:
            var benchmark_total_returns = 1.0
            for i in range(len(self._benchmark_daily_returns)):
                benchmark_total_returns = benchmark_total_returns * (1.0 + self._benchmark_daily_returns[i])
            benchmark_total_returns = benchmark_total_returns - 1.0
            summary["benchmark_total_returns"] = benchmark_total_returns

            if n > 0:
                var trading_days_a_year = Float64(self._trading_days_a_year)
                if trading_days_a_year == 0:
                    trading_days_a_year = 252.0
                var benchmark_annualized = pow(benchmark_total_returns + 1.0, trading_days_a_year / Float64(n)) - 1.0
                summary["benchmark_annualized_returns"] = benchmark_annualized

        return summary^


@fieldwise_init
struct PerformanceMetrics(Movable, Copyable, ImplicitlyCopyable, Writable):
    var total_returns: Float64
    var annualized_returns: Float64
    var max_drawdown: Float64
    var sharpe_ratio: Float64
    var win_rate: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PerformanceMetrics(returns=", String(self.total_returns), ", sharpe=", String(self.sharpe_ratio), ")")


@fieldwise_init
struct TradeSummary(Movable, Copyable, ImplicitlyCopyable, Writable):
    var total_trades: Int
    var winning_trades: Int
    var losing_trades: Int
    var total_pnl: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TradeSummary(trades=", String(self.total_trades), ", pnl=", String(self.total_pnl), ")")


def _format_date(dt: DateTime) -> String:
    var y = String(dt.year)
    var m = String(dt.month)
    var d = String(dt.day)
    if dt.month < 10:
        m = "0" + m
    if dt.day < 10:
        d = "0" + d
    return y + "-" + m + "-" + d


def _format_datetime(dt: DateTime) -> String:
    var h = String(dt.hour)
    var mi = String(dt.minute)
    var s = String(dt.second)
    if dt.hour < 10:
        h = "0" + h
    if dt.minute < 10:
        mi = "0" + mi
    if dt.second < 10:
        s = "0" + s
    return _format_date(dt) + " " + h + ":" + mi + ":" + s


def _is_long_only_instrument(instrument_type: INSTRUMENT_TYPE) -> Bool:
    return instrument_type == INSTRUMENT_TYPE.CS or instrument_type == INSTRUMENT_TYPE.ETF or instrument_type == INSTRUMENT_TYPE.LOF or instrument_type == INSTRUMENT_TYPE.INDX or instrument_type == INSTRUMENT_TYPE.PUBLIC_FUND or instrument_type == INSTRUMENT_TYPE.FUND or instrument_type == INSTRUMENT_TYPE.BOND or instrument_type == INSTRUMENT_TYPE.CONVERTIBLE or instrument_type == INSTRUMENT_TYPE.REITs


def _parse_float_list_from_json(json_str: String, key: String) -> List[Float64]:
    var result = List[Float64]()
    var search_key = "\"" + key + "\":["
    var start_idx = json_str.find(search_key)
    if start_idx == -1:
        return result^
    var arr_start = start_idx + len(search_key)
    var arr_end = json_str.find("]", arr_start)
    if arr_end == -1:
        return result^
    var arr_content = json_str[byte=arr_start:arr_end]
    if len(arr_content) == 0:
        return result^
    var parts = arr_content.split(",")
    for i in range(len(parts)):
        var part = String(parts[i].strip())
        if len(part) > 0:
            try:
                result.append(Float64(part))
            except:
                pass
    return result^


def get_pressure_test_periods() -> List[PressureTestPeriod]:
    var result = List[PressureTestPeriod]()
    result.append(PressureTestPeriod(title="打击壳价值", start_date="2016-11-01", end_date="2018-02-01"))
    result.append(PressureTestPeriod(title="公募基金抱团", start_date="2020-10-09", end_date="2021-03-01"))
    result.append(PressureTestPeriod(title="行业风格切换", start_date="2021-09-01", end_date="2021-12-31"))
    result.append(PressureTestPeriod(title="小盘踩踏危机", start_date="2024-01-05", end_date="2024-02-08"))
    return result^


def get_null_oids() -> Set[String]:
    var s = Set[String]()
    s.add("null")
    s.add("NULL")
    return s^


def get_account_fields_map() -> Dict[String, List[String]]:
    var m = Dict[String, List[String]]()
    m[DEFAULT_ACCOUNT_TYPE.STOCK.value] = List[String]()
    var future_fields = List[String]()
    future_fields.append("position_pnl")
    future_fields.append("trading_pnl")
    future_fields.append("daily_pnl")
    future_fields.append("margin")
    m[DEFAULT_ACCOUNT_TYPE.FUTURE.value] = future_fields^
    m[DEFAULT_ACCOUNT_TYPE.BOND.value] = List[String]()
    return m^


def create_analyser_mod() -> AnalyserMod:
    return AnalyserMod(
        name="analyser",
        enabled=False,
        _benchmark_config="",
        _benchmark_daily_returns=List[Float64](),
        _total_benchmark_portfolios=List[BenchmarkPortfolio](),
        _data_proxy=create_data_proxy(),
        _start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        _end_date=DateTime(2024, 12, 31, 0, 0, 0, 0),
        _initial_cash=100000.0,
        _orders=List[Order](),
        _trades=List[TradeRecord](),
        _total_portfolios=List[PortfolioRecord](),
        _sub_accounts=Dict[String, List[AccountRecord]](),
        _positions=Dict[String, List[PositionRecord]](),
        _daily_pnl=List[Float64](),
        _portfolio_daily_returns=List[Float64](),
        _benchmark=Optional[List[Tuple[String, Float64]]](None),
        _plot_store=create_plot_store(),
        _strategy_name="",
        _strategy_file="",
        _run_type="backtest",
        _accounts_config=Dict[String, Float64](),
        _trading_days_a_year=252,
        _result=Dict[String, String](),
    )


def create_analyser_mod_with_params(
    var data_proxy: DataProxy,
    start_date: DateTime,
    end_date: DateTime,
    initial_cash: Float64,
    benchmark_config: String = ""
) -> AnalyserMod:
    var mod = AnalyserMod(
        name="analyser",
        enabled=False,
        _benchmark_config="",
        _benchmark_daily_returns=List[Float64](),
        _total_benchmark_portfolios=List[BenchmarkPortfolio](),
        _data_proxy=data_proxy^,
        _start_date=start_date,
        _end_date=end_date,
        _initial_cash=initial_cash,
        _orders=List[Order](),
        _trades=List[TradeRecord](),
        _total_portfolios=List[PortfolioRecord](),
        _sub_accounts=Dict[String, List[AccountRecord]](),
        _positions=Dict[String, List[PositionRecord]](),
        _daily_pnl=List[Float64](),
        _portfolio_daily_returns=List[Float64](),
        _benchmark=Optional[List[Tuple[String, Float64]]](None),
        _plot_store=create_plot_store(),
        _strategy_name="",
        _strategy_file="",
        _run_type="backtest",
        _accounts_config=Dict[String, Float64](),
        _trading_days_a_year=252,
        _result=Dict[String, String](),
    )

    if len(benchmark_config) > 0:
        mod.set_benchmark(benchmark_config)

    return mod^


def create_performance_metrics() -> PerformanceMetrics:
    return PerformanceMetrics(
        total_returns=0.0,
        annualized_returns=0.0,
        max_drawdown=0.0,
        sharpe_ratio=0.0,
        win_rate=0.0
    )


def create_trade_summary() -> TradeSummary:
    return TradeSummary(
        total_trades=0,
        winning_trades=0,
        losing_trades=0,
        total_pnl=0.0
    )
