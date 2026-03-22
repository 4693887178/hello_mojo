"""
RQAlpha Mojo - Test PT Example
Ported from rqalpha/examples/test_pt.py
"""

from rqmojo.apis import *
from python import time
from python import talib


def init(context: object) -> None:
    context.s1 = "000001.XSHE"
    context.SHORTPERIOD = 20
    context.LONGPERIOD = 120
    context.count = 0
    print("init")


def before_trading(context: object) -> None:
    print("before_trading {}", context.count)
    time.sleep(1)


def handle_bar(context: object, bar_dict: object) -> None:
    print("handle_bar {}", context.count)
    context.count += 1
    
    print("{} {}", context.count, bar_dict["000001.XSHE"].close)
    print("{} {}", context.count, bar_dict["000001.XSHG"].close)
    
    print("{}", current_snapshot("000001.XSHE").last)
    print("{}", current_snapshot("000001.XSHG").last)
    
    order_shares("000001.XSHE", 100)
    order_shares("000001.XSHE", -100)
    print("{}", context.portfolio)
    print("{}", get_positions())


def after_trading(context: object) -> None:
    print("after_trading {}", context.count)
