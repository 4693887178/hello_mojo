"""
RQAlpha Mojo - Strategy Loader
Ported from rqalpha/core/strategy_loader.py
"""

from std.collections import Dict


trait StrategyLoader:
    def load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]: ...


struct FileStrategyLoader(Movable, Writable, StrategyLoader):
    var strategy_file_path: String
    var loaded: Bool

    def __init__(out self, strategy_file_path: String, loaded: Bool = False):
        self.strategy_file_path = strategy_file_path
        self.loaded = loaded

    def write_to(self, mut writer: Some[Writer]):
        writer.write("FileStrategyLoader(", self.strategy_file_path, ")")

    def load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        result["strategy_file"] = self.strategy_file_path
        self.loaded = True
        return result^

    def is_loaded(self) -> Bool:
        return self.loaded

    def get_file_path(self) -> String:
        return self.strategy_file_path


struct SourceCodeStrategyLoader(Movable, Writable, StrategyLoader):
    var source_code: String
    var code_name: String
    var loaded: Bool

    def __init__(out self, source_code: String, code_name: String, loaded: Bool = False):
        self.source_code = source_code
        self.code_name = code_name
        self.loaded = loaded

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SourceCodeStrategyLoader(", self.code_name, ")")

    def load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        result["source_code"] = self.source_code
        result["code_name"] = self.code_name
        self.loaded = True
        return result^

    def is_loaded(self) -> Bool:
        return self.loaded

    def get_source_code(self) -> String:
        return self.source_code


struct UserFuncStrategyLoader(Movable, Writable, StrategyLoader):
    var func_count: Int
    var loaded: Bool

    def __init__(out self, func_count: Int = 0, loaded: Bool = False):
        self.func_count = func_count
        self.loaded = loaded

    def write_to(self, mut writer: Some[Writer]):
        writer.write("UserFuncStrategyLoader(funcs=", String(self.func_count), ")")

    def load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        for key in scope.keys():
            result[key] = scope.get(key, "")
        self.loaded = True
        return result^

    def is_loaded(self) -> Bool:
        return self.loaded

    def add_func(mut self) -> None:
        self.func_count += 1

    def get_func_count(self) -> Int:
        return self.func_count


struct FunctionStrategyLoader(Movable, Writable, StrategyLoader):
    var has_init: Bool
    var has_handle_bar: Bool
    var has_handle_tick: Bool
    var has_before_trading: Bool
    var has_after_trading: Bool
    var has_open_auction: Bool
    var loaded: Bool

    def __init__(out self):
        self.has_init = False
        self.has_handle_bar = False
        self.has_handle_tick = False
        self.has_before_trading = False
        self.has_after_trading = False
        self.has_open_auction = False
        self.loaded = False

    def write_to(self, mut writer: Some[Writer]):
        writer.write("FunctionStrategyLoader()")

    def load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        
        if self.has_init:
            result["init"] = "init_func"
        
        if self.has_handle_bar:
            result["handle_bar"] = "handle_bar_func"
        
        if self.has_handle_tick:
            result["handle_tick"] = "handle_tick_func"
        
        if self.has_before_trading:
            result["before_trading"] = "before_trading_func"
        
        if self.has_after_trading:
            result["after_trading"] = "after_trading_func"
        
        if self.has_open_auction:
            result["open_auction"] = "open_auction_func"
        
        for key in scope.keys():
            if result.get(key, "") == "":
                result[key] = scope.get(key, "")
        
        self.loaded = True
        return result^

    def is_loaded(self) -> Bool:
        return self.loaded

    def set_init(mut self) -> None:
        self.has_init = True

    def set_handle_bar(mut self) -> None:
        self.has_handle_bar = True

    def set_handle_tick(mut self) -> None:
        self.has_handle_tick = True

    def set_before_trading(mut self) -> None:
        self.has_before_trading = True

    def set_after_trading(mut self) -> None:
        self.has_after_trading = True

    def set_open_auction(mut self) -> None:
        self.has_open_auction = True


def create_file_strategy_loader(file_path: String) -> FileStrategyLoader:
    return FileStrategyLoader(strategy_file_path=file_path, loaded=False)


def create_source_code_strategy_loader(code: String, name: String = "strategy") -> SourceCodeStrategyLoader:
    return SourceCodeStrategyLoader(source_code=code, code_name=name, loaded=False)


def create_user_func_strategy_loader(func_count: Int = 0) -> UserFuncStrategyLoader:
    return UserFuncStrategyLoader(func_count=func_count, loaded=False)


def create_function_strategy_loader() -> FunctionStrategyLoader:
    return FunctionStrategyLoader()
