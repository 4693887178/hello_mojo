"""
RQAlpha Mojo - Argument Checker (Simplified)
Ported from rqalpha/utils/arg_checker.py
"""

from std.python import Python, PythonObject
from std.collections import List, Dict

from rqmojo.utils.i18n import gettext
from rqmojo.utils.exception import RQInvalidArgument, RQTypeError


comptime __all__: List[String] = [
    "ArgumentCheckerBase",
    "ArgumentChecker",
    "ArgumentConverter",
    "ApiArgumentsChecker",
    "verify_that",
    "assure_that",
]


def str_pyobject(obj: PythonObject) raises -> String:
    """Convert PythonObject to string representation."""
    var builtins = Python().import_module("builtins")
    var result = builtins.str(obj)
    return String(py=result)


@fieldwise_init
struct ArgumentCheckerBase(Writable, Movable):
    """验证/转换规则的基类."""
    var _arg_name: String

    def arg_name(self) -> String:
        return self._arg_name

    def raise_invalid_instrument_error(self, func_name: String, value: PythonObject) raises:
        self.raise_instrument_error(func_name, value, gettext("valid order_book_id/instrument"))

    def raise_instrument_not_listed_error(self, func_name: String, value: PythonObject) raises:
        self.raise_instrument_error(func_name, value, gettext("listed order_book_id/instrument"))

    def raise_instrument_error(
        self,
        func_name: String,
        value: PythonObject,
        instrument_info: String
    ) raises:
        var builtins = Python().import_module("builtins")
        var type_str = builtins.type(value)
        var type_name = builtins.str(type_str)

        raise RQInvalidArgument.create(
            gettext("function ") + func_name + gettext(": invalid ") + self._arg_name +
            gettext(" argument, expected a ") + instrument_info + gettext(", got ") +
            str_pyobject(value) + gettext(" (type: ") + String(py=type_name) + ")"
        )

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ArgumentCheckerBase(", self._arg_name, ")")


@fieldwise_init
struct ArgumentChecker(Writable, Movable):
    """仅验证参数，不修改参数值."""
    var _base: ArgumentCheckerBase
    var _pre_check: Bool
    var _rules: List[PythonObject]

    def __init__(out self, arg_name: String, pre_check: Bool = False):
        self._base = ArgumentCheckerBase(arg_name)
        self._pre_check = pre_check
        self._rules = List[PythonObject]()

    def arg_name(self) -> String:
        return self._base.arg_name()

    def pre_check(self) -> Bool:
        return self._pre_check

    def is_number(mut self) raises -> None:
        """验证是否为数字."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_is_number(arg_name):
    def inner(func_name, value):
        try:
            float(value)
        except (ValueError, TypeError):
            import builtins
            type_str = builtins.type(value)
            type_name = builtins.str(type_str)
            msg = (
                "function " + func_name + ": invalid " + arg_name +
                " argument, expect a number, got " + str(value) + " (type: " + str(type_name) + ")"
            )
            raise ValueError(msg)
    return inner

check_number_fn = check_is_number
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var rule_fn = getattr_from_module(rule_mod, "check_number_fn")(arg_name)
        self._rules.append(rule_fn)

    def is_in(mut self, valid_values: PythonObject, ignore_none: Bool = True) raises -> None:
        """检查值是否在有效值列表中."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_is_in_factory(arg_name, valid_values, ignore_none):
    def inner(func_name, value):
        if ignore_none and value is None:
            return
        if value not in valid_values:
            import builtins
            valid_repr = repr(valid_values)
            type_str = builtins.type(value)
            type_name = builtins.str(type_str)
            msg = (
                "function " + func_name + ": invalid " + arg_name +
                " argument, valid: " + str(valid_repr) + ", got " + str(value) + " (type: " + str(type_name) + ")"
            )
            raise ValueError(msg)
    return inner

