"""
Test Transaction Cost Deciders
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider
from rqmojo.interface import TransactionCostArgs, TransactionCost
from rqmojo.const import SIDE, POSITION_EFFECT, INSTRUMENT_TYPE
from std import Float64, Int
from std.testing import assert_equal, assert_approx_equal

@test
def test_stock_decider_buy():
    """测试股票买入交易成本"""
    var decider = StockTransactionCostDecider(
        stock_commission_multiplier=1.0,
        tax_multiplier=1.0,
        stock_min_commission=5.0,
        pit_tax=False
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=100,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0,
        instrument_type=INSTRUMENT_TYPE.CS,
        instrument=None
    )
    
    var cost = decider.calc(args)
    # 买入时：佣金 = 10 * 100 * 0.0008 = 0.8，低于最低佣金5元，所以佣金为5元；税费为0
    assert_approx_equal(cost.commission, 5.0)
    assert_approx_equal(cost.tax, 0.0)
    assert_approx_equal(cost.other_fees, 0.0)
    assert_approx_equal(cost.total(), 5.0)

@test
def test_stock_decider_sell():
    """测试股票卖出交易成本"""
    var decider = StockTransactionCostDecider(
        stock_commission_multiplier=1.0,
        tax_multiplier=1.0,
        stock_min_commission=5.0,
        pit_tax=False
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=10000,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=1,
        close_today_quantity=0,
        instrument_type=INSTRUMENT_TYPE.CS,
        instrument=None
    )
    
    var cost = decider.calc(args)
    # 卖出时：佣金 = 10 * 10000 * 0.0008 = 80元；税费 = 10 * 10000 * 0.0005 = 50元
    assert_approx_equal(cost.commission, 80.0)
    assert_approx_equal(cost.tax, 50.0)
    assert_approx_equal(cost.other_fees, 0.0)
    assert_approx_equal(cost.total(), 130.0)

@test
def test_stock_decider_with_multiplier():
    """测试带倍率的股票交易成本"""
    var decider = StockTransactionCostDecider(
        stock_commission_multiplier=2.0,
        tax_multiplier=0.5,
        stock_min_commission=5.0,
        pit_tax=False
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=10000,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=1,
        close_today_quantity=0,
        instrument_type=INSTRUMENT_TYPE.CS,
        instrument=None
    )
    
    var cost = decider.calc(args)
    # 佣金倍率2.0：80 * 2 = 160元；税费倍率0.5：50 * 0.5 = 25元
    assert_approx_equal(cost.commission, 160.0)
    assert_approx_equal(cost.tax, 25.0)
    assert_approx_equal(cost.total(), 185.0)

@test
def test_future_decider():
    """测试期货交易成本"""
    var decider = FutureTransactionCostDecider(
        futures_commission_multiplier=1.0
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="IF2103.CFFEX",
        price=4000.0,
        quantity=1,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0,
        instrument_type=INSTRUMENT_TYPE.FUTURE,
        instrument=None
    )
    
    var cost = decider.calc(args)
    # 期货交易：佣金 = 4000 * 1 * 0.0001 = 0.4元
    assert_approx_equal(cost.commission, 0.4)
    assert_approx_equal(cost.tax, 0.0)
    assert_approx_equal(cost.other_fees, 0.0)
    assert_approx_equal(cost.total(), 0.4)

@test
def test_future_decider_with_multiplier():
    """测试带倍率的期货交易成本"""
    var decider = FutureTransactionCostDecider(
        futures_commission_multiplier=1.5
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="IF2103.CFFEX",
        price=4000.0,
        quantity=1,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0,
        instrument_type=INSTRUMENT_TYPE.FUTURE,
        instrument=None
    )
    
    var cost = decider.calc(args)
    # 佣金倍率1.5：0.4 * 1.5 = 0.6元
    assert_approx_equal(cost.commission, 0.6)
    assert_approx_equal(cost.total(), 0.6)

@test
def test_bond_decider():
    """测试债券交易成本"""
    var decider = BondTransactionCostDecider(
        bond_commission_multiplier=1.0
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="110030.SH",
        price=100.0,
        quantity=10,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0,
        instrument_type=INSTRUMENT_TYPE.BOND,
        instrument=None
    )
    
    var cost = decider.calc(args)
    # 债券交易：佣金 = 100 * 10 * 0.0001 = 0.1元
    assert_approx_equal(cost.commission, 0.1)
    assert_approx_equal(cost.tax, 0.0)
    assert_approx_equal(cost.other_fees, 0.0)
    assert_approx_equal(cost.total(), 0.1)

@test
def test_transaction_cost_total():
    """测试交易成本总计"""
    var cost = TransactionCost(commission=10.0, tax=5.0, other_fees=2.0)
    assert_approx_equal(cost.total(), 17.0)

@test
def test_transaction_cost_zero():
    """测试零交易成本"""
    var cost = TransactionCost.zero()
    assert_approx_equal(cost.commission, 0.0)
    assert_approx_equal(cost.tax, 0.0)
    assert_approx_equal(cost.other_fees, 0.0)
    assert_approx_equal(cost.total(), 0.0)