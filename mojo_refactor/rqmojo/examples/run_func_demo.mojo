"""
RQAlpha Mojo - Run Func Demo Example
Ported from rqalpha/examples/run_func_demo.py
"""

from rqmojo.apis import *
from rqmojo import run_func


fn init(context: object) -> None:
    log.info("init")
    context.s1 = "000001.XSHE"
    update_universe(context.s1)
    context.fired = False


fn before_trading(context: object) -> None:
    pass


fn handle_bar(context: object, bar_dict: object) -> None:
    if not context.fired:
        order_percent(context.s1, 1.0)
        context.fired = True


fn main() -> None:
    var config = {
        "base": {
            "start_date": "2016-06-01",
            "end_date": "2016-12-01",
            "benchmark": "000300.XSHG",
            "accounts": {
                "stock": 100000
            }
        },
        "extra": {
            "log_level": "verbose",
        },
        "mod": {
            "sys_analyser": {
                "enabled": True,
                "plot": True
            }
        }
    }
    
    run_func(init=init, before_trading=before_trading, handle_bar=handle_bar, config=config)
