"""
RQAlpha Mojo - Run File Demo Example
Ported from rqalpha/examples/run_file_demo.py
"""

from rqmojo import run_file


def main() -> None:
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
    
    var strategy_file_path = "./buy_and_hold.mojo"
    run_file(strategy_file_path, config)
