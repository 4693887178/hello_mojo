# test_L01_04_config.mojo
# Module: rqmojo.utils.config
# Python: rqalpha.utils.config
# Level: L01 - Utils module
# Dependencies: const, datetime_func

from rqmojo.utils.config import (
    BaseConfig, ExtraConfig, ModConfig, RQAlphaConfig,
    parse_run_type, parse_persist_mode,
    default_base_config, default_extra_config, default_mod_config, default_config,
    create_config, create_config_from_args
)
from rqmojo.const import RUN_TYPE, PERSIST_MODE
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

    fn test_parse_run_type_backtest(mut self):
        var result = parse_run_type("b")
        self.check(result == RUN_TYPE.BACKTEST(), "parse_run_type 'b' returns BACKTEST")

    fn test_parse_run_type_paper_trading(mut self):
        var result = parse_run_type("p")
        self.check(result == RUN_TYPE.PAPER_TRADING(), "parse_run_type 'p' returns PAPER_TRADING")

    fn test_parse_run_type_live_trading(mut self):
        var result = parse_run_type("r")
        self.check(result == RUN_TYPE.LIVE_TRADING(), "parse_run_type 'r' returns LIVE_TRADING")

    fn test_parse_run_type_backtest_full(mut self):
        var result = parse_run_type("backtest")
        self.check(result == RUN_TYPE.BACKTEST(), "parse_run_type 'backtest' returns BACKTEST")

    fn test_parse_run_type_default(mut self):
        var result = parse_run_type("unknown")
        self.check(result == RUN_TYPE.BACKTEST(), "parse_run_type unknown returns BACKTEST")

    fn test_parse_persist_mode_real_time(mut self):
        var result = parse_persist_mode("real_time")
        self.check(result == PERSIST_MODE.REAL_TIME(), "parse_persist_mode 'real_time' returns REAL_TIME")

    fn test_parse_persist_mode_on_crash(mut self):
        var result = parse_persist_mode("on_crash")
        self.check(result == PERSIST_MODE.ON_CRASH(), "parse_persist_mode 'on_crash' returns ON_CRASH")

    fn test_parse_persist_mode_on_normal_exit(mut self):
        var result = parse_persist_mode("on_normal_exit")
        self.check(result == PERSIST_MODE.ON_NORMAL_EXIT(), "parse_persist_mode 'on_normal_exit' returns ON_NORMAL_EXIT")

    fn test_parse_persist_mode_default(mut self):
        var result = parse_persist_mode("unknown")
        self.check(result == PERSIST_MODE.ON_CRASH(), "parse_persist_mode unknown returns ON_CRASH")

    fn test_default_base_config(mut self):
        var config = default_base_config()
        self.check(config.frequency == "1d", "default_base_config frequency is 1d")
        self.check(config.initial_cash == 100000.0, "default_base_config initial_cash is 100000")

    fn test_default_extra_config(mut self):
        var config = default_extra_config()
        self.check(config.locale == "zh_CN", "default_extra_config locale is zh_CN")
        self.check(config.is_hold == False, "default_extra_config is_hold is False")

    fn test_default_mod_config(mut self):
        var config = default_mod_config()
        self.check(config.enabled == True, "default_mod_config enabled is True")

    fn test_default_config(mut self):
        var config = default_config()
        self.check(config.base.frequency == "1d", "default_config base.frequency is 1d")
        self.check(config.extra.locale == "zh_CN", "default_config extra.locale is zh_CN")
        self.check(config.mod.enabled == True, "default_config mod.enabled is True")

    fn test_create_config(mut self):
        var start = DateTime(2020, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2020, 12, 31, 0, 0, 0, 0)
        var config = create_config(start, end)
        self.check(config.base.start_date.year == 2020, "create_config start_date year is 2020")
        self.check(config.base.end_date.year == 2020, "create_config end_date year is 2020")

    fn test_create_config_with_frequency(mut self):
        var start = DateTime(2021, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2021, 12, 31, 0, 0, 0, 0)
        var config = create_config(start, end, "1m")
        self.check(config.base.frequency == "1m", "create_config with frequency 1m")

    fn test_create_config_from_args(mut self):
        var config = create_config_from_args(2022, 1, 1, 2022, 12, 31)
        self.check(config.base.start_date.year == 2022, "create_config_from_args start year is 2022")
        self.check(config.base.end_date.year == 2022, "create_config_from_args end year is 2022")

    fn test_create_config_from_args_with_run_type(mut self):
        var config = create_config_from_args(2022, 1, 1, 2022, 12, 31, "1d", "p")
        self.check(config.base.run_type == RUN_TYPE.PAPER_TRADING(), "create_config_from_args with run_type p")

    fn test_rqalpha_config_str(mut self):
        var config = default_config()
        var str_repr = config.__str__()
        self.check(str_repr.find("RQAlphaConfig") >= 0, "RQAlphaConfig __str__ contains RQAlphaConfig")

    fn test_base_config_fields(mut self):
        var config = default_base_config()
        self.check(config.data_bundle_path.find(".rqalpha") >= 0, "BaseConfig data_bundle_path contains .rqalpha")
        self.check(config.strategy_file == "", "BaseConfig strategy_file is empty string")

    fn run_all(mut self):
        print("=" * 60)
        print("L01_04_config Module Tests")
        print("=" * 60)
        
        self.test_parse_run_type_backtest()
        self.test_parse_run_type_paper_trading()
        self.test_parse_run_type_live_trading()
        self.test_parse_run_type_backtest_full()
        self.test_parse_run_type_default()
        self.test_parse_persist_mode_real_time()
        self.test_parse_persist_mode_on_crash()
        self.test_parse_persist_mode_on_normal_exit()
        self.test_parse_persist_mode_default()
        self.test_default_base_config()
        self.test_default_extra_config()
        self.test_default_mod_config()
        self.test_default_config()
        self.test_create_config()
        self.test_create_config_with_frequency()
        self.test_create_config_from_args()
        self.test_create_config_from_args_with_run_type()
        self.test_rqalpha_config_str()
        self.test_base_config_fields()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
