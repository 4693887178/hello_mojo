"""
RQAlpha Mojo - Subscribe Event Example
Ported from rqalpha/examples/subscribe_event.py
"""

from rqmojo.apis import *


def on_trade_handler(event: object) -> None:
    var trade = event.trade
    var order = event.order
    var account = event.account
    log.info("********** Trade Handler **********")
    log.info("{}", trade)
    log.info("{}", order)
    log.info("{}", account)


def on_order_handler(event: object) -> None:
    var order = event.order
    log.info("********** Order Handler **********")
    log.info("{}", order)


def init(context: object) -> None:
    log.info("init")
    context.s1 = "000001.XSHE"
    update_universe(context.s1)
    context.fired = False
    subscribe_event(EVENT.TRADE, on_trade_handler)
    subscribe_event(EVENT.ORDER_CREATION_PASS, on_order_handler)


def before_trading(context: object) -> None:
    pass


def handle_bar(context: object, bar_dict: object) -> None:
    if not context.fired:
        order_percent(context.s1, 1.0)
        context.fired = True
