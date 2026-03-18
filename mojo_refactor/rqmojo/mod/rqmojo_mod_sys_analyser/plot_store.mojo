"""
RQAlpha Mojo - Plot Store
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot_store.py
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.plot import PlotFigure, PlotData
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import ChartType, Color


@fieldwise_init
struct PlotStore(Movable):
    var figures: List[PlotFigure]
    var _current_figure: Optional[PlotFigure]
    
    fn add_figure(mut self, figure: PlotFigure) -> None:
        self.figures.append(figure)
    
    fn create_figure(mut self, title: String, x_label: String = "Date", y_label: String = "Value") -> PlotFigure:
        var figure = PlotFigure(
            title=title,
            x_label=x_label,
            y_label=y_label,
            width=800,
            height=400,
            data_series=List[PlotData]()
        )
        self._current_figure = figure
        return figure
    
    fn get_figures(self) -> List[PlotFigure]:
        return self.figures
    
    fn clear(mut self) -> None:
        self.figures = List[PlotFigure]()
        self._current_figure = None


fn create_plot_store() -> PlotStore:
    return PlotStore(
        figures=List[PlotFigure](),
        _current_figure=None
    )
