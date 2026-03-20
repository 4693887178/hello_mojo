"""
RQAlpha Mojo - Exception Handling
Ported from rqalpha/utils/exception.py
"""

from rqmojo.const import EXC_TYPE, EXC_TYPE_NOTSET, EXC_TYPE_USER_EXC, EXC_TYPE_SYSTEM_EXC, EXC_TYPE_NOTSET, EXC_TYPE_USER_EXC, EXC_TYPE_SYSTEM_EXC


@fieldwise_init
struct CustomError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var msg: String
    var exc_type_name: String
    var error_type: EXC_TYPE
    var stacks: String

    fn __str__(self) -> String:
        if len(self.stacks) == 0:
            return self.msg
        return self.stacks + "\n" + self.exc_type_name + ": " + self.msg

    @staticmethod
    fn create(msg: String, exc_type_name: String = "Exception", error_type: EXC_TYPE = EXC_TYPE_NOTSET) -> Self:
        return Self(msg, exc_type_name, error_type, "")


@fieldwise_init
struct RQUserError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String
    var error_type: EXC_TYPE

    fn __str__(self) -> String:
        return self.message

    fn to_error(self) -> Error:
        return Error(self.message)

    @staticmethod
    fn create(message: String) -> Self:
        return Self(message, EXC_TYPE_USER_EXC)


@fieldwise_init
struct RQInvalidArgument(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    fn __str__(self) -> String:
        return "RQInvalidArgument: " + self.message

    fn to_error(self) -> Error:
        return Error("RQInvalidArgument: " + self.message)

    @staticmethod
    fn create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQTypeError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    fn __str__(self) -> String:
        return "RQTypeError: " + self.message

    fn to_error(self) -> Error:
        return Error("RQTypeError: " + self.message)

    @staticmethod
    fn create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQApiNotSupportedError(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    fn __str__(self) -> String:
        return "RQApiNotSupportedError: " + self.message

    fn to_error(self) -> Error:
        return Error("RQApiNotSupportedError: " + self.message)

    @staticmethod
    fn create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQDatacVersionTooLow(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    fn __str__(self) -> String:
        return "RQDatacVersionTooLow: " + self.message

    fn to_error(self) -> Error:
        return Error("RQDatacVersionTooLow: " + self.message)

    @staticmethod
    fn create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct InstrumentNotFound(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    fn __str__(self) -> String:
        return "InstrumentNotFound: " + self.message

    fn to_error(self) -> Error:
        return Error("InstrumentNotFound: " + self.message)

    @staticmethod
    fn create(order_book_id: String) -> Self:
        return Self("Instrument " + order_book_id + " not found")


@fieldwise_init
struct EnvironmentNotInitialized(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var message: String

    fn __str__(self) -> String:
        return "EnvironmentNotInitialized: " + self.message

    fn to_error(self) -> Error:
        return Error("EnvironmentNotInitialized: " + self.message)

    @staticmethod
    fn create() -> Self:
        return Self("Environment has not been initialized")


fn patch_user_exc(exc_type: EXC_TYPE) -> EXC_TYPE:
    if exc_type == EXC_TYPE_NOTSET:
        return EXC_TYPE_USER_EXC
    return exc_type


fn patch_system_exc(exc_type: EXC_TYPE) -> EXC_TYPE:
    if exc_type == EXC_TYPE_NOTSET:
        return EXC_TYPE_SYSTEM_EXC
    return exc_type


fn is_user_exc(exc_type: EXC_TYPE) -> Bool:
    return exc_type == EXC_TYPE_USER_EXC


fn is_system_exc(exc_type: EXC_TYPE) -> Bool:
    return exc_type == EXC_TYPE_SYSTEM_EXC


fn raise_invalid_argument(message: String) raises:
    raise Error("RQInvalidArgument: " + message)


fn raise_instrument_not_found(order_book_id: String) raises:
    raise Error("InstrumentNotFound: Instrument " + order_book_id + " not found")


fn raise_environment_not_initialized() raises:
    raise Error("EnvironmentNotInitialized: Environment has not been initialized")


fn raise_api_not_supported(message: String) raises:
    raise Error("RQApiNotSupportedError: " + message)
