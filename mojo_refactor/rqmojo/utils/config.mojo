"""
RQAlpha Mojo - Config
Ported from rqalpha/utils/config.py
"""

from std.collections import Dict, List
from rqmojo.const import RUN_TYPE, PERSIST_MODE, COMMISSION_TYPE
from rqmojo.utils.typing import DateTime, DateTimeDate


@fieldwise_init
struct BaseConfig(Movable):
    var start_date: DateTime
    var end_date: DateTime
    var frequency: String
    var run_type: RUN_TYPE
    var data_bundle_path: String
    var strategy_file: String
    var persist_mode: PERSIST_MODE
    var initial_cash: Float64
    var rqdatac_uri: String


@fieldwise_init
struct ExtraConfig(Copyable, Movable, ImplicitlyCopyable):
    var locale: String
    var context_vars: String
    var is_hold: Bool


@fieldwise_init
struct ModConfig(Movable, ImplicitlyCopyable):
    var enabled: Bool


@fieldwise_init
struct RQAlphaConfig(Movable):
    var base: BaseConfig
    var extra: ExtraConfig
    var mod: ModConfig

    def __str__(self) -> String:
        return "RQAlphaConfig(" + self.base.start_date.__str__() + " to " + self.base.end_date.__str__() + ")"


def parse_run_type(rt_str: String) -> RUN_TYPE:
    if rt_str == "b" or rt_str == "backtest":
        return RUN_TYPE.BACKTEST
    elif rt_str == "p" or rt_str == "paper_trading":
        return RUN_TYPE.PAPER_TRADING
    elif rt_str == "r" or rt_str == "live_trading":
        return RUN_TYPE.LIVE_TRADING
    else:
        return RUN_TYPE.BACKTEST


def parse_persist_mode(mode_str: String) -> PERSIST_MODE:
    if mode_str == "real_time":
        return PERSIST_MODE.REAL_TIME
    elif mode_str == "on_crash":
        return PERSIST_MODE.ON_CRASH
    elif mode_str == "on_normal_exit":
        return PERSIST_MODE.ON_NORMAL_EXIT
    else:
        return PERSIST_MODE.ON_CRASH


def default_base_config() -> BaseConfig:
    return BaseConfig(
        start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        frequency="1d",
        run_type=RUN_TYPE.BACKTEST,
        data_bundle_path="~/.rqalpha/bundle",
        strategy_file="",
        persist_mode=PERSIST_MODE.ON_CRASH,
        initial_cash=100000.0,
        rqdatac_uri=""
    )


def default_extra_config() -> ExtraConfig:
    return ExtraConfig(
        locale="zh_CN",
        context_vars="",
        is_hold=False
    )


def default_mod_config() -> ModConfig:
    return ModConfig(enabled=True)


def default_config() -> RQAlphaConfig:
    return RQAlphaConfig(
        base=default_base_config()^,
        extra=default_extra_config()^,
        mod=default_mod_config()^
    )^


def create_config(
    start_date: DateTime,
    end_date: DateTime,
    frequency: String = "1d",
    run_type: RUN_TYPE = RUN_TYPE.BACKTEST
) -> RQAlphaConfig:
    var start_dt = DateTime(start_date.year, start_date.month, start_date.day, start_date.hour, start_date.minute, start_date.second, start_date.microsecond)
    var end_dt = DateTime(end_date.year, end_date.month, end_date.day, end_date.hour, end_date.minute, end_date.second, end_date.microsecond)
    return RQAlphaConfig(
        base=BaseConfig(
            start_date=start_dt^,
            end_date=end_dt^,
            frequency=frequency,
            run_type=run_type,
            data_bundle_path="~/.rqalpha/bundle",
            strategy_file="",
            persist_mode=PERSIST_MODE.ON_CRASH,
            initial_cash=100000.0,
            rqdatac_uri=""
        )^,
        extra=default_extra_config()^,
        mod=default_mod_config()^
    )^


def create_config_from_args(
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
    return create_config(start_dt^, end_dt^, frequency, rt)


def parse_config(
    config_dict: Dict[String, String],
    source_code: String = "",
    user_funcs: Dict[String, String] = Dict[String, String]()
) raises -> RQAlphaConfig:
    """
    Parse configuration dictionary into RQAlphaConfig.
    
    Args:
        config_dict: Configuration dictionary
        source_code: Strategy source code (optional)
        user_funcs: User function dictionary (optional)
        
    Returns:
        Parsed RQAlphaConfig
    """
    var base_cfg = default_base_config()
    var extra_cfg = default_extra_config()
    var mod_cfg = default_mod_config()
    
    for key in config_dict.keys():
        var value = config_dict[key]
        
        if key == "base.start_date" or key == "start_date":
            var parts = value.split("-")
            if len(parts) >= 3:
                base_cfg.start_date = DateTime(
                    Int(parts[0]), Int(parts[1]), Int(parts[2]), 0, 0, 0, 0
                )
        elif key == "base.end_date" or key == "end_date":
            var parts = value.split("-")
            if len(parts) >= 3:
                base_cfg.end_date = DateTime(
                    Int(parts[0]), Int(parts[1]), Int(parts[2]), 0, 0, 0, 0
                )
        elif key == "base.frequency" or key == "frequency":
            base_cfg.frequency = value
        elif key == "base.run_type" or key == "run_type":
            base_cfg.run_type = parse_run_type(value)
        elif key == "base.data_bundle_path" or key == "data_bundle_path":
            base_cfg.data_bundle_path = value
        elif key == "base.strategy_file" or key == "strategy_file":
            base_cfg.strategy_file = value
        elif key == "base.initial_cash" or key == "initial_cash":
            base_cfg.initial_cash = Float64(value)
        elif key == "base.persist_mode" or key == "persist_mode":
            base_cfg.persist_mode = parse_persist_mode(value)
        elif key == "extra.locale" or key == "locale":
            extra_cfg.locale = value
        elif key == "mod.enabled":
            mod_cfg.enabled = (value == "true" or value == "True")
    
    return RQAlphaConfig(base=base_cfg^, extra=extra_cfg^, mod=mod_cfg^)
