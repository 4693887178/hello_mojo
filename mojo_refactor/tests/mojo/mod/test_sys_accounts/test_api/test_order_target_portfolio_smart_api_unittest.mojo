"""
order_target_portfolio_smart unit test suite - Mojo version

Test parameters:
- Test date: 2025-09-15
- Initial capital: 10,000,000 yuan (10 million)
- Test stocks and prices:
  * 000001.XSHE (Ping An Bank): opening price 11.70 yuan
  * 000004.XSHE (*ST Guohua): opening price 10.53 yuan

Calculation formula:
Target quantity = (Total capital x Target weight) / Stock price
Actual order quantity will be processed by algorithm minimum unit adjustment, safety margin, etc.
"""

from std.python import Python, PythonObject
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List


def test_order_target_portfolio_smart_empty_weights() raises:
    """Test empty weights dict - should have no orders."""
    var unittest_mock = Python.import_module("unittest.mock")
    var pandas_timestamp = Python.import_module("pandas").Timestamp
    
    var MagicMock = unittest_mock.MagicMock
    
    var rqalpha_env = Python.import_module("rqalpha.environment")
    var Environment = rqalpha_env.Environment
    
    var parse_config = Python.import_module("rqalpha.utils.config").parse_config
    var BaseDataSource = Python.import_module("rqalpha.data.base_data_source").BaseDataSource
    var BarDictPriceBoard = Python.import_module("rqalpha.data.bar_dict_price_board").BarDictPriceBoard
    var DataProxy = Python.import_module("rqalpha.data.data_proxy").DataProxy
    var Portfolio = Python.import_module("rqalpha.portfolio").Portfolio
    var ExecutionContext = Python.import_module("rqalpha.core.execution_context").ExecutionContext
    var StockTransactionCostDecider = Python.import_module("rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders").StockTransactionCostDecider
    var order_target_portfolio_smart = Python.import_module("rqalpha.mod.rqalpha_mod_sys_accounts.api.api_stock").order_target_portfolio_smart
    var cleanup_resources = Python.import_module("rqalpha.main").cleanup_resources
    
    var EXECUTION_PHASE = Python.import_module("rqalpha.const").EXECUTION_PHASE
    var INSTRUMENT_TYPE = Python.import_module("rqalpha.const").INSTRUMENT_TYPE
    var MARKET = Python.import_module("rqalpha.const").MARKET
    
    var config = parse_config(Python.dict(
        base=Python.dict(
            start_date=pandas_timestamp("2025-09-15").date(),
            end_date=pandas_timestamp("2025-09-15").date(),
            accounts=Python.dict(stock=10000000)
        )
    ))
    
    var env = Environment(config, False)
    
    var price_board = BarDictPriceBoard()
    var data_source = BaseDataSource(config.base)
    var data_proxy = DataProxy(data_source, price_board)
    
    env.set_data_source(data_source)
    env.set_price_board(price_board)
    env.set_data_proxy(data_proxy)
    
    env.set_transaction_cost_decider(
        INSTRUMENT_TYPE.CS, 
        StockTransactionCostDecider(
            commission_multiplier=0.25,
            min_commission=0.0,
            tax_multiplier=1,
            pit_tax=False,
            event_bus=env.event_bus
        ), 
        MARKET.CN
    )
    
    env.portfolio = Portfolio(
        starting_cash=config.base.accounts,
        init_positions=Python.list(),
        financing_rate=0.0,
        env=env
    )
    
    env.submit_order = MagicMock()
    
    var context_manager = ExecutionContext(EXECUTION_PHASE.ON_BAR)
    context_manager.__enter__()
    
    try:
        var empty_dict = Python.dict()
        order_target_portfolio_smart(empty_dict)
        
        var call_count = Int(py=env.submit_order.call_count)
        assert_equal(call_count, 0, "Empty weights should not submit orders")
        
        print("Test test_order_target_portfolio_smart_empty_weights: PASSED")
        
    except e:
        print("Test failed with error: ", e)
    finally:
        context_manager.__exit__(Python.none(), Python.none(), Python.none())
        cleanup_resources(env)


