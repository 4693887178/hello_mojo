"""
RQAlpha Mojo - Strategy Loader Implementation
Ported from rqalpha/core/strategy_loader.py
"""

from std.collections import Dict, List, Optional
from rqmojo.interface import StrategyLoader
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject


@fieldwise_init
struct FileStrategyLoader(StrategyLoader, Movable, Writable):
    var _strategy_file: String
    var _scope: Dict[String, String]
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("FileStrategyLoader(file=", self._strategy_file, ")")
    
    def load(mut self):
        """从文件加载策略"""
        # 模拟从文件加载策略
        self._scope["__name__"] = "rqmojo.strategy"
        self._scope["init"] = "init"
        self._scope["handle_bar"] = "handle_bar"
        self._scope["before_trading"] = "before_trading"
        self._scope["after_trading"] = "after_trading"
    
    def init(mut self):
        """初始化策略"""
        print("FileStrategyLoader: init called")
    
    def handle_bar(mut self, bar: BarObject):
        """处理bar数据"""
        print("FileStrategyLoader: handle_bar called")
    
    def handle_tick(mut self, tick: TickObject):
        """处理tick数据"""
        print("FileStrategyLoader: handle_tick called")
    
    def before_trading(mut self):
        """交易前处理"""
        print("FileStrategyLoader: before_trading called")
    
    def after_trading(mut self):
        """交易后处理"""
        print("FileStrategyLoader: after_trading called")


@fieldwise_init
struct SourceCodeStrategyLoader(StrategyLoader, Movable, Writable):
    var _source_code: String
    var _scope: Dict[String, String]
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("SourceCodeStrategyLoader(code_length=", String(len(self._source_code)), ")")
    
    def load(mut self):
        """从源代码加载策略"""
        # 模拟从源代码加载策略
        self._scope["__name__"] = "rqmojo.strategy"
        self._scope["init"] = "init"
        self._scope["handle_bar"] = "handle_bar"
        self._scope["before_trading"] = "before_trading"
        self._scope["after_trading"] = "after_trading"
    
    def init(mut self):
        """初始化策略"""
        print("SourceCodeStrategyLoader: init called")
    
    def handle_bar(mut self, bar: BarObject):
        """处理bar数据"""
        print("SourceCodeStrategyLoader: handle_bar called")
    
    def handle_tick(mut self, tick: TickObject):
        """处理tick数据"""
        print("SourceCodeStrategyLoader: handle_tick called")
    
    def before_trading(mut self):
        """交易前处理"""
        print("SourceCodeStrategyLoader: before_trading called")
    
    def after_trading(mut self):
        """交易后处理"""
        print("SourceCodeStrategyLoader: after_trading called")


@fieldwise_init
struct UserFuncStrategyLoader(StrategyLoader, Movable, Writable):
    var _user_funcs: Dict[String, String]
    var _scope: Dict[String, String]
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("UserFuncStrategyLoader(funcs=", String(self._user_funcs.len()), ")")
    
    def load(mut self):
        """从用户函数加载策略"""
        # 模拟从用户函数加载策略
        self._scope["__name__"] = "rqmojo.strategy"
        for key, value in self._user_funcs.items():
            self._scope[key] = value
    
    def init(mut self):
        """初始化策略"""
        print("UserFuncStrategyLoader: init called")
    
    def handle_bar(mut self, bar: BarObject):
        """处理bar数据"""
        print("UserFuncStrategyLoader: handle_bar called")
    
    def handle_tick(mut self, tick: TickObject):
        """处理tick数据"""
        print("UserFuncStrategyLoader: handle_tick called")
    
    def before_trading(mut self):
        """交易前处理"""
        print("UserFuncStrategyLoader: before_trading called")
    
    def after_trading(mut self):
        """交易后处理"""
        print("UserFuncStrategyLoader: after_trading called")


def create_file_strategy_loader(strategy_file: String) -> FileStrategyLoader:
    """创建文件策略加载器"""
    return FileStrategyLoader(
        _strategy_file=strategy_file,
        _scope=Dict[String, String]()
    )


def create_source_code_strategy_loader(source_code: String) -> SourceCodeStrategyLoader:
    """创建源代码策略加载器"""
    return SourceCodeStrategyLoader(
        _source_code=source_code,
        _scope=Dict[String, String]()
    )


def create_user_func_strategy_loader(user_funcs: Dict[String, String]) -> UserFuncStrategyLoader:
    """创建用户函数策略加载器"""
    return UserFuncStrategyLoader(
        _user_funcs=user_funcs,
        _scope=Dict[String, String]()
    )


def create_strategy_loader(strategy_file: String = "", source_code: String = "", user_funcs: Dict[String, String] = Dict[String, String]()) -> StrategyLoader:
    """创建策略加载器"""
    if len(strategy_file) > 0:
        return create_file_strategy_loader(strategy_file)
    elif len(source_code) > 0:
        return create_source_code_strategy_loader(source_code)
    else:
        return create_user_func_strategy_loader(user_funcs)
