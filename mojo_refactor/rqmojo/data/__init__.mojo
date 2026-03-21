"""
RQAlpha Mojo - Data Package
Ported from rqalpha/data/__init__.py

This module provides data access functionality including:
- DataProxy: Main data access interface
"""

from . import data_proxy

from .data_proxy import DataProxy

from .data_proxy import (
    DividendInfo,
    SplitInfo,
    Snapshot,
    OpenAuctionBar,
    YieldCurvePoint,
    create_data_proxy,
    create_data_proxy_with_name,
    create_dividend_info,
    create_split_info,
    create_snapshot,
    create_open_auction_bar,
)
