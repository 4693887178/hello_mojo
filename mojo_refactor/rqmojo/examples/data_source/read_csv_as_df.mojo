"""
RQAlpha Mojo - Read CSV as DataFrame Example
Ported from rqalpha/examples/data_source/read_csv_as_df.py
"""

from rqmojo.apis import *
from python import os
from python import pandas as pd


fn read_csv_as_df(csv_path: String) -> object:
    var data = pd.read_csv(csv_path)
    return data


fn init(context: object) -> None:
    var strategy_file_path = context.config.base.strategy_file
    var csv_path = os.path.join(os.path.dirname(strategy_file_path), "../IF1706_20161108.csv")
    var IF1706_df = read_csv_as_df(csv_path)
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
