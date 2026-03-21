"""
RQAlpha Mojo - Exception Handling
Ported from rqalpha/utils/exception.py
"""

from collections import List
from rqmojo.const import EXC_TYPE


@fieldwise_init
struct CustomError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var msg: String
    var exc_type_name: String
    var error_type: EXC_TYPE
    var stacks: String

    def __str__(self) -> String:
        if len(self.stacks) == 0:
            return self.msg
        return self.stacks + "\n" + self.exc_type_name + ": " + self.msg

    @staticmethod
    def create(msg: String, exc_type_name: String = "Exception", error_type: EXC_TYPE = EXC_TYPE.NOTSET) -> Self:
        return Self(msg, exc_type_name, error_type, "")


@fieldwise_init
struct RQUserError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String
    var error_type: EXC_TYPE

    def __str__(self) -> String:
        return self.message

    def to_error(self) -> Error:
        return Error(self.message)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message, EXC_TYPE.USER_EXC)


@fieldwise_init
struct RQInvalidArgument(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    def __str__(self) -> String:
        return "RQInvalidArgument: " + self.message

    def to_error(self) -> Error:
        return Error("RQInvalidArgument: " + self.message)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQTypeError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    def __str__(self) -> String:
        return "RQTypeError: " + self.message

    def to_error(self) -> Error:
        return Error("RQTypeError: " + self.message)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQApiNotSupportedError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    def __str__(self) -> String:
        return "RQApiNotSupportedError: " + self.message

    def to_error(self) -> Error:
        return Error("RQApiNotSupportedError: " + self.message)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQDatacVersionTooLow(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    def __str__(self) -> String:
        return "RQDatacVersionTooLow: " + self.message

    def to_error(self) -> Error:
        return Error("RQDatacVersionTooLow: " + self.message)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct InstrumentNotFound(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    def __str__(self) -> String:
        return "InstrumentNotFound: " + self.message

    def to_error(self) -> Error:
        return Error("InstrumentNotFound: " + self.message)

    @staticmethod
    def create(order_book_id: String) -> Self:
        return Self("Instrument " + order_book_id + " not found")


@fieldwise_init
struct EnvironmentNotInitialized(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    def __str__(self) -> String:
        return "EnvironmentNotInitialized: " + self.message

    def to_error(self) -> Error:
        return Error("EnvironmentNotInitialized: " + self.message)

    @staticmethod
    def create() -> Self:
        return Self("Environment has not been initialized")


@fieldwise_init
struct BaseExceptionGroup(Stringable, Movable):
    var message: String
    var exceptions: List[Error]

    def __str__(self) -> String:
        if len(self.exceptions) == 1:
            return self.message + " (1 sub-exception)"
        return self.message + " (" + String(len(self.exceptions)) + " sub-exceptions)"

    @staticmethod
    def create(message: String, exceptions: List[Error]) raises -> Self:
        if len(message) == 0:
            raise Error("ExceptionGroup message must be a string")
        if len(exceptions) == 0:
            raise Error("second argument (exceptions) must be a non-empty sequence")
        return Self(message, exceptions)


@fieldwise_init
struct ExceptionGroup(Stringable, Movable):
    var message: String
    var exceptions: List[Error]

    def __str__(self) -> String:
        if len(self.exceptions) == 1:
            return self.message + " (1 sub-exception)"
        return self.message + " (" + String(len(self.exceptions)) + " sub-exceptions)"

    @staticmethod
    def create(message: String, exceptions: List[Error]) raises -> Self:
        if len(message) == 0:
            raise Error("ExceptionGroup message must be a string")
        if len(exceptions) == 0:
            raise Error("second argument (exceptions) must be a non-empty sequence")
        return Self(message, exceptions)


def format_exception_group(exc_group: ExceptionGroup, indent: String = "") -> String:
    var lines = List[String]()
    lines.append(indent + "ExceptionGroup: " + exc_group.message)
    
    for i in range(len(exc_group.exceptions)):
        var is_last = (i == len(exc_group.exceptions) - 1)
        var prefix = "|-- " if not is_last else "`-- "
        
        lines.append(indent + prefix + "Error: " + String(exc_group.exceptions[i]))
    
    var result = ""
    for i in range(len(lines)):
        if i > 0:
            result = result + "\n"
        result = result + lines[i]
    
    return result


def patch_user_exc(exc_type: EXC_TYPE) -> EXC_TYPE:
    if exc_type == EXC_TYPE.NOTSET:
        return EXC_TYPE.USER_EXC
    return exc_type


def patch_system_exc(exc_type: EXC_TYPE) -> EXC_TYPE:
    if exc_type == EXC_TYPE.NOTSET:
        return EXC_TYPE.SYSTEM_EXC
    return exc_type


def is_user_exc(exc_type: EXC_TYPE) -> Bool:
    return exc_type == EXC_TYPE.USER_EXC


def is_system_exc(exc_type: EXC_TYPE) -> Bool:
    return exc_type == EXC_TYPE.SYSTEM_EXC


def raise_invalid_argument(message: String) raises:
    raise Error("RQInvalidArgument: " + message)


def raise_instrument_not_found(order_book_id: String) raises:
    raise Error("InstrumentNotFound: Instrument " + order_book_id + " not found")


def raise_environment_not_initialized() raises:
    raise Error("EnvironmentNotInitialized: Environment has not been initialized")


def raise_api_not_supported(message: String) raises:
    raise Error("RQApiNotSupportedError: " + message)