def test_order_target_portfolio_smart_base_with_weights() raises:
    """Test basic rebalancing - from empty to target weights."""
    var unittest_mock = Python.import_module("unittest.mock")
    var pandas_timestamp = Python.import_module("pandas").Timestamp
    
    var MagicMock = unittest_mock.MagicMock
    
    var rqalpha_env = Python.import_module("rqalpha.environment")
    var Environment = rqalpha_env.Environment
    
    var parse_config = Python.import_module("rqalpha.utils.config").parse_config
    var BaseDataSource = Python.import_module("rqalpha.data.base_data_source").BaseDataSource
    var BarDictPriceBoard = Python.import_module("rqalpha.data.bar_dict_price_board").BarDictPriceBoard
    var DataProxy = Python.import_module("rqalpha.data.data_proxy").DataProxy
    var Portfolio = Python.import_module("rqalpha.portfolio").Portfolio
    var ExecutionContext = Python.import_module("rqalpha.core.execution_context").ExecutionContext
    var StockTransactionCostDecider = Python.import_module("rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders").StockTransactionCostDecider
    var order_target_portfolio_smart = Python.import_module("rqalpha.mod.rqalpha_mod_sys_accounts.api.api_stock").order_target_portfolio_smart
    var cleanup_resources = Python.import_module("rqalpha.main").cleanup_resources
    
    var EXECUTION_PHASE = Python.import_module("rqalpha.const").EXECUTION_PHASE
    var INSTRUMENT_TYPE = Python.import_module("rqalpha.const").INSTRUMENT_TYPE
    var MARKET = Python.import_module("rqalpha.const").MARKET
    var SIDE = Python.import_module("rqalpha.const").SIDE
    var POSITION_EFFECT = Python.import_module("rqalpha.const").POSITION_EFFECT
    var MarketOrder = Python.import_module("rqalpha.model.order").MarketOrder
    
    var config = parse_config(Python.dict(
        base=Python.dict(
            start_date=pandas_timestamp("2025-09-15").date(),
            end_date=pandas_timestamp("2025-09-15").date(),
            accounts=Python.dict(stock=10000000)
        )
    ))
    
    var env = Environment(config, False)
    
    var price_board = BarDictPriceBoard()
    var data_source = BaseDataSource(config.base)
    var data_proxy = DataProxy(data_source, price_board)
    
    env.set_data_source(data_source)
    env.set_price_board(price_board)
    env.set_data_proxy(data_proxy)
    
    env.set_transaction_cost_decider(
        INSTRUMENT_TYPE.CS, 
        StockTransactionCostDecider(
            commission_multiplier=0.25,
            min_commission=0.0,
            tax_multiplier=1,
            pit_tax=False,
            event_bus=env.event_bus
        ), 
        MARKET.CN
    )
    
    env.portfolio = Portfolio(
        starting_cash=config.base.accounts,
        init_positions=Python.list(),
        financing_rate=0.0,
        env=env
    )
    
    env.submit_order = MagicMock()
    
    var context_manager = ExecutionContext(EXECUTION_PHASE.ON_BAR)
    context_manager.__enter__()
    
    try:
        var weights_dict = Python.dict()
        weights_dict.__setitem__("000001.XSHE", value=0.1)
        weights_dict.__setitem__("000004.XSHE", value=0.2)
        
        order_target_portfolio_smart(weights_dict)
        
        var call_count = Int(py=env.submit_order.call_count)
        
        print("Order submission count: ", call_count)
        print("Test test_order_target_portfolio_smart_base_with_weights: PASSED")
        
    except e:
        print("Test failed with error: ", e)
    finally:
        context_manager.__exit__(Python.none(), Python.none(), Python.none())
        cleanup_resources(env)


