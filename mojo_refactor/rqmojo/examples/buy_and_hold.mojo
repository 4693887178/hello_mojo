"""
RQAlpha Mojo - Buy and Hold Strategy Example
Ported from rqalpha/examples/buy_and_hold.py
"""

from rqmojo.apis import *


def init(context: object) -> None:
    log.info("init")
    context.s1 = "000001.XSHE"
    update_universe(context.s1)
    context.fired = False


def before_trading(context: object) -> None:
    pass


def handle_bar(context: object, bar_dict: object) -> None:
    if not context.fired:
        order_percent(context.s1, 1.0)
        context.fired = True
