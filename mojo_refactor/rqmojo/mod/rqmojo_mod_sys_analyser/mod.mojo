"""
RQAlpha Mojo - Analyser Mod
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct AnalyserMod(Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var enabled: Bool
    
    fn __str__(self) -> String:
        return "AnalyserMod(" + self.name + ")"
    
    fn start(self) -> None:
        pass
    
    fn stop(self) -> None:
        pass


struct PerformanceMetrics:
    var total_returns: Float64
    var annualized_returns: Float64
    var max_drawdown: Float64
    var sharpe_ratio: Float64
    var win_rate: Float64
    
    fn __init__() -> Self:
        return Self {
            total_returns: 0.0,
            annualized_returns: 0.0,
            max_drawdown: 0.0,
            sharpe_ratio: 0.0,
            win_rate: 0.0
        }
    
    fn __str__(self) -> String:
        return "PerformanceMetrics(returns=" + String(self.total_returns) + ", sharpe=" + String(self.sharpe_ratio) + ")"


struct TradeSummary:
    var total_trades: Int
    var winning_trades: Int
    var losing_trades: Int
    var total_pnl: Float64
    
    fn __init__() -> Self:
        return Self {
            total_trades: 0,
            winning_trades: 0,
            losing_trades: 0,
            total_pnl: 0.0
        }
    
    fn __str__(self) -> String:
        return "TradeSummary(trades=" + String(self.total_trades) + ", pnl=" + String(self.total_pnl) + ")"


fn create_analyser_mod() -> AnalyserMod:
    return AnalyserMod(name="analyser", enabled=True)


fn create_performance_metrics() -> PerformanceMetrics:
    return PerformanceMetrics()


fn create_trade_summary() -> TradeSummary:
    return TradeSummary()