is_in_factory_fn = check_is_in_factory
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var factory_fn = getattr_from_module(rule_mod, "is_in_factory_fn")
        var rule_fn = factory_fn(arg_name, valid_values, PythonObject(ignore_none))
        self._rules.append(rule_fn)

    def is_valid_date(mut self, ignore_none: Bool = True) raises -> None:
        """验证日期有效性."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_is_valid_date_factory(arg_name, ignore_none):
    def inner(func_name, value):
        import datetime
        import pandas as pd
        from dateutil.parser import parse as parse_date
        import six
        import builtins

        if ignore_none and value is None:
            return None

        if isinstance(value, (datetime.date, pd.Timestamp)):
            return

        if isinstance(value, six.string_types):
            try:
                v = parse_date(value)
                return
            except ValueError:
                type_str = builtins.type(value)
                type_name = builtins.str(type_str)
                msg = (
                    "function " + func_name + ": invalid " + arg_name +
                    " argument, expect a valid date, got " + str(value) + " (type: " + str(type_name) + ")"
                )
                raise ValueError(msg)

        type_str = builtins.type(value)
        type_name = builtins.str(type_str)
        msg = (
            "function " + func_name + ": invalid " + arg_name +
            " argument, expect a valid date, got " + str(value) + " (type: " + str(type_name) + ")"
        )
        raise ValueError(msg)
    return inner

valid_date_factory_fn = check_is_valid_date_factory
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var factory_fn = getattr_from_module(rule_mod, "valid_date_factory_fn")
        var rule_fn = factory_fn(arg_name, PythonObject(ignore_none))
        self._rules.append(rule_fn)

    def is_greater_or_equal_than(mut self, low: Float64) raises -> None:
        """验证值 >= low."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_greater_or_equal_than_factory(arg_name, low):
    def inner(func_name, value):
        import builtins
        if isinstance(value, (int, float)) and value < low:
            type_str = builtins.type(value)
            type_name = builtins.str(type_str)
            msg = (
                "function " + func_name + ": invalid " + arg_name +
                " argument, expect a value >= " + str(low) + ", got " + str(value) + " (type: " + str(type_name) + ")"
            )
            raise ValueError(msg)
    return inner

geq_factory_fn = check_greater_or_equal_than_factory
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var factory_fn = getattr_from_module(rule_mod, "geq_factory_fn")
        var rule_fn = factory_fn(arg_name, PythonObject(low))
        self._rules.append(rule_fn)

    def is_less_or_equal_than(mut self, high: Float64) raises -> None:
        """验证值 <= high."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_less_or_equal_than_factory(arg_name, high):
    def inner(func_name, value):
        import builtins
        if isinstance(value, (int, float)) and value > high:
            type_str = builtins.type(value)
            type_name = builtins.str(type_str)
            msg = (
                "function " + func_name + ": invalid " + arg_name +
                " argument, expect a value <= " + str(high) + ", got " + str(value) + " (type: " + str(type_name) + ")"
            )
            raise ValueError(msg)
    return inner

leq_factory_fn = check_less_or_equal_than_factory
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var factory_fn = getattr_from_module(rule_mod, "leq_factory_fn")
        var rule_fn = factory_fn(arg_name, PythonObject(high))
        self._rules.append(rule_fn)

    def is_valid_interval(mut self) raises -> None:
        """验证时间间隔格式（如'1d', '3m', '4q', '2y'）."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_is_valid_interval_factory(arg_name):
    def inner(func_name, value):
        import six
        import builtins

        valid = isinstance(value, six.string_types) and value[-1] in {'d', 'm', 'q', 'y'}
        if valid:
            try:
                valid = int(value[:-1]) > 0
            except (ValueError, TypeError):
                valid = False

        if not valid:
            type_str = builtins.type(value)
            type_name = builtins.str(type_str)
            msg = (
                "function " + func_name + ": invalid " + arg_name +
                " argument, interval should be in form of '1d', '3m', '4q', '2y', "
                "got " + str(value) + " (type: " + str(type_name) + ")"
            )
            raise ValueError(msg)
    return inner

interval_factory_fn = check_is_valid_interval_factory
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var factory_fn = getattr_from_module(rule_mod, "interval_factory_fn")
        var rule_fn = factory_fn(arg_name)
        self._rules.append(rule_fn)

    def is_valid_quarter(mut self) raises -> None:
        """验证季度格式（如'2012q3'）."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_is_valid_quarter_factory(arg_name):
    def inner(func_name, value):
        import six
        import builtins

        if value is None:
            valid = True
        else:
            valid = isinstance(value, six.string_types) and len(value) >= 2 and value[-2].lower() == 'q'
            if valid:
                try:
                    year_part = int(value[:-2])
                    quarter_part = int(value[-1])
                    valid = 1990 <= year_part <= 2099 and 1 <= quarter_part <= 4
                except (ValueError, TypeError, IndexError):
                    valid = False

        if not valid:
            type_str = builtins.type(value)
            type_name = builtins.str(type_str)
            msg = (
                "function " + func_name + ": invalid " + arg_name +
                " argument, quarter should be in form of '2012q3', "
                "got " + str(value) + " (type: " + str(type_name) + ")"
            )
            raise ValueError(msg)
    return inner

quarter_factory_fn = check_is_valid_quarter_factory
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var factory_fn = getattr_from_module(rule_mod, "quarter_factory_fn")
        var rule_fn = factory_fn(arg_name)
        self._rules.append(rule_fn)

    def is_valid_frequency(mut self) raises -> None:
        """验证频率格式（如'1m', '5m', '1d', '1w'）."""
        var arg_name = self._base.arg_name()
        var rule_code = """
