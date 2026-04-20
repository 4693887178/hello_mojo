"""
RQAlpha Mojo - Plot Store
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot_store.py

Design (vs Python original):
  Python: class PlotStore with defaultdict(dict) for _plots
  Mojo:   struct PlotStore with Dict[String, Dict[String, Float64]] for _plots
          Using String date representation as key (Morrow/DateTime not Hashable)

Key differences from previous Mojo implementation:
  - Previous: Had PlotData, PlotFigure structs with figure counting (WRONG)
  - Now: Matches Python original with proper plot storage and API
"""

from std.collections import Dict
from rqmojo.environment import Environment
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.typing import DateTime


def _date_to_key(dt: DateTime) -> String:
    """Convert DateTime to string key for dict storage (YYYY-MM-DD format)."""
    var month_str = String(dt.month)
    var day_str = String(dt.day)
    if dt.month < 10:
        month_str = "0" + month_str
    if dt.day < 10:
        day_str = "0" + day_str
    return String(dt.year) + "-" + month_str + "-" + day_str


@fieldwise_init
struct PlotStore(Movable):
    """
    Plot Store - stores plot data for strategy visualization.
    
    Ported from Python PlotStore class.
    Stores data as {series_name: {date_str: value}} structure.
    Uses String representation of DateTime as key for compatibility.
    """

    var _env: Environment
    var _plots: Dict[String, Dict[String, Float64]]

    def __init__(out self, var env: Environment):
        self._env = env^
        self._plots = Dict[String, Dict[String, Float64]]()

    def add_plot(mut self, dt: DateTime, series_name: String, value: Float64) raises -> None:
        """
        Add a data point to the plots store.

        Args:
            dt: The date/time of the data point.
            series_name: Name of the series/curve.
            value: The y-axis value.
        """
        var dt_key = _date_to_key(dt)
        try:
            _ = self._plots[series_name].copy()
        except:
            self._plots[series_name] = Dict[String, Float64]()
        self._plots[series_name][dt_key] = value

    def get_plots(self) raises -> Dict[String, Dict[String, Float64]]:
        """
        Get all stored plots.

        Returns:
            Dictionary of `{series_name: {date_str: value}}`.
        """
        return self._plots.copy()

    def plot(mut self, series_name: String, value: Float64) raises -> None:
        """
        Main API method to add a plot point.
        
        Uses the current trading date from environment as x-coordinate,
        and the provided value as y-coordinate.
        
        Points with the same series_name will be connected into a curve.

        Args:
            series_name: Curve name (must be a string).
            value: Y-coordinate value (must be a number).

        Example:

        .. code-block:: mojo

            # In handle_bar context:
            plot_store.plot("OPEN", bar_dict_open_price)

        """
        var dt = self._env.trading_dt()
        self.add_plot(dt, series_name, value)


def create_plot_store(var env: Environment) -> PlotStore:
    """
    Factory function to create a PlotStore instance.

    Args:
        env: The RQAlpha environment instance.

    Returns:
        A new PlotStore instance.
    """
    return PlotStore(env=env^)
