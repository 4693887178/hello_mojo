"""
RQAlpha Mojo - Testing Fixtures
Ported from rqalpha/utils/testing/fixtures.py
"""

from rqmojo.environment import Environment, create_environment
from rqmojo.const import RUN_TYPE, RUN_TYPE_BACKTEST, RUN_TYPE_BACKTEST
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.data.data_proxy import DataProxy, create_data_proxy


@fieldwise_init
struct BacktestFixture(Movable):
    var env: Environment
    var start_date: DateTime
    var end_date: DateTime
    
    fn setup(mut self) -> None:
        pass
    
    fn teardown(mut self) -> None:
        pass


fn create_backtest_fixture(start_date: DateTime = DateTime(2020, 1, 1, 0, 0, 0, 0), end_date: DateTime = DateTime(2020, 12, 31, 0, 0, 0, 0)) -> BacktestFixture:
    var env = create_environment(
        start_date=start_date,
        end_date=end_date,
        run_type=RUN_TYPE_BACKTEST
    )
    
    return BacktestFixture(
        env=env,
        start_date=start_date,
        end_date=end_date
    )


@fieldwise_init
struct DataProxyFixture(Movable):
    var data_proxy: DataProxy
    var start_date: DateTime
    var end_date: DateTime
    
    fn init_fixture(mut self) -> None:
        pass


fn create_data_proxy_fixture(start_date: DateTime = DateTime(2016, 1, 1, 0, 0, 0, 0), end_date: DateTime = DateTime(2023, 12, 28, 0, 0, 0, 0)) -> DataProxyFixture:
    var data_proxy = create_data_proxy()
    
    return DataProxyFixture(
        data_proxy=data_proxy^,
        start_date=start_date,
        end_date=end_date
    )


@fieldwise_init
struct RQAlphaTestCase(Movable):
    var _test_count: Int
    var _pass_count: Int
    
    fn init_fixture(mut self) -> None:
        pass
    
    fn assert_set_equal(mut self, set1: List[String], set2: List[String], test_name: String) -> None:
        self._test_count += 1
        
        if len(set1) != len(set2):
            print("FAIL: " + test_name + " - set sizes differ")
            return
        
        var matched = List[Bool]()
        for i in range(len(set2)):
            matched.append(False)
        
        for i in range(len(set1)):
            var found = False
            for j in range(len(set2)):
                if not matched[j] and set1[i] == set2[j]:
                    matched[j] = True
                    found = True
                    break
            if not found:
                print("FAIL: " + test_name + " - sets not equal")
                return
        
        self._pass_count += 1
        print("PASS: " + test_name)


fn create_rqalpha_test_case() -> RQAlphaTestCase:
    return RQAlphaTestCase(_test_count=0, _pass_count=0)
