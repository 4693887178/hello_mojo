"""
Mojo Test for data/__init__.mojo
Tests the data package exports
"""

from rqmojo.data import DataProxy
from rqmojo.data import DividendInfo, SplitInfo, Snapshot
from rqmojo.data import create_data_proxy


def test_data_proxy_import():
    var proxy = create_data_proxy()
    print("DataProxy created successfully")
    assert True


def test_dividend_info_import():
    var di = DividendInfo(
        book_closure_date=20231215,
        announcement_date=20231210,
        dividend_cash_before_tax=0.5,
        ex_dividend_date=20231216,
        payable_date=20231220,
        round_lot=10
    )
    print("DividendInfo created: " + di.__str__())
    assert True


def test_split_info_import():
    var si = SplitInfo(ex_date=20230515, split_factor=1.5)
    print("SplitInfo created: " + si.__str__())
    assert True


def main():
    print("=== Testing data/__init__.mojo ===")
    test_data_proxy_import()
    test_dividend_info_import()
    test_split_info_import()
    print("All data/__init__ tests passed!")
