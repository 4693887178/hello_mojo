"""
RQAlpha Mojo - Argument Checker
Ported from rqalpha/utils/arg_checker.py
"""

from rqmojo.utils.i18n import gettext
from rqmojo.utils.exception import RQInvalidArgument, RQTypeError
from rqmojo.const import INSTRUMENT_TYPE
from std.collections import List, Dict


comptime __all__: List[String] = [
    "check_string",
    "check_int",
    "check_float",
    "check_percentage",
    "check_order_book_id",
    "ArgumentCheckerBase",
    "ArgumentChecker",
    "ArgumentConverter",
    "ApiArgumentsChecker",
]


def check_string(value: String, name: String) raises -> Bool:
    if len(value) == 0:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' cannot be empty string"))
    return True


def check_int(value: Int, name: String, min_val: Int = 0, max_val: Int = 999999999) raises -> Bool:
    if value < min_val:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' must be >= ") + String(min_val))
    if value > max_val:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' must be <= ") + String(max_val))
    return True


def check_float(value: Float64, name: String, min_val: Float64 = 0.0, max_val: Float64 = 1e12) raises -> Bool:
    if value < min_val:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' must be >= ") + String(min_val))
    if value > max_val:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' must be <= ") + String(max_val))
    return True


def check_percentage(value: Float64, name: String) raises -> Bool:
    if value < 0.0 or value > 1.0:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' must be between 0 and 1"))
    return True


def check_order_book_id(value: String, name: String) raises -> Bool:
    if len(value) == 0:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' cannot be empty"))
    if value.find(".") < 0:
        raise RQInvalidArgument.create(gettext("Argument '") + name + gettext("' must be in format 'CODE.EXCHANGE'"))
    return True


struct ArgumentCheckerBase(Writable, Movable):
    var _arg_name: String

    def __init__(out self, arg_name: String):
        self._arg_name = arg_name

    def arg_name(self) -> String:
        return self._arg_name

    def raise_invalid_instrument_error(self, func_name: String, value: String) raises:
        self.raise_instrument_error(func_name, value, gettext("valid order_book_id/instrument"))

    def raise_instrument_error(self, func_name: String, value: String, instrument_info: String) raises:
        raise RQInvalidArgument.create(
            gettext("function ") + func_name + gettext(": invalid ") + self._arg_name +
            gettext(" argument, expected a ") + instrument_info + gettext(", got ") + value
        )

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ArgumentCheckerBase(", self._arg_name, ")")


struct ArgumentChecker(Writable, Movable):
    var _base: ArgumentCheckerBase
    var _pre_check: Bool
    var _rules: List[fn(String, String) raises -> None]

    def __init__(out self, arg_name: String, pre_check: Bool = False):
        self._base = ArgumentCheckerBase(arg_name)
        self._pre_check = pre_check
        self._rules = List[fn(String, String) raises -> None]()

    def arg_name(self) -> String:
        return self._base.arg_name()

    def pre_check(self) -> Bool:
        return self._pre_check

    def is_instance_of(self, type_name: String) -> Self:
        var rule: fn(String, String) raises -> None = lambda(func_name: String, value: String) raises -> None:
            pass
        self._rules.append(rule)
        return self

    def is_number(self) -> Self:
        var rule: fn(String, String) raises -> None = lambda(func_name: String, value: String) raises -> None:
            pass
        self._rules.append(rule)
        return self

    def is_in(self, valid_values: List[String], ignore_none: Bool = True) -> Self:
        var rule: fn(String, String) raises -> None = lambda(func_name: String, value: String) raises -> None:
            if ignore_none and len(value) == 0:
                return
            var found = False
            for i in range(len(valid_values)):
                if valid_values[i] == value:
                    found = True
                    break
            if not found:
                raise RQInvalidArgument.create(
                    gettext("function ") + func_name + gettext(": invalid ") + self._base.arg_name() +
                    gettext(" argument, valid: ") + String(len(valid_values)) + gettext(" values, got ") + value
                )
        self._rules.append(rule)
        return self

    def is_greater_or_equal_than(self, low: Float64) -> Self:
        var rule: fn(String, String) raises -> None = lambda(func_name: String, value: String) raises -> None:
            pass
        self._rules.append(rule)
        return self

    def is_less_or_equal_than(self, high: Float64) -> Self:
        var rule: fn(String, String) raises -> None = lambda(func_name: String, value: String) raises -> None:
            pass
        self._rules.append(rule)
        return self

    def verify(self, func_name: String, value: String) raises:
        for i in range(len(self._rules)):
            self._rules[i](func_name, value)

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ArgumentChecker(", self._base.arg_name(), ")")


struct ArgumentConverter(Writable, Movable):
    var _base: ArgumentCheckerBase
    var _rules: List[fn(String) raises -> String]

    def __init__(out self, arg_name: String):
        self._base = ArgumentCheckerBase(arg_name)
        self._rules = List[fn(String) raises -> String]()

    def arg_name(self) -> String:
        return self._base.arg_name()

    def is_valid_order_book_id(self) -> Self:
        var rule: fn(String) raises -> String = lambda(value: String) raises -> String:
            if len(value) == 0:
                raise RQInvalidArgument.create(gettext("order_book_id cannot be empty"))
            return value
        self._rules.append(rule)
        return self

    def convert(self, value: String) raises -> String:
        var result = value
        for i in range(len(self._rules)):
            result = self._rules[i](result)
        return result

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ArgumentConverter(", self._base.arg_name(), ")")


struct ApiArgumentsChecker(Writable, Movable):
    var _checkers: List[ArgumentChecker]
    var _converters: List[ArgumentConverter]

    def __init__(out self):
        self._checkers = List[ArgumentChecker]()
        self._converters = List[ArgumentConverter]()

    def __init__(out self, rules: List[ArgumentChecker]):
        self._checkers = rules
        self._converters = List[ArgumentConverter]()

    def add_checker(self, checker: ArgumentChecker):
        self._checkers.append(checker)

    def add_converter(self, converter: ArgumentConverter):
        self._converters.append(converter)

    def verify(self, func_name: String, args: Dict[String, String]) raises:
        for i in range(len(self._checkers)):
            var checker = self._checkers[i]
            var arg_name = checker.arg_name()
            if args.contains(arg_name):
                checker.verify(func_name, args[arg_name])

    def convert(self, args: Dict[String, String]) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        for key in args.keys():
            result[key] = args[key]
        for i in range(len(self._converters)):
            var converter = self._converters[i]
            var arg_name = converter.arg_name()
            if result.contains(arg_name):
                result[arg_name] = converter.convert(result[arg_name])
        return result

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ApiArgumentsChecker(checkers=", String(len(self._checkers)), ", converters=", String(len(self._converters)), ")")


def verify_that(arg_name: String, pre_check: Bool = False) -> ArgumentChecker:
    return ArgumentChecker(arg_name, pre_check)


def assure_that(arg_name: String) -> ArgumentConverter:
    return ArgumentConverter(arg_name)