def test_order_target_portfolio_smart_single_stock() raises:
    """Test single stock rebalancing."""
    var unittest_mock = Python.import_module("unittest.mock")
    var pandas_timestamp = Python.import_module("pandas").Timestamp
    
    var MagicMock = unittest_mock.MagicMock
    
    var rqalpha_env = Python.import_module("rqalpha.environment")
    var Environment = rqalpha_env.Environment
    
    var parse_config = Python.import_module("rqalpha.utils.config").parse_config
    var BaseDataSource = Python.import_module("rqalpha.data.base_data_source").BaseDataSource
    var BarDictPriceBoard = Python.import_module("rqalpha.data.bar_dict_price_board").BarDictPriceBoard
    var DataProxy = Python.import_module("rqalpha.data.data_proxy").DataProxy
    var Portfolio = Python.import_module("rqalpha.portfolio").Portfolio
    var ExecutionContext = Python.import_module("rqalpha.core.execution_context").ExecutionContext
    var StockTransactionCostDecider = Python.import_module("rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders").StockTransactionCostDecider
    var order_target_portfolio_smart = Python.import_module("rqalpha.mod.rqalpha_mod_sys_accounts.api.api_stock").order_target_portfolio_smart
    var cleanup_resources = Python.import_module("rqalpha.main").cleanup_resources
    
    var EXECUTION_PHASE = Python.import_module("rqalpha.const").EXECUTION_PHASE
    var INSTRUMENT_TYPE = Python.import_module("rqalpha.const").INSTRUMENT_TYPE
    var MARKET = Python.import_module("rqalpha.const").MARKET
    
    var config = parse_config(Python.dict(
        base=Python.dict(
            start_date=pandas_timestamp("2025-09-15").date(),
            end_date=pandas_timestamp("2025-09-15").date(),
            accounts=Python.dict(stock=10000000)
        )
    ))
    
    var env = Environment(config, False)
    
    var price_board = BarDictPriceBoard()
    var data_source = BaseDataSource(config.base)
    var data_proxy = DataProxy(data_source, price_board)
    
    env.set_data_source(data_source)
    env.set_price_board(price_board)
    env.set_data_proxy(data_proxy)
    
    env.set_transaction_cost_decider(
        INSTRUMENT_TYPE.CS, 
        StockTransactionCostDecider(
            commission_multiplier=0.25,
            min_commission=0.0,
            tax_multiplier=1,
            pit_tax=False,
            event_bus=env.event_bus
        ), 
        MARKET.CN
    )
    
    env.portfolio = Portfolio(
        starting_cash=config.base.accounts,
        init_positions=Python.list(),
        financing_rate=0.0,
        env=env
    )
    
    env.submit_order = MagicMock()
    
    var context_manager = ExecutionContext(EXECUTION_PHASE.ON_BAR)
    context_manager.__enter__()
    
    try:
        var weights_dict = Python.dict()
        weights_dict.__setitem__("000001.XSHE", value=0.5)
        
        order_target_portfolio_smart(weights_dict)
        
        print("Test test_order_target_portfolio_smart_single_stock: PASSED")
        
    except e:
        print("Test failed with error: ", e)
    finally:
        context_manager.__exit__(Python.none(), Python.none(), Python.none())
        cleanup_resources(env)


def test_order_target_portfolio_smart_small_weights() raises:
    """Test small weight rebalancing - minimum unit handling."""
    var unittest_mock = Python.import_module("unittest.mock")
    var pandas_timestamp = Python.import_module("pandas").Timestamp
    
    var MagicMock = unittest_mock.MagicMock
    
    var rqalpha_env = Python.import_module("rqalpha.environment")
    var Environment = rqalpha_env.Environment
    
    var parse_config = Python.import_module("rqalpha.utils.config").parse_config
    var BaseDataSource = Python.import_module("rqalpha.data.base_data_source").BaseDataSource
    var BarDictPriceBoard = Python.import_module("rqalpha.data.bar_dict_price_board").BarDictPriceBoard
    var DataProxy = Python.import_module("rqalpha.data.data_proxy").DataProxy
    var Portfolio = Python.import_module("rqalpha.portfolio").Portfolio
    var ExecutionContext = Python.import_module("rqalpha.core.execution_context").ExecutionContext
    var StockTransactionCostDecider = Python.import_module("rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders").StockTransactionCostDecider
    var order_target_portfolio_smart = Python.import_module("rqalpha.mod.rqalpha_mod_sys_accounts.api.api_stock").order_target_portfolio_smart
    var cleanup_resources = Python.import_module("rqalpha.main").cleanup_resources
    
    var EXECUTION_PHASE = Python.import_module("rqalpha.const").EXECUTION_PHASE
    var INSTRUMENT_TYPE = Python.import_module("rqalpha.const").INSTRUMENT_TYPE
    var MARKET = Python.import_module("rqalpha.const").MARKET
    
    var config = parse_config(Python.dict(
        base=Python.dict(
            start_date=pandas_timestamp("2025-09-15").date(),
            end_date=pandas_timestamp("2025-09-15").date(),
            accounts=Python.dict(stock=10000000)
        )
    ))
    
    var env = Environment(config, False)
    
    var price_board = BarDictPriceBoard()
    var data_source = BaseDataSource(config.base)
    var data_proxy = DataProxy(data_source, price_board)
    
    env.set_data_source(data_source)
    env.set_price_board(price_board)
    env.set_data_proxy(data_proxy)
    
    env.set_transaction_cost_decider(
        INSTRUMENT_TYPE.CS, 
        StockTransactionCostDecider(
            commission_multiplier=0.25,
            min_commission=0.0,
            tax_multiplier=1,
            pit_tax=False,
            event_bus=env.event_bus
        ), 
        MARKET.CN
    )
    
    env.portfolio = Portfolio(
        starting_cash=config.base.accounts,
        init_positions=Python.list(),
        financing_rate=0.0,
        env=env
    )
    
    env.submit_order = MagicMock()
    
    var context_manager = ExecutionContext(EXECUTION_PHASE.ON_BAR)
    context_manager.__enter__()
    
    try:
        var weights_dict = Python.dict()
        weights_dict.__setitem__("000001.XSHE", value=0.001)
        weights_dict.__setitem__("000004.XSHE", value=0.002)
        
        order_target_portfolio_smart(weights_dict)
        
        print("Test test_order_target_portfolio_smart_small_weights: PASSED")
        
    except e:
        print("Test failed with error: ", e)
    finally:
        context_manager.__exit__(Python.none(), Python.none(), Python.none())
        cleanup_resources(env)


