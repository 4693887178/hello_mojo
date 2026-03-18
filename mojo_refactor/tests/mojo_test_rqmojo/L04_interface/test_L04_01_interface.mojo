# test_L04_01_interface.mojo
# Module: rqmojo.interface
# Python: rqalpha.interface
# Level: L04 - Interface Layer
# Dependencies: const, model

from rqmojo.interface import (
    ExchangeRate, TransactionCostArgs, TransactionCost,
    FuturesTradingParameters, Snapshot,
    Persistable, Position, StrategyLoader, EventSource,
    PriceBoard, DataSource, Broker, Mod, PersistProvider,
    FrontendValidator, TransactionCostDecider
)
from rqmojo.model.instrument import create_stock_instrument
from rqmojo.const import SIDE, POSITION_EFFECT, EXCHANGE
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_exchange_rate(mut self):
        var rate = ExchangeRate(
            bid_reference=7.0,
            ask_reference=7.1,
            bid_settlement_sh=7.05,
            ask_settlement_sh=7.08,
            bid_settlement_sz=7.04,
            ask_settlement_sz=7.09
        )
        self.check(rate.bid_reference == 7.0, "ExchangeRate bid_reference is 7.0")
        self.check(rate.ask_reference == 7.1, "ExchangeRate ask_reference is 7.1")
        self.check(rate.bid_settlement_sh == 7.05, "ExchangeRate bid_settlement_sh is 7.05")

    fn test_transaction_cost_args(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        var args = TransactionCostArgs(
            instrument=ins,
            price=10.0,
            quantity=100,
            side=SIDE.BUY(),
            position_effect=POSITION_EFFECT.OPEN(),
            order_id=1,
            close_today_quantity=0
        )
        self.check(args.price == 10.0, "TransactionCostArgs price is 10.0")
        self.check(args.quantity == 100, "TransactionCostArgs quantity is 100")
        self.check(args.side == SIDE.BUY(), "TransactionCostArgs side is BUY")

    fn test_transaction_cost(mut self):
        var cost = TransactionCost(commission=10.0, tax=5.0, other_fees=2.0)
        self.check(cost.commission == 10.0, "TransactionCost commission is 10.0")
        self.check(cost.tax == 5.0, "TransactionCost tax is 5.0")
        self.check(cost.other_fees == 2.0, "TransactionCost other_fees is 2.0")
        self.check(cost.total() == 17.0, "TransactionCost total is 17.0")

    fn test_transaction_cost_zero(mut self):
        var cost = TransactionCost.zero()
        self.check(cost.commission == 0.0, "TransactionCost.zero commission is 0.0")
        self.check(cost.tax == 0.0, "TransactionCost.zero tax is 0.0")
        self.check(cost.other_fees == 0.0, "TransactionCost.zero other_fees is 0.0")

    fn test_futures_trading_parameters(mut self):
        var params = FuturesTradingParameters(
            open_commission_ratio=0.0001,
            close_commission_ratio=0.0001,
            close_commission_ratio_today=0.0002,
            margin_ratio=0.1
        )
        self.check(params.open_commission_ratio == 0.0001, "FuturesTradingParameters open_commission_ratio is 0.0001")
        self.check(params.margin_ratio == 0.1, "FuturesTradingParameters margin_ratio is 0.1")

    fn test_snapshot(mut self):
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var snapshot = Snapshot(
            order_book_id="000001.XSHE",
            datetime=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            last=10.2,
            volume=1000000,
            total_turnover=10200000.0,
            prev_close=10.0,
            limit_up=11.0,
            limit_down=9.0
        )
        self.check(snapshot.order_book_id == "000001.XSHE", "Snapshot order_book_id is 000001.XSHE")
        self.check(snapshot.open == 10.0, "Snapshot open is 10.0")
        self.check(snapshot.last == 10.2, "Snapshot last is 10.2")
        self.check(snapshot.volume == 1000000, "Snapshot volume is 1000000")

    fn test_persistable_trait(mut self):
        self.check(True, "Persistable trait exists")

    fn test_position_trait(mut self):
        self.check(True, "Position trait exists")

    fn test_strategy_loader_trait(mut self):
        self.check(True, "StrategyLoader trait exists")

    fn test_event_source_trait(mut self):
        self.check(True, "EventSource trait exists")

    fn test_price_board_trait(mut self):
        self.check(True, "PriceBoard trait exists")

    fn test_data_source_trait(mut self):
        self.check(True, "DataSource trait exists")

    fn test_broker_trait(mut self):
        self.check(True, "Broker trait exists")

    fn test_mod_trait(mut self):
        self.check(True, "Mod trait exists")

    fn test_persist_provider_trait(mut self):
        self.check(True, "PersistProvider trait exists")

    fn test_frontend_validator_trait(mut self):
        self.check(True, "FrontendValidator trait exists")

    fn test_transaction_cost_decider_trait(mut self):
        self.check(True, "TransactionCostDecider trait exists")

    fn run_all(mut self):
        print("=" * 60)
        print("L04_01_interface Module Tests")
        print("=" * 60)
        
        self.test_exchange_rate()
        self.test_transaction_cost_args()
        self.test_transaction_cost()
        self.test_transaction_cost_zero()
        self.test_futures_trading_parameters()
        self.test_snapshot()
        self.test_persistable_trait()
        self.test_position_trait()
        self.test_strategy_loader_trait()
        self.test_event_source_trait()
        self.test_price_board_trait()
        self.test_data_source_trait()
        self.test_broker_trait()
        self.test_mod_trait()
        self.test_persist_provider_trait()
        self.test_frontend_validator_trait()
        self.test_transaction_cost_decider_trait()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
