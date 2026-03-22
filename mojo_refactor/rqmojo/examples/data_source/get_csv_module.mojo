"""
RQAlpha Mojo - Get CSV Module
Ported from rqalpha/examples/data_source/get_csv_module.py
"""

from python import os
from python import pandas as pd


def read_csv_as_df(csv_path: String) -> object:
    var data = pd.read_csv(csv_path)
    return data


def get_csv() -> object:
    var csv_path = os.path.join(os.path.dirname(__file__), "../IF1706_20161108.csv")
    return read_csv_as_df(csv_path)