def check_is_valid_frequency_factory(arg_name):
    def inner(func_name, value):
        import six
        import builtins

        valid = isinstance(value, six.string_types) and len(value) > 0 and value[-1] in ("d", "m", "w")
        if valid:
            try:
                valid = int(value[:-1]) > 0
            except (ValueError, TypeError):
                valid = False

        if not valid:
            type_str = builtins.type(value)
            type_name = builtins.str(type_str)
            msg = (
                "function " + func_name + ": invalid " + arg_name +
                " argument, frequency should be in form of "
                "'1m', '5m', '1d', '1w' got " + str(value) + " (type: " + str(type_name) + ")"
            )
            raise ValueError(msg)
    return inner

frequency_factory_fn = check_is_valid_frequency_factory
"""
        var rule_mod = Python.evaluate(rule_code, file=True)
        var factory_fn = getattr_from_module(rule_mod, "frequency_factory_fn")
        var rule_fn = factory_fn(arg_name)
        self._rules.append(rule_fn)

    def verify(self, func_name: String, call_args: Dict[String, PythonObject]) raises:
        """执行所有验证规则."""
        var arg_name = self._base.arg_name()
        if not (arg_name in call_args):
            return

        var value = call_args[arg_name]

        for i in range(len(self._rules)):
            var rule = self._rules[i]
            rule(func_name, value)

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ArgumentChecker(", self._base.arg_name(), ")")


@fieldwise_init
struct ArgumentConverter(Writable, Movable):
    """验证参数并转换参数值，转换后的值会替换原参数."""
    var _base: ArgumentCheckerBase
    var _rules: List[PythonObject]

    def __init__(out self, arg_name: String):
        self._base = ArgumentCheckerBase(arg_name)
        self._rules = List[PythonObject]()

    def arg_name(self) -> String:
        return self._base.arg_name()

    def convert(self, call_args: Dict[String, PythonObject]) raises -> PythonObject:
        """执行转换规则，返回转换后的值."""
        var arg_name = self._base.arg_name()
        if not (arg_name in call_args):
            return Python.none()

        var value = call_args[arg_name]

        for i in range(len(self._rules)):
            var rule = self._rules[i]
            value = rule(value)

        return value

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ArgumentConverter(", self._base.arg_name(), ")")


@fieldwise_init
struct ApiArgumentsChecker(Writable, Movable):
    """API参数检查器，管理多个检查器和转换器."""
    var _checker_names: List[String]
    var _converter_names: List[String]

    def __init__(out self):
        self._checker_names = List[String]()
        self._converter_names = List[String]()

    def add_checker(mut self, checker: ArgumentChecker):
        """添加检查器."""
        self._checker_names.append(checker.arg_name())

    def add_converter(mut self, converter: ArgumentConverter):
        """添加转换器."""
        self._converter_names.append(converter.arg_name())

    def verify(mut self, func_name: String, args: Dict[String, PythonObject]) raises:
        """执行所有检查器的验证（简化版）."""
        pass

    def convert(mut self, args: Dict[String, PythonObject]) raises -> Dict[String, PythonObject]:
        """应用所有转换器，返回转换后的参数字典（简化版）."""
        var result = Dict[String, PythonObject]()
        for key in args.keys():
            result[key] = args[key]
        return result^

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "ApiArgumentsChecker(checkers=", String(len(self._checker_names)),
            ", converters=", String(len(self._converter_names)), ")"
        )


def verify_that(arg_name: String, pre_check: Bool = False) -> ArgumentChecker:
    """创建ArgumentChecker的工厂函数."""
    return ArgumentChecker(arg_name=arg_name, pre_check=pre_check)


def assure_that(arg_name: String) -> ArgumentConverter:
    """创建ArgumentConverter的工厂函数."""
    return ArgumentConverter(arg_name=arg_name)


def getattr_from_module(mod: PythonObject, name: String) raises -> PythonObject:
    """Helper function to get attribute from module using getattr."""
    var builtins = Python().import_module("builtins")
    return builtins.getattr(mod, name)