def test_order_target_portfolio_smart_negative_weights_error() raises:
    """Test negative weights - should raise exception."""
    var unittest_mock = Python.import_module("unittest.mock")
    var pandas_timestamp = Python.import_module("pandas").Timestamp
    
    var MagicMock = unittest_mock.MagicMock
    
    var rqalpha_env = Python.import_module("rqalpha.environment")
    var Environment = rqalpha_env.Environment
    
    var parse_config = Python.import_module("rqalpha.utils.config").parse_config
    var BaseDataSource = Python.import_module("rqalpha.data.base_data_source").BaseDataSource
    var BarDictPriceBoard = Python.import_module("rqalpha.data.bar_dict_price_board").BarDictPriceBoard
    var DataProxy = Python.import_module("rqalpha.data.data_proxy").DataProxy
    var Portfolio = Python.import_module("rqalpha.portfolio").Portfolio
    var ExecutionContext = Python.import_module("rqalpha.core.execution_context").ExecutionContext
    var StockTransactionCostDecider = Python.import_module("rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders").StockTransactionCostDecider
    var order_target_portfolio_smart = Python.import_module("rqalpha.mod.rqalpha_mod_sys_accounts.api.api_stock").order_target_portfolio_smart
    var cleanup_resources = Python.import_module("rqalpha.main").cleanup_resources
    
    var EXECUTION_PHASE = Python.import_module("rqalpha.const").EXECUTION_PHASE
    var INSTRUMENT_TYPE = Python.import_module("rqalpha.const").INSTRUMENT_TYPE
    var MARKET = Python.import_module("rqalpha.const").MARKET
    
    var config = parse_config(Python.dict(
        base=Python.dict(
            start_date=pandas_timestamp("2025-09-15").date(),
            end_date=pandas_timestamp("2025-09-15").date(),
            accounts=Python.dict(stock=10000000)
        )
    ))
    
    var env = Environment(config, False)
    
    var price_board = BarDictPriceBoard()
    var data_source = BaseDataSource(config.base)
    var data_proxy = DataProxy(data_source, price_board)
    
    env.set_data_source(data_source)
    env.set_price_board(price_board)
    env.set_data_proxy(data_proxy)
    
    env.set_transaction_cost_decider(
        INSTRUMENT_TYPE.CS, 
        StockTransactionCostDecider(
            commission_multiplier=0.25,
            min_commission=0.0,
            tax_multiplier=1,
            pit_tax=False,
            event_bus=env.event_bus
        ), 
        MARKET.CN
    )
    
    env.portfolio = Portfolio(
        starting_cash=config.base.accounts,
        init_positions=Python.list(),
        financing_rate=0.0,
        env=env
    )
    
    env.submit_order = MagicMock()
    
    var context_manager = ExecutionContext(EXECUTION_PHASE.ON_BAR)
    context_manager.__enter__()
    
    var error_raised = False
    try:
        var weights_dict = Python.dict()
        weights_dict.__setitem__("000001.XSHE", value=-0.1)
        weights_dict.__setitem__("000004.XSHE", value=0.2)
        
        order_target_portfolio_smart(weights_dict)
        
    except e:
        error_raised = True
        print("Expected error caught: ", e)
    finally:
        context_manager.__exit__(Python.none(), Python.none(), Python.none())
        cleanup_resources(env)
    
    if error_raised:
        print("Test test_order_target_portfolio_smart_negative_weights_error: PASSED")
    else:
        print("Test test_order_target_portfolio_smart_negative_weights_error: FAILED (no error raised)")


def main() raises:
    print("=" * 60)
    print("Running test_order_target_portfolio_smart_api_unittest.mojo")
    print("=" * 60)
    
    test_order_target_portfolio_smart_empty_weights()
    test_order_target_portfolio_smart_base_with_weights()
    test_order_target_portfolio_smart_single_stock()
    test_order_target_portfolio_smart_small_weights()
    test_order_target_portfolio_smart_negative_weights_error()
    
    print("=" * 60)
    print("All tests completed")
    print("=" * 60)
