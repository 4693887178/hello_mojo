"""
RQAlpha Mojo - Config
Ported from rqalpha/utils/config.py
"""

from collections import Dict, List
from rqmojo.const import RUN_TYPE, PERSIST_MODE, COMMISSION_TYPE, RUN_TYPE_BACKTEST, RUN_TYPE_PAPER_TRADING, RUN_TYPE_LIVE_TRADING, PERSIST_MODE_REAL_TIME, PERSIST_MODE_ON_CRASH, PERSIST_MODE_ON_NORMAL_EXIT, RUN_TYPE_BACKTEST, RUN_TYPE_PAPER_TRADING, RUN_TYPE_LIVE_TRADING, PERSIST_MODE_REAL_TIME, PERSIST_MODE_ON_CRASH, PERSIST_MODE_ON_NORMAL_EXIT
from rqmojo.utils.datetime_func import DateTime, Date


@fieldwise_init
struct BaseConfig(Movable, ImplicitlyCopyable):
    var start_date: DateTime
    var end_date: DateTime
    var frequency: String
    var run_type: RUN_TYPE
    var data_bundle_path: String
    var strategy_file: String
    var persist_mode: PERSIST_MODE
    var initial_cash: Float64


@fieldwise_init
struct ExtraConfig(Copyable, Movable, ImplicitlyCopyable):
    var locale: String
    var context_vars: String
    var is_hold: Bool


@fieldwise_init
struct ModConfig(Movable, ImplicitlyCopyable):
    var enabled: Bool


@fieldwise_init
struct RQAlphaConfig(Movable, ImplicitlyCopyable):
    var base: BaseConfig
    var extra: ExtraConfig
    var mod: ModConfig

    fn __str__(self) -> String:
        return "RQAlphaConfig(" + self.base.start_date.__str__() + " to " + self.base.end_date.__str__() + ")"


fn parse_run_type(rt_str: String) -> RUN_TYPE:
    if rt_str == "b" or rt_str == "backtest":
        return RUN_TYPE_BACKTEST
    elif rt_str == "p" or rt_str == "paper_trading":
        return RUN_TYPE_PAPER_TRADING
    elif rt_str == "r" or rt_str == "live_trading":
        return RUN_TYPE_LIVE_TRADING
    else:
        return RUN_TYPE_BACKTEST


fn parse_persist_mode(mode_str: String) -> PERSIST_MODE:
    if mode_str == "real_time":
        return PERSIST_MODE_REAL_TIME
    elif mode_str == "on_crash":
        return PERSIST_MODE_ON_CRASH
    elif mode_str == "on_normal_exit":
        return PERSIST_MODE_ON_NORMAL_EXIT
    else:
        return PERSIST_MODE_ON_CRASH


fn default_base_config() -> BaseConfig:
    return BaseConfig(
        start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        frequency="1d",
        run_type=RUN_TYPE_BACKTEST,
        data_bundle_path="~/.rqalpha/bundle",
        strategy_file="",
        persist_mode=PERSIST_MODE_ON_CRASH,
        initial_cash=100000.0
    )


fn default_extra_config() -> ExtraConfig:
    return ExtraConfig(
        locale="zh_CN",
        context_vars="",
        is_hold=False
    )


fn default_mod_config() -> ModConfig:
    return ModConfig(enabled=True)


fn default_config() -> RQAlphaConfig:
    return RQAlphaConfig(
        base=default_base_config(),
        extra=default_extra_config(),
        mod=default_mod_config()
    )


fn create_config(
    start_date: DateTime,
    end_date: DateTime,
    frequency: String = "1d",
    run_type: RUN_TYPE = RUN_TYPE_BACKTEST
) -> RQAlphaConfig:
    return RQAlphaConfig(
        base=BaseConfig(
            start_date=start_date,
            end_date=end_date,
            frequency=frequency,
            run_type=run_type,
            data_bundle_path="~/.rqalpha/bundle",
            strategy_file="",
            persist_mode=PERSIST_MODE_ON_CRASH,
            initial_cash=100000.0
        ),
        extra=default_extra_config(),
        mod=default_mod_config()
    )


fn create_config_from_args(
    start_year: Int,
    start_month: Int,
    start_day: Int,
    end_year: Int,
    end_month: Int,
    end_day: Int,
    frequency: String = "1d",
    run_type_str: String = "b"
) -> RQAlphaConfig:
    var start_dt = DateTime(start_year, start_month, start_day, 0, 0, 0, 0)
    var end_dt = DateTime(end_year, end_month, end_day, 0, 0, 0, 0)
    var rt = parse_run_type(run_type_str)
    return create_config(start_dt, end_dt, frequency, rt)
