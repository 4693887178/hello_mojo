"""
RQAlpha Mojo - Transaction Cost Deciders
Ported from rqalpha/mod/rqalpha_mod_sys_transaction_cost/deciders.py

Python original provides:
  - AbstractStockTransactionCostDecider (base class)
  - StockTransactionCostDecider (with per-order commission tracking, PIT tax)
  - FuturesTransactionCostDecider (BY_MONEY / BY_VOLUME modes)
"""

from rqmojo.const import (
    INSTRUMENT_TYPE, SIDE, POSITION_EFFECT,
    COMMISSION_TYPE, HEDGE_TYPE,
)
from rqmojo.interface import TransactionCostArgs, TransactionCost
from std.collections import Dict, List, Optional
from std.math import max as math_max


comptime __all__: List[String] = [
    "StockTransactionCostDecider",
    "FutureTransactionCostDecider",
    "BondTransactionCostDecider",
    "create_stock_decider",
    "create_future_decider",
    "create_bond_decider",
]


@fieldwise_init
struct StockTransactionCostDecider(Movable):
    var commission_rate: Float64
    var commission_multiplier: Float64
    var commission_map: Dict[Int, Float64]
    var min_commission: Float64
    var tax_rate: Float64
    var tax_multiplier: Float64

    def __init__(
        commission_rate: Float64 = 0.0008,
        commission_multiplier: Float64 = 1.0,
        min_commission: Float64 = 5.0,
        tax_rate: Float64 = 0.0005,
        tax_multiplier: Float64 = 1.0,
    ) -> Self:
        var cmap = Dict[Int, Float64]()
        return Self(
            commission_rate=commission_rate,
            commission_multiplier=commission_multiplier,
            commission_map=cmap^,
            min_commission=min_commission,
            tax_rate=tax_rate,
            tax_multiplier=tax_multiplier,
        )

    def _calc_commission(mut self, args: TransactionCostArgs) raises -> Float64:
        """Calculate commission using per-order tracking algorithm."""
        var cost_commission = (
            args.price * Float64(args.quantity) *
            self.commission_rate * self.commission_multiplier
        )
        var order_id = args.order_id
        if order_id == 0:
            return math_max(cost_commission, self.min_commission)

        if order_id not in self.commission_map:
            self.commission_map[order_id] = self.min_commission

        var commission_ref = self.commission_map[order_id]

        if cost_commission > commission_ref:
            if commission_ref == self.min_commission:
                self.commission_map[order_id] = 0.0
                return cost_commission
            else:
                self.commission_map[order_id] = 0.0
                return cost_commission - commission_ref
        else:
            if commission_ref == self.min_commission:
                self.commission_map[order_id] = commission_ref - cost_commission
                return commission_ref
            else:
                self.commission_map[order_id] = commission_ref - cost_commission
                return 0.0

    def _calc_tax(self, args: TransactionCostArgs) -> Float64:
        """Calculate stamp tax: BUY side has no tax."""
        if args.side == SIDE.BUY:
            return 0.0
        var cost_money = args.price * Float64(args.quantity)
        return cost_money * self.tax_rate * self.tax_multiplier

    def calc(mut self, args: TransactionCostArgs) raises -> TransactionCost:
        return TransactionCost(
            commission=self._calc_commission(args),
            tax=self._calc_tax(args),
            other_fees=0.0,
        )

    def update_tax_rate(mut self, before_pit_change_date: Bool) -> None:
        """Update tax rate based on trading date (PIT tax logic)."""
        if before_pit_change_date:
            self.tax_rate = 0.001
        else:
            self.tax_rate = 0.0005


@fieldwise_init
struct FutureTransactionCostDecider(Movable):
    var commission_multiplier: Float64
    var hedge_type: Int

    def __init__(commission_multiplier: Float64 = 1.0) -> Self:
        return Self(
            commission_multiplier=commission_multiplier,
            hedge_type=0,
        )

    def _calc_commission(
        self,
        args: TransactionCostArgs,
        open_commission_ratio: Float64 = 0.000025,
        close_commission_ratio: Float64 = 0.000025,
        close_commission_today_ratio: Float64 = 0.000025,
        contract_multiplier: Float64 = 1.0,
        commission_type: COMMISSION_TYPE = COMMISSION_TYPE.BY_MONEY,
    ) -> Float64:
        """Calculate futures commission (pure function, no mutation)."""
        var commission = 0.0
        if commission_type.name == "BY_MONEY":
            if args.position_effect == POSITION_EFFECT.OPEN:
                commission += (
                    args.price * Float64(args.quantity) *
                    contract_multiplier * open_commission_ratio
                )
            else:
                commission += args.price * (
                    Float64(args.quantity - args.close_today_quantity)
                ) * contract_multiplier * close_commission_ratio
                commission += (
                    args.price * Float64(args.close_today_quantity) *
                    contract_multiplier * close_commission_today_ratio
                )
        else:
            if args.position_effect == POSITION_EFFECT.OPEN:
                commission += Float64(args.quantity) * open_commission_ratio
            else:
                commission += (
                    Float64(args.quantity - args.close_today_quantity) *
                    close_commission_ratio
                )
                commission += (
                    Float64(args.close_today_quantity) *
                    close_commission_today_ratio
                )
        return commission * self.commission_multiplier

    def calc(self, args: TransactionCostArgs) -> TransactionCost:
        return TransactionCost(
            commission=self._calc_commission(args),
            tax=0.0,
            other_fees=0.0,
        )


@fieldwise_init
struct BondTransactionCostDecider(Movable):
    var commission_multiplier: Float64

    def calc(self, args: TransactionCostArgs) -> TransactionCost:
        var commission = (
            args.price * Float64(args.quantity) * self.commission_multiplier
        )
        return TransactionCost(
            commission=commission,
            tax=0.0,
            other_fees=0.0,
        )


def create_stock_decider(
    commission_multiplier: Float64 = 1.0,
    min_commission: Float64 = 5.0,
    tax_multiplier: Float64 = 1.0,
) -> StockTransactionCostDecider:
    return StockTransactionCostDecider(
        commission_multiplier=commission_multiplier,
        min_commission=min_commission,
        tax_multiplier=tax_multiplier,
    )


def create_future_decider(
    commission_multiplier: Float64 = 1.0,
) -> FutureTransactionCostDecider:
    return FutureTransactionCostDecider(
        commission_multiplier=commission_multiplier,
    )


def create_bond_decider(
    commission_multiplier: Float64 = 1.0,
) -> BondTransactionCostDecider:
    return BondTransactionCostDecider(
        commission_multiplier=commission_multiplier,
    )
