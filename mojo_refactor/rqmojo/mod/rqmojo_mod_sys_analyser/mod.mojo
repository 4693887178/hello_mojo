"""
RQAlpha Mojo - Analyser Mod
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/

This module provides portfolio analysis functionality including:
- Benchmark portfolio calculation
- Performance metrics calculation
- Trade summary generation
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from std.collections import Dict, List


@fieldwise_init
struct BenchmarkPortfolio(Copyable, Movable, ImplicitlyCopyable):
    var date: DateTime
    var unit_net_value: Float64
    var total_value: Float64
    
    def __str__(self) -> String:
        return "BenchmarkPortfolio(date=" + self.date.__str__() + ", nav=" + String(self.unit_net_value) + ")"


@fieldwise_init
struct AnalyserMod(Movable):
    var name: String
    var enabled: Bool
    var _benchmark_config: String
    var _benchmark_daily_returns: List[Float64]
    var _total_benchmark_portfolios: List[BenchmarkPortfolio]
    var _data_proxy: DataProxy
    var _start_date: DateTime
    var _end_date: DateTime
    var _initial_cash: Float64
    
    def __str__(self) -> String:
        return "AnalyserMod(" + self.name + ")"
    
    def start(self) -> None:
        pass
    
    def stop(self) -> None:
        pass
    
    def set_benchmark(mut self, benchmark_config: String) -> None:
        self._benchmark_config = benchmark_config
        self._generate_benchmark_portfolios()
    
    def _parse_benchmark(self, config: String) raises -> List[Tuple[String, Float64]]:
        var result = List[Tuple[String, Float64]]()
        
        var config_str = config
        var parts = config_str.split(",")
        for i in range(len(parts)):
            var part_str = String(parts[i].strip())
            if len(part_str) == 0:
                continue
            
            var sub_parts = part_str.split(":")
            if len(sub_parts) == 2:
                var order_book_id = String(sub_parts[0].strip())
                var weight_str = String(sub_parts[1].strip())
                var weight = Float64(weight_str)
                result.append(Tuple[String, Float64](order_book_id, weight))
            else:
                result.append(Tuple[String, Float64](part_str, 1.0))
        
        return result^
    
    def _generate_benchmark_portfolios(mut self) -> None:
        if len(self._benchmark_config) == 0:
            return
        
        var benchmark: List[Tuple[String, Float64]]
        try:
            benchmark = self._parse_benchmark(self._benchmark_config)
        except e:
            return
        
        if len(benchmark) == 0:
            return
        
        var trading_dates = self._data_proxy.get_trading_dates(self._start_date, self._end_date)
        
        if len(trading_dates) == 0:
            return
        
        var daily_returns = List[Float64]()
        for i in range(len(trading_dates)):
            daily_returns.append(0.0)
        
        var weights = 0.0
        
        for i in range(len(benchmark)):
            var order_book_id = benchmark[i][0]
            var weight = benchmark[i][1]
            
            if order_book_id == "null":
                for j in range(len(daily_returns)):
                    daily_returns[j] = daily_returns[j] + 0.0 * weight
            else:
                var ins = self._data_proxy.get_instrument(order_book_id)
                var bars = self._data_proxy.history_bars(
                    ins, len(trading_dates) + 1, "1d", "close", self._end_date
                )
                
                if len(bars) >= 2:
                    for j in range(len(trading_dates)):
                        var prev_bar = bars[len(bars) - len(trading_dates) + j - 1]
                        var curr_bar = bars[len(bars) - len(trading_dates) + j]
                        var prev_close = prev_bar.close()
                        var curr_close = curr_bar.close()
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
    
    def get_benchmark_portfolios(self) -> List[BenchmarkPortfolio]:
        return self._total_benchmark_portfolios.copy()
    
    def get_benchmark_daily_returns(self) -> List[Float64]:
        return self._benchmark_daily_returns.copy()


@fieldwise_init
struct PerformanceMetrics(Movable, Copyable, ImplicitlyCopyable):
    var total_returns: Float64
    var annualized_returns: Float64
    var max_drawdown: Float64
    var sharpe_ratio: Float64
    var win_rate: Float64
    
    def __str__(self) -> String:
        return "PerformanceMetrics(returns=" + String(self.total_returns) + ", sharpe=" + String(self.sharpe_ratio) + ")"


@fieldwise_init
struct TradeSummary(Movable, Copyable, ImplicitlyCopyable):
    var total_trades: Int
    var winning_trades: Int
    var losing_trades: Int
    var total_pnl: Float64
    
    def __str__(self) -> String:
        return "TradeSummary(trades=" + String(self.total_trades) + ", pnl=" + String(self.total_pnl) + ")"


def create_analyser_mod() -> AnalyserMod:
    return AnalyserMod(
        name="analyser",
        enabled=True,
        _benchmark_config="",
        _benchmark_daily_returns=List[Float64](),
        _total_benchmark_portfolios=List[BenchmarkPortfolio](),
        _data_proxy=create_data_proxy(),
        _start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        _end_date=DateTime(2024, 12, 31, 0, 0, 0, 0),
        _initial_cash=100000.0
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
        enabled=True,
        _benchmark_config="",
        _benchmark_daily_returns=List[Float64](),
        _total_benchmark_portfolios=List[BenchmarkPortfolio](),
        _data_proxy=data_proxy^,
        _start_date=start_date,
        _end_date=end_date,
        _initial_cash=initial_cash
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
