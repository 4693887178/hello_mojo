from rqmojo.const import EXECUTION_PHASE, RUN_TYPE, DEFAULT_ACCOUNT_TYPE, MATCHING_TYPE, ORDER_TYPE, ALGO, ORDER_STATUS, SIDE, POSITION_EFFECT, POSITION_DIRECTION, EXC_TYPE, INSTRUMENT_TYPE, PERSIST_MODE, COMMISSION_TYPE, EXIT_CODE, HEDGE_TYPE, EXCHANGE, TRADING_CALENDAR_TYPE, MARKET
from std.testing import assert_equal, assert_true

fn test_execution_phase_members() raises:
    var members = EXECUTION_PHASE.members()
    assert_equal(len(members), 9, "EXECUTION_PHASE should have 9 members")
    
    # Check that all expected members are present
    var member_names = ["GLOBAL", "ON_INIT", "BEFORE_TRADING", "OPEN_AUCTION", "ON_BAR", "ON_TICK", "AFTER_TRADING", "FINALIZED", "SCHEDULED"]
    for name in member_names:
        var found = False
        for member in members:
            if member.name == name:
                found = True
                break
        assert_true(found, "EXECUTION_PHASE should contain member " + name)

fn test_run_type_members() raises:
    var members = RUN_TYPE.members()
    assert_equal(len(members), 3, "RUN_TYPE should have 3 members")

fn test_default_account_type_members() raises:
    var members = DEFAULT_ACCOUNT_TYPE.members()
    assert_equal(len(members), 3, "DEFAULT_ACCOUNT_TYPE should have 3 members")

fn test_matching_type_members() raises:
    var members = MATCHING_TYPE.members()
    assert_equal(len(members), 7, "MATCHING_TYPE should have 7 members")

fn test_order_type_members() raises:
    var members = ORDER_TYPE.members()
    assert_equal(len(members), 3, "ORDER_TYPE should have 3 members")

fn test_algo_members() raises:
    var members = ALGO.members()
    assert_equal(len(members), 2, "ALGO should have 2 members")

fn test_order_status_members() raises:
    var members = ORDER_STATUS.members()
    assert_equal(len(members), 6, "ORDER_STATUS should have 6 members")

fn test_side_members() raises:
    var members = SIDE.members()
    assert_equal(len(members), 5, "SIDE should have 5 members")

fn test_position_effect_members() raises:
    var members = POSITION_EFFECT.members()
    assert_equal(len(members), 5, "POSITION_EFFECT should have 5 members")

fn test_position_direction_members() raises:
    var members = POSITION_DIRECTION.members()
    assert_equal(len(members), 2, "POSITION_DIRECTION should have 2 members")

fn test_exc_type_members() raises:
    var members = EXC_TYPE.members()
    assert_equal(len(members), 3, "EXC_TYPE should have 3 members")

fn test_instrument_type_members() raises:
    var members = INSTRUMENT_TYPE.members()
    assert_equal(len(members), 14, "INSTRUMENT_TYPE should have 14 members")

fn test_persist_mode_members() raises:
    var members = PERSIST_MODE.members()
    assert_equal(len(members), 3, "PERSIST_MODE should have 3 members")

fn test_commission_type_members() raises:
    var members = COMMISSION_TYPE.members()
    assert_equal(len(members), 2, "COMMISSION_TYPE should have 2 members")

fn test_exit_code_members() raises:
    var members = EXIT_CODE.members()
    assert_equal(len(members), 3, "EXIT_CODE should have 3 members")

fn test_hedge_type_members() raises:
    var members = HEDGE_TYPE.members()
    assert_equal(len(members), 3, "HEDGE_TYPE should have 3 members")

fn test_exchange_members() raises:
    var members = EXCHANGE.members()
    assert_equal(len(members), 9, "EXCHANGE should have 9 members")

fn test_trading_calendar_type_members() raises:
    var members = TRADING_CALENDAR_TYPE.members()
    assert_equal(len(members), 5, "TRADING_CALENDAR_TYPE should have 5 members")

fn test_market_members() raises:
    var members = MARKET.members()
    assert_equal(len(members), 2, "MARKET should have 2 members")

fn test_enum_functions() raises:
    # Test __getitem__
    var global_phase = EXECUTION_PHASE.__getitem__("GLOBAL")
    assert_true(global_phase != None, "__getitem__ should find GLOBAL")
    if global_phase:
        assert_equal(global_phase.value().name, "GLOBAL", "__getitem__ should return correct member")

    # Test __getitem__
    var backtest_run = RUN_TYPE.__getitem__("BACKTEST")
    assert_true(backtest_run != None, "__getitem__ should find BACKTEST")
    if backtest_run:
        assert_equal(backtest_run.value().name, "BACKTEST", "__getitem__ should return correct member")

    # Test contains
    assert_true(DEFAULT_ACCOUNT_TYPE.contains("STOCK"), "contains should find STOCK")
    assert_true(not RUN_TYPE.contains("STOCK"), "contains should not find STOCK in RUN_TYPE")

fn main() raises:
    test_execution_phase_members()
    test_run_type_members()
    test_default_account_type_members()
    test_matching_type_members()
    test_order_type_members()
    test_algo_members()
    test_order_status_members()
    test_side_members()
    test_position_effect_members()
    test_position_direction_members()
    test_exc_type_members()
    test_instrument_type_members()
    test_persist_mode_members()
    test_commission_type_members()
    test_exit_code_members()
    test_hedge_type_members()
    test_exchange_members()
    test_trading_calendar_type_members()
    test_market_members()
    test_enum_functions()
    print("All tests passed!")
