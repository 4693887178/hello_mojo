"""
RQAlpha Mojo - Slippage Models
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/slippage.py
"""

from rqmojo.model.order import Order
from rqmojo.model.bar import BarObject


trait Slippage:
    def get_slippage(self, order: Order, bar: BarObject) -> Float64:
        ...


struct FixedSlippage(Slippage, Movable, Copyable):
    var slippage: Float64
    
    def __init__(out self, slippage: Float64 = 0.0):
        self.slippage = slippage
    
    def get_slippage(self, order: Order, bar: BarObject) -> Float64:
        return self.slippage


struct PercentSlippage(Slippage, Movable, Copyable):
    var percent: Float64
    
    def __init__(out self, percent: Float64 = 0.0):
        self.percent = percent
    
    def get_slippage(self, order: Order, bar: BarObject) -> Float64:
        return bar.close() * self.percent


struct VolumeShareSlippage(Slippage, Movable, Copyable):
    var volume_share_limit: Float64
    var price_impact: Float64
    
    def __init__(out self, volume_share_limit: Float64 = 0.25, price_impact: Float64 = 0.1):
        self.volume_share_limit = volume_share_limit
        self.price_impact = price_impact
    
    def get_slippage(self, order: Order, bar: BarObject) -> Float64:
        if bar.volume() <= 0:
            return 0.0
        
        var volume_share = Float64(order.quantity) / Float64(bar.volume())
        if volume_share > self.volume_share_limit:
            volume_share = self.volume_share_limit
        
        return bar.close() * volume_share * self.price_impact


def create_fixed_slippage(slippage: Float64 = 0.0) -> FixedSlippage:
    return FixedSlippage(slippage=slippage)


def create_percent_slippage(percent: Float64 = 0.0) -> PercentSlippage:
    return PercentSlippage(percent=percent)


def create_volume_share_slippage(volume_share_limit: Float64 = 0.25, price_impact: Float64 = 0.1) -> VolumeShareSlippage:
    return VolumeShareSlippage(
        volume_share_limit=volume_share_limit,
        price_impact=price_impact
    )
