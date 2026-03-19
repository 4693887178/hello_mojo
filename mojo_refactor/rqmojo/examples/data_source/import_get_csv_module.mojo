"""
RQAlpha Mojo - Import Get CSV Module Example
Ported from rqalpha/examples/data_source/import_get_csv_module.py
"""

from rqmojo.apis import *
from python import os
from python import sys
from .get_csv_module import get_csv


fn init(context: object) -> None:
    var strategy_file_path = context.config.base.strategy_file
    sys.path.append(os.path.realpath(os.path.dirname(strategy_file_path)))
    
    var IF1706_df = get_csv()
    context.IF1706_df = IF1706_df


fn before_trading(context: object) -> None:
    log.info("{}", context.IF1706_df)


alias __config__ = {
    "base": {
        "start_date": "2015-01-09",
        "end_date": "2015-01-10",
        "frequency": "1d",
        "matching_type": "current_bar",
        "benchmark": None,
        "accounts": {
            "future": 1000000
        }
    },
    "extra": {
        "log_level": "verbose",
    },
}
