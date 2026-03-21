"""
RQAlpha Mojo - Plot Store
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot_store.py
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import ChartType, Color


@fieldwise_init
struct PlotData(Movable):
    var name: String
    var chart_type: ChartType
    var color: Color


@fieldwise_init
struct PlotFigure(Movable):
    var title: String
    var x_label: String
    var y_label: String
    var width: Int
    var height: Int
    
    fn add_line(mut self, name: String, color: Color = Color.BLUE()) -> None:
        pass
    
    fn add_bar(mut self, name: String, color: Color = Color.RED()) -> None:
        pass


@fieldwise_init
struct PlotStore(Movable):
    var _figure_count: Int
    
    fn add_figure(mut self, title: String, x_label: String = "Date", y_label: String = "Value") -> None:
        self._figure_count += 1
    
    fn create_figure(mut self, title: String, x_label: String = "Date", y_label: String = "Value") -> PlotFigure:
        return PlotFigure(
            title=title,
            x_label=x_label,
            y_label=y_label,
            width=800,
            height=400
        )
    
    fn get_figure_count(self) -> Int:
        return self._figure_count
    
    fn clear(mut self) -> None:
        self._figure_count = 0


fn create_plot_store() -> PlotStore:
    return PlotStore(_figure_count=0)
