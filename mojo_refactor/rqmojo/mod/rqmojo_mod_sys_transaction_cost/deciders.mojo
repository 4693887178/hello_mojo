"""
RQAlpha Mojo - Transaction Cost Deciders
Ported from rqalpha/mod/rqalpha_mod_sys_transaction_cost/deciders.py
"""

from rqmojo.const import INSTRUMENT_TYPE, SIDE, POSITION_EFFECT, MARKET
from rqmojo.interface import TransactionCostArgs, TransactionCost
from rqmojo.model.instrument import Instrument


@fieldwise_init
struct StockTransactionCostDecider(Movable):
    var commission_multiplier: Float64
    var min_commission: Float64
    var stamp_tax_rate: Float64
    var transfer_fee_rate: Float64
    
    fn calc(self, args: TransactionCostArgs) -> TransactionCost:
        var commission = args.price * Float64(args.quantity) * self.commission_multiplier
        if commission < self.min_commission:
            commission = self.min_commission
        
        var tax = 0.0
        if args.side == SIDE.SELL():
            tax = args.price * Float64(args.quantity) * self.stamp_tax_rate
        
        var other_fees = args.price * Float64(args.quantity) * self.transfer_fee_rate
        
        return TransactionCost(
            commission=commission,
            tax=tax,
            other_fees=other_fees
        )


@fieldwise_init
struct FutureTransactionCostDecider(Movable):
    var commission_multiplier: Float64
    var close_commission_multiplier: Float64
    
    fn calc(self, args: TransactionCostArgs) -> TransactionCost:
        var multiplier = self.commission_multiplier
        if args.position_effect == POSITION_EFFECT.CLOSE() or args.position_effect == POSITION_EFFECT.CLOSE_TODAY():
            multiplier = self.close_commission_multiplier
        
        var commission = args.price * Float64(args.quantity) * multiplier
        return TransactionCost(
            commission=commission,
            tax=0.0,
            other_fees=0.0
        )


@fieldwise_init
struct BondTransactionCostDecider(Movable):
    var commission_multiplier: Float64
    
    fn calc(self, args: TransactionCostArgs) -> TransactionCost:
        var commission = args.price * Float64(args.quantity) * self.commission_multiplier
        return TransactionCost(
            commission=commission,
            tax=0.0,
            other_fees=0.0
        )


fn create_stock_decider(commission_multiplier: Float64 = 0.0003, min_commission: Float64 = 5.0, stamp_tax_rate: Float64 = 0.001, transfer_fee_rate: Float64 = 0.00002) -> StockTransactionCostDecider:
    return StockTransactionCostDecider(
        commission_multiplier=commission_multiplier,
        min_commission=min_commission,
        stamp_tax_rate=stamp_tax_rate,
        transfer_fee_rate=transfer_fee_rate
    )


fn create_future_decider(commission_multiplier: Float64 = 0.0001, close_commission_multiplier: Float64 = 0.0001) -> FutureTransactionCostDecider:
    return FutureTransactionCostDecider(
        commission_multiplier=commission_multiplier,
        close_commission_multiplier=close_commission_multiplier
    )


fn create_bond_decider(commission_multiplier: Float64 = 0.0001) -> BondTransactionCostDecider:
    return BondTransactionCostDecider(commission_multiplier=commission_multiplier)
