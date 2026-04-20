"""
RQAlpha Mojo - Run Code Demo Example
Ported from rqalpha/examples/run_code_demo.py
"""

from rqmojo import run_code


def main() -> None:
    var code = """
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
"""
    
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
                "plot": False
            }
        }
    }
    
    run_code(code, config)
