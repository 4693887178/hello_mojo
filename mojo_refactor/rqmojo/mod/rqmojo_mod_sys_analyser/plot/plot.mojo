"""
RQAlpha Mojo - Plot Implementation
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/plot.py
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import ChartType, Color
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct PlotData(Copyable, Movable):
    var x: List[String]
    var y: List[Float64]
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
    var data_series: List[PlotData]
    
    def add_line(mut self, var x: List[String], var y: List[Float64], name: String, var color: Color = Color.BLUE()) -> None:
        var data = PlotData(
            x=x^,
            y=y^,
            name=name,
            chart_type=ChartType.LINE(),
            color=color^
        )
        self.data_series.append(data^)
    
    def add_bar(mut self, var x: List[String], var y: List[Float64], name: String, var color: Color = Color.RED()) -> None:
        var data = PlotData(
            x=x^,
            y=y^,
            name=name,
            chart_type=ChartType.BAR(),
            color=color^
        )
        self.data_series.append(data^)
    
    def to_json(self) -> String:
        var json = "{\"title\":\"" + self.title + "\","
        json += "\"x_label\":\"" + self.x_label + "\","
        json += "\"y_label\":\"" + self.y_label + "\","
        json += "\"width\":" + String(self.width) + ","
        json += "\"height\":" + String(self.height) + ","
        json += "\"data\":["
        
        for i in range(len(self.data_series)):
            if i > 0:
                json += ","
            var data = self.data_series[i].copy()
            json += "{\"name\":\"" + data.name + "\","
            json += "\"type\":\"" + data.chart_type.value + "\","
            var color_str = String.write(data.color)
            json += "\"color\":\"" + color_str + "\","
            json += "\"x\":["
            for j in range(len(data.x)):
                if j > 0:
                    json += ","
                json += "\"" + data.x[j] + "\""
            json += "],\"y\":["
            for j in range(len(data.y)):
                if j > 0:
                    json += ","
                json += String(data.y[j])
            json += "]}"
        
        json += "]}"
        return json


def create_figure(title: String = "", x_label: String = "Date", y_label: String = "Value", width: Int = 800, height: Int = 400) -> PlotFigure:
    return PlotFigure(
        title=title,
        x_label=x_label,
        y_label=y_label,
        width=width,
        height=height,
        data_series=List[PlotData]()
    )
