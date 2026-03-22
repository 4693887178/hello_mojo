"""
RQAlpha Mojo - Report Generation
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/report/report.py
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import calculate_max_drawdown, calculate_sharpe_ratio
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct StrategyResult(Movable, Copyable, ImplicitlyCopyable):
    var start_date: DateTime
    var end_date: DateTime
    var total_returns: Float64
    var annual_returns: Float64
    var max_drawdown: Float64
    var sharpe_ratio: Float64
    var total_trades: Int
    var win_rate: Float64
    var profit_loss_ratio: Float64
    
    def to_dict(self) -> Dict[String, String]:
        var d = Dict[String, String]()
        d["start_date"] = String(self.start_date.year) + "-" + String(self.start_date.month) + "-" + String(self.start_date.day)
        d["end_date"] = String(self.end_date.year) + "-" + String(self.end_date.month) + "-" + String(self.end_date.day)
        d["total_returns"] = String(self.total_returns * 100) + "%"
        d["annual_returns"] = String(self.annual_returns * 100) + "%"
        d["max_drawdown"] = String(self.max_drawdown * 100) + "%"
        d["sharpe_ratio"] = String(self.sharpe_ratio)
        d["total_trades"] = String(self.total_trades)
        d["win_rate"] = String(self.win_rate * 100) + "%"
        d["profit_loss_ratio"] = String(self.profit_loss_ratio)
        return d^


@fieldwise_init
struct Report(Movable):
    var strategy_name: String
    var result: StrategyResult
    var daily_returns: List[Float64]
    var nav_list: List[Float64]
    var trade_list: List[Dict[String, String]]
    
    def generate_summary(self) -> String:
        var summary = "=== Strategy Report ===\n"
        summary += "Strategy: " + self.strategy_name + "\n"
        summary += "Period: " + self.result.start_date.__str__() + " to " + self.result.end_date.__str__() + "\n"
        summary += "Total Returns: " + String(self.result.total_returns * 100) + "%\n"
        summary += "Annual Returns: " + String(self.result.annual_returns * 100) + "%\n"
        summary += "Max Drawdown: " + String(self.result.max_drawdown * 100) + "%\n"
        summary += "Sharpe Ratio: " + String(self.result.sharpe_ratio) + "\n"
        summary += "Total Trades: " + String(self.result.total_trades) + "\n"
        summary += "Win Rate: " + String(self.result.win_rate * 100) + "%\n"
        summary += "Profit/Loss Ratio: " + String(self.result.profit_loss_ratio) + "\n"
        return summary


def create_report(strategy_name: String, nav_list: List[Float64], start_date: DateTime, end_date: DateTime, total_trades: Int = 0, win_count: Int = 0, loss_count: Int = 0) -> Report:
    var max_dd = calculate_max_drawdown(nav_list)
    
    var returns = List[Float64]()
    for i in range(1, len(nav_list)):
        if nav_list[i-1] > 0:
            returns.append((nav_list[i] - nav_list[i-1]) / nav_list[i-1])
    
    var sharpe = calculate_sharpe_ratio(returns)
    
    var total_return = 0.0
    if len(nav_list) > 0 and nav_list[0] > 0:
        total_return = (nav_list[-1] - nav_list[0]) / nav_list[0]
    
    var days = (end_date.year - start_date.year) * 365 + (end_date.month - start_date.month) * 30 + (end_date.day - start_date.day)
    var annual_return = 0.0
    if days > 0:
        annual_return = total_return * 365.0 / Float64(days)
    
    var win_rate = 0.0
    if total_trades > 0:
        win_rate = Float64(win_count) / Float64(total_trades)
    
    var result = StrategyResult(
        start_date=start_date,
        end_date=end_date,
        total_returns=total_return,
        annual_returns=annual_return,
        max_drawdown=max_dd,
        sharpe_ratio=sharpe,
        total_trades=total_trades,
        win_rate=win_rate,
        profit_loss_ratio=0.0
    )
    
    return Report(
        strategy_name=strategy_name,
        result=result^,
        daily_returns=returns^,
        nav_list=nav_list.copy(),
        trade_list=List[Dict[String, String]]()
    )
