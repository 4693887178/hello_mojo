"""
RQAlpha Mojo - Strategy Loader
Ported from rqalpha/core/strategy_loader.py
"""

from collections import Dict


trait StrategyLoader:
    fn load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]


@fieldwise_init
struct FileStrategyLoader(Movable, Stringable):
    var strategy_file_path: String
    var loaded: Bool

    fn __str__(self) -> String:
        return "FileStrategyLoader(" + self.strategy_file_path + ")"

    fn load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        result["strategy_file"] = self.strategy_file_path
        self.loaded = True
        return result^

    fn is_loaded(self) -> Bool:
        return self.loaded

    fn get_file_path(self) -> String:
        return self.strategy_file_path


@fieldwise_init
struct SourceCodeStrategyLoader(Movable, Stringable):
    var source_code: String
    var code_name: String
    var loaded: Bool

    fn __str__(self) -> String:
        return "SourceCodeStrategyLoader(" + self.code_name + ")"

    fn load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        result["source_code"] = self.source_code
        result["code_name"] = self.code_name
        self.loaded = True
        return result^

    fn is_loaded(self) -> Bool:
        return self.loaded

    fn get_source_code(self) -> String:
        return self.source_code


@fieldwise_init
struct UserFuncStrategyLoader(Movable, Stringable):
    var func_count: Int
    var loaded: Bool

    fn __str__(self) -> String:
        return "UserFuncStrategyLoader(funcs=" + String(self.func_count) + ")"

    fn load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        for key in scope.keys():
            result[key] = scope.get(key, "")
        self.loaded = True
        return result^

    fn is_loaded(self) -> Bool:
        return self.loaded

    fn add_func(mut self) -> None:
        self.func_count += 1

    fn get_func_count(self) -> Int:
        return self.func_count


@fieldwise_init
struct FunctionStrategyLoader(Movable, Stringable):
    var has_init: Bool
    var has_handle_bar: Bool
    var has_handle_tick: Bool
    var has_before_trading: Bool
    var has_after_trading: Bool
    var has_open_auction: Bool
    var loaded: Bool

    fn __str__(self) -> String:
        return "FunctionStrategyLoader()"

    fn load(mut self, scope: Dict[String, String]) raises -> Dict[String, String]:
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

    fn is_loaded(self) -> Bool:
        return self.loaded

    fn set_init(mut self) -> None:
        self.has_init = True

    fn set_handle_bar(mut self) -> None:
        self.has_handle_bar = True

    fn set_handle_tick(mut self) -> None:
        self.has_handle_tick = True

    fn set_before_trading(mut self) -> None:
        self.has_before_trading = True

    fn set_after_trading(mut self) -> None:
        self.has_after_trading = True

    fn set_open_auction(mut self) -> None:
        self.has_open_auction = True


fn create_file_strategy_loader(file_path: String) -> FileStrategyLoader:
    return FileStrategyLoader(strategy_file_path=file_path, loaded=False)


fn create_source_code_strategy_loader(code: String, name: String = "strategy") -> SourceCodeStrategyLoader:
    return SourceCodeStrategyLoader(source_code=code, code_name=name, loaded=False)


fn create_user_func_strategy_loader(func_count: Int = 0) -> UserFuncStrategyLoader:
    return UserFuncStrategyLoader(func_count=func_count, loaded=False)


fn create_function_strategy_loader() -> FunctionStrategyLoader:
    return FunctionStrategyLoader(
        has_init=False,
        has_handle_bar=False,
        has_handle_tick=False,
        has_before_trading=False,
        has_after_trading=False,
        has_open_auction=False,
        loaded=False
    )
