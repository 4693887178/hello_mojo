"""
RQAlpha Mojo - Exception Handling
Ported from rqalpha/utils/exception.py
Mojo 0.26+ compatible
"""

from std.collections import List, Dict
from rqmojo.const import EXC_TYPE


comptime EXC_EXT_NAME: String = "ricequant_exc"


@fieldwise_init
struct StackFrame(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var filename: String
    var lineno: Int
    var func_name: String
    var code: String

    def write_to(self, mut writer: Some[Writer]):
        t"File {self.filename}, line {self.lineno} in {self.func_name}".write_to(writer)


@fieldwise_init
struct CustomError(Equatable, Writable):
    var msg: String
    var exc_type_name: String
    var error_type: EXC_TYPE
    var stacks: List[StackFrame]
    var max_exc_var_len: Int

    def write_to(self, mut writer: Some[Writer]):
        if len(self.stacks) == 0:
            self.msg.write_to(writer)
            return

        "Traceback (most recent call last):\n".write_to(writer)
        
        for frame in self.stacks:
            t"  File {frame.filename}, line {frame.lineno} in {frame.func_name}\n".write_to(writer)
            t"    {frame.code}\n".write_to(writer)
            "\n".write_to(writer)
        
        t"{self.exc_type_name}: {self.msg}".write_to(writer)

    @staticmethod
    def create(msg: String, exc_type_name: String = "Exception", error_type: EXC_TYPE = EXC_TYPE.NOTSET) -> Self:
        return Self(msg, exc_type_name, error_type, List[StackFrame](), 160)

    def add_stack_info(mut self, filename: String, lineno: Int, func_name: String, code: String):
        self.stacks.append(StackFrame(filename, lineno, func_name, code))

    def stacks_length(self) -> Int:
        return len(self.stacks)


@fieldwise_init
struct CustomException(Equatable, Writable):
    var error: CustomError

    def write_to(self, mut writer: Some[Writer]):
        self.error.write_to(writer)

    @staticmethod
    def create(error: CustomError) -> Self:
        return Self(error)


@fieldwise_init
struct RQUserError(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var message: String
    var error_type: EXC_TYPE

    def write_to(self, mut writer: Some[Writer]):
        self.message.write_to(writer)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message, EXC_TYPE.USER_EXC)


@fieldwise_init
struct RQInvalidArgument(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        t"RQInvalidArgument: {self.message}".write_to(writer)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQTypeError(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        t"RQTypeError: {self.message}".write_to(writer)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQApiNotSupportedError(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        t"RQApiNotSupportedError: {self.message}".write_to(writer)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct RQDatacVersionTooLow(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        t"RQDatacVersionTooLow: {self.message}".write_to(writer)

    @staticmethod
    def create(message: String) -> Self:
        return Self(message)


@fieldwise_init
struct InstrumentNotFound(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        t"InstrumentNotFound: {self.message}".write_to(writer)

    @staticmethod
    def create(order_book_id: String) -> Self:
        return Self("Instrument " + order_book_id + " not found")


@fieldwise_init
struct EnvironmentNotInitialized(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        t"EnvironmentNotInitialized: {self.message}".write_to(writer)

    @staticmethod
    def create() -> Self:
        return Self("Environment has not been initialized")


@fieldwise_init
struct BaseExceptionGroup(Equatable, Writable):
    var message: String
    var exceptions: List[Error]

    def write_to(self, mut writer: Some[Writer]):
        if len(self.exceptions) == 1:
            t"{self.message} (1 sub-exception)".write_to(writer)
        else:
            t"{self.message} ({len(self.exceptions)} sub-exceptions)".write_to(writer)

    @staticmethod
    def create(message: String, exceptions: List[Error]) raises -> Self:
        if len(message) == 0:
            raise Error("ExceptionGroup message must be a string")
        if len(exceptions) == 0:
            raise Error("second argument (exceptions) must be a non-empty sequence")
        return Self(message, exceptions)


@fieldwise_init
struct ExceptionGroup(Equatable, Writable):
    var message: String
    var exceptions: List[Error]

    def write_to(self, mut writer: Some[Writer]):
        if len(self.exceptions) == 1:
            t"{self.message} (1 sub-exception)".write_to(writer)
        else:
            t"{self.message} ({len(self.exceptions)} sub-exceptions)".write_to(writer)

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
        var prefix = "├─ " if not is_last else "└─ "
        
        var err = exc_group.exceptions[i]
        lines.append(indent + prefix + "Error: " + String(err))
    
    var result = ""
    for i in range(len(lines)):
        if i > 0:
            result = result + "\n"
        result = result + lines[i]
    
    return result


def patch_user_exc(exc_type: EXC_TYPE, force: Bool = False) -> EXC_TYPE:
    if exc_type == EXC_TYPE.NOTSET or force:
        return EXC_TYPE.USER_EXC
    return exc_type


def patch_system_exc(exc_type: EXC_TYPE, force: Bool = False) -> EXC_TYPE:
    if exc_type == EXC_TYPE.NOTSET or force:
        return EXC_TYPE.SYSTEM_EXC
    return exc_type


def get_exc_from_type(exc_type: EXC_TYPE) -> EXC_TYPE:
    return exc_type


def is_user_exc(exc_type: EXC_TYPE) -> Bool:
    return exc_type == EXC_TYPE.USER_EXC


def is_system_exc(exc_type: EXC_TYPE) -> Bool:
    return exc_type == EXC_TYPE.SYSTEM_EXC


@fieldwise_init
struct ModifyExceptionFromType(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var exc_from_type: EXC_TYPE
    var force: Bool

    def write_to(self, mut writer: Some[Writer]):
        "ModifyExceptionFromType".write_to(writer)

    @staticmethod
    def create(exc_from_type: EXC_TYPE, force: Bool = False) -> Self:
        return Self(exc_from_type, force)

    def __enter__(mut self) -> &Self:
        return &self

    def __exit__(mut self, exc_type: EXC_TYPE):
        pass
